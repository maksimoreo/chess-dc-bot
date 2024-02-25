require 'discordrb'

require_relative 'pausable_timer_task'

require_relative 'discord_config'
require_relative 'chess_bot_base'

# This script provides team vs computer chess gameplay
class ChessBotTeamVsComputer < ChessBotBase
  attr_reader :players_move_time

  def initialize(players_move_time:, computer_move_time:, chess_ai:, **args)
    super game_channel_id: DiscordConfig::CHANNEL_ID_TEAM_VS_COMPUTER, **args

    @chess_ai = chess_ai
    @players_move_time = players_move_time
    @computer_move_time = computer_move_time

    # Info about players team
    @players_votes = {}
    @players_color = nil

    # Initialize background thread
    @input_timer_task = PausableTimerTask.new(@players_move_time) do
      # sort and filter received messages
      # perform most popular user move
      # perform computer move or end the game
      # prepare to receive new messages or end the game
      on_timer_end()
      puts "#{Time.now} end of the task"
      :success # If return nil TaskObserver will think task returned an error
    end
    # @input_timer_task.add_observer(TaskObserver.new) # TODO: Add this again

    # User commands
    # User wants to start the game
    @bot.command :play, aliases: [:start] do |event|
      if game_going?
        say 'There is a game already going! End current game to start new one'
      else
        start_game
      end

      nil
    end

    # User wants to surrender
    @bot.command :surrender, aliases: [:resign, :giveup, :give_up, :abandon] do |event|
      if game_going?
        @players_votes[event.user.distinct] = :surrender
      else
        say 'The game is not started yet! Say !play to start a new game.'
      end
      nil
    end
  end

  def on_move_message(user, move)
    if game_going?
      if !@input_timer_task.paused?
        @players_votes[user.distinct] = move
        puts "Accepted move #{move} from #{user.distinct}"
      else
        say 'Not accepting moves rn, plz wait.'
      end
    else
      say 'The game is not started yet! Say !play to start a new game.'
    end
  end

  def start_game
    start_chess_game black_player: @chess_ai
    send_chessboard "New game started! Your goal is to checkmate computer in #{@max_moves} moves. You cannot ask for draw. Players have #{@players_move_time} seconds for their every move, computer has #{@computer_move_time} seconds for his move."
    start_receiving_moves
    @players_color = :white

    @input_timer_task.execution_interval = @players_move_time # In case bot admin changed players move time with !setint command
    @input_timer_task.resume
  end

  def on_timer_end
    puts "#{Time.now} Timer ended"

    if @players_votes.empty?
      say "Didn't receive any moves, stopping..."
      on_game_end
    else
      voted_moves, filtered_voted_moves = filter_players_votes
      puts 'Done sorting and filtering moves'

      # Info
      accumulate_msg "Received #{voted_moves.size} moves from #{@players_votes.size} users. " \
        "Selected #{filtered_voted_moves.size} allowed moves. #{chess_game.allowed_moves.size + 1} moves were allowed.\n"

      if filtered_voted_moves.empty?
        say_accumulated_msg "Didn't receive any allowed moves, stopping..."
        on_game_end
      else
        say_accumulated_msg voted_moves_message(filtered_voted_moves)

        # Select all moves with equal vote count
        best_moves = filtered_voted_moves.select { |_move, votes| votes == filtered_voted_moves.first[1] }
        best_move = nil

        if best_moves.size == 1
          best_move = best_moves.first[0]
          accumulate_msg "Performing move #{best_move}."
        else
          best_move = best_moves.to_a.sample[0]
          accumulate_msg "Performing move #{best_move} (choosen randomly from #{best_moves.size > 5 ? best_moves.first(5).map { |move, _votes| move }.join(', ') + ', ...' : best_moves.map { |move, _votes| move }.join(', ')})"
        end

        # Play move
        user_play best_move

        # Clear vote history
        @players_votes = {}
      end
    end
  end

  def voted_moves_message(move_vote_hash)
    msg = nil
    moves_to_show = move_vote_hash

    if move_vote_hash.size <= 5
      msg = "Showing your moves:\n"
    else
      msg = "Showing your moves: (first 5)\n"
      moves_to_show = move_vote_hash.first(5).to_h
    end

    msg + moves_to_show.each_with_index.map { |(move, votes), index| "#{index + 1}. #{move} - #{votes}" }.join("\n")
  end

  def start_receiving_moves
    # Start timer
    puts "#{Time.now} Timer started"

    # Notify users
    say "It is your turn to play, send your moves! You have #{@players_move_time} seconds"
  end

  def computer_play
    say "Computer is thinking... (#{@computer_move_time} seconds)"
    computer_move = @chess_game.play_player_move(@computer_move_time)
    send_chessboard "Computer plays move #{computer_move}:"

    # If computer didn't checkmate let user play his turn
    if !game_end?
      start_receiving_moves
    else
      on_game_end
    end
  end

  def user_play(move)
    if move.is_a?(Symbol) && move == :surrender
      say_accumulated_msg
      on_game_end
    else # Regular move
      @chess_game.try_move move
      send_chessboard_with_msg_accumulator

      # If user didn't checkmate let computer play his turn
      if !game_end? && !@chess_game.waiting_for_move?
        computer_play
      else
        on_game_end
      end
    end
  end

  def on_game_end
    # Stop timer task
    @input_timer_task.pause

    send_chessboard "Game ended! #{@players_color == @chess_game.state ? "players_won_message" : "players_lost_message"}"

    # Debug
    puts "on_game_end: chess_game.state: #{@chess_game.state}"

    # Cleaning
    end_chess_game
    @players_votes = {}
    @players_color = nil
  end

  def filter_players_votes
    # Sorted hash of voted moves { move => vote_number }
    voted_moves = @players_votes.reduce(Hash.new(0)) do |moves, (user, move)|
      moves[move] += 1
      moves
    end.sort_by { |_move, votes| votes}.reverse.to_h

    # Reject impossible moves
    filtered_voted_moves = voted_moves.select do |move, _count|
      (move.is_a?(Symbol) && move == :surrender) || chess_game.move_allowed?(move)
    end

    [voted_moves, filtered_voted_moves]
  end
end
