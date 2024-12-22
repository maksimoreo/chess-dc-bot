# frozen_string_literal: true

require 'discordrb'
require 'concurrent/scheduled_task'

require_relative 'chess_bot_base'

# This script provides team vs computer chess gameplay
class ChessBotTeamVsComputer < ChessBotBase
  attr_reader :players_move_time

  def initialize(players_move_time:, computer_move_time:, chess_ai:, **args)
    super(game_channel_id: ENV.fetch('CHESS_BOT_GAME_CHANNEL_ID'), **args)

    @chess_ai = chess_ai
    @players_move_time = players_move_time
    @computer_move_time = computer_move_time

    @players_votes = {}
    @players_color = nil

    # User commands
    @bot.command(:play, aliases: [:start]) { handle_command__play }
    @bot.command(:surrender, aliases: %i[resign giveup give_up abandon]) { handle_command__surrender(_1) }
  end

  def schedule_players_move_task
    raise 'Timer already running' unless @user_moves_task.nil?

    @user_moves_task = Concurrent::ScheduledTask.execute(@players_move_time) { handle_users_move_timer_completed }
  end

  def handle_command__play
    if game_going?
      say 'There is a game already going! End current game to start new one'
      return
    end

    start_game

    nil
  end

  def handle_command__surrender(event)
    unless game_going?
      say 'The game is not started yet! Say !play to start a new game.'
      return
    end

    @players_votes[event.user.distinct] = :surrender

    nil
  end

  def on_move_message(user, move)
    unless game_going?
      say 'The game is not started yet! Say !play to start a new game.'
      return
    end

    if @user_moves_task.nil?
      say 'Not accepting moves rn, plz wait.'
      return
    end

    @players_votes[user.distinct] = move
    puts "Accepted move #{move} from #{user.distinct}"
  end

  def start_game
    start_chess_game black_player: @chess_ai
    send_chessboard "New game started! Your goal is to checkmate computer in #{@max_moves} moves. You cannot ask for draw. Players have #{@players_move_time} seconds for their every move, computer has #{@computer_move_time} seconds for his move."
    start_receiving_moves
    @players_color = :white
  end

  def handle_users_move_timer_completed
    puts "#{Time.now.utc} Timer ended"

    @user_moves_task = nil

    if @players_votes.empty?
      say "Didn't receive any moves, stopping..."
      on_game_end
      return
    end

    voted_moves, filtered_voted_moves = filter_players_votes
    puts "#{Time.now.utc} Done sorting and filtering moves"

    # Info
    accumulate_msg(
      "Received #{voted_moves.size} moves from #{@players_votes.size} users. " \
      "Selected #{filtered_voted_moves.size} allowed moves. #{chess_game.allowed_moves.size} moves were allowed.\n"
    )

    if filtered_voted_moves.empty?
      say_accumulated_msg "Didn't receive any allowed moves, stopping..."
      on_game_end
      return
    end

    say_accumulated_msg voted_moves_message(filtered_voted_moves)

    # Select all moves with equal vote count
    best_moves = filtered_voted_moves.select { |_move, votes| votes == filtered_voted_moves.first[1] }
    best_move = nil

    if best_moves.size == 1
      best_move = best_moves.first[0]
      accumulate_msg "Performing move #{best_move}."
    else
      best_move = best_moves.to_a.sample[0]
      best_moves_text = best_moves.keys.first(5).join(', ')
      best_moves_text += ', ...' if best_moves.size > 5
      accumulate_msg(
        "Performing move #{best_move} (choosen randomly from #{best_moves.size} most voted moves: #{best_moves_text})"
      )
    end

    # Play move
    user_play best_move

    # Clear vote history
    @players_votes = {}
  rescue StandardError => e
    logger.error(e)
    raise
  end

  def voted_moves_message(move_vote_hash)
    msg = nil
    moves_to_show = move_vote_hash.first(5).to_h

    votes_list_text =
      moves_to_show
      .each_with_index
      .map { |(move, votes), index| "#{index + 1}. #{move} - #{votes} votes" }
      .join("\n")

    if move_vote_hash.size <= 5
      msg = "Submitted moves:\n"
      msg += votes_list_text
    else
      msg = "Submitted moves: (top 5)\n"
      msg += votes_list_text
      msg += "\n..."
    end

    msg + votes_list_text
  end

  def start_receiving_moves
    # Start timer
    puts "#{Time.now.utc} Timer started"

    # Notify users
    say "It is your turn to play, send your moves! You have #{@players_move_time} seconds"

    schedule_players_move_task
  end

  def computer_play
    say "Computer is thinking... (#{@computer_move_time} seconds)"
    computer_move = @chess_game.play_player_move(@computer_move_time)
    send_chessboard "Computer plays move #{computer_move}:"

    if game_end?
      on_game_end
      return
    end

    start_receiving_moves
  end

  def user_play(move)
    if move.is_a?(Symbol) && move == :surrender
      say_accumulated_msg
      on_game_end
      return
    end

    # Regular move
    @chess_game.try_move(move)
    send_chessboard_with_msg_accumulator

    # If user didn't checkmate let computer play his turn
    if !game_end? && !@chess_game.waiting_for_move?
      computer_play
    else
      on_game_end
    end
  end

  def on_game_end
    send_chessboard "Game ended! #{@players_color == @chess_game.state ? 'players_won_message' : 'players_lost_message'}"

    # Cleaning
    end_chess_game
    @players_votes = {}
    @players_color = nil
  end

  def filter_players_votes
    # Sorted hash of voted moves { move => vote_number }
    voted_moves =
      @players_votes
      .values
      .tally
      .sort_by { |_move, votes| votes }
      .reverse
      .to_h

    # Reject impossible moves
    filtered_voted_moves = voted_moves.select do |move, _count|
      (move.is_a?(Symbol) && move == :surrender) || chess_game.move_allowed?(move)
    end

    [voted_moves, filtered_voted_moves]
  end
end
