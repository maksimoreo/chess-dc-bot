# frozen_string_literal: true

require_relative 'game_bot_base'

class ChessBotBase < GameBotBase
  attr_reader :chess_game, :max_moves

  def initialize(max_moves: 50, **args)
    super(**args)

    # User sends a chess move
    @bot.message(start_with: ChessMove.regex, in: @channel_id) { handle_message__chess_move_regex(_1) }

    # User can send move with '!move <move>', this command is defined mostly to be seen from !help command
    @bot.command(:move, aliases: [:go]) { handle_command__move(_1) }

    @chess_game = nil
    @max_moves = max_moves
  end

  def start_chess_game(white_player: nil, black_player: nil)
    @chess_game = ChessGame.new(white_player:, black_player:, max_moves:)
  end

  def end_chess_game
    @chess_game.uninitialize
    @chess_game = nil
  end

  def chess_game_state
    @chess_game.state
  end

  def send_chessboard(message)
    @chess_game.send_chessboard(@bot, @game_channel_id, message)
  end

  def send_chessboard_with_msg_accumulator(additional_msg = nil)
    accumulate_msg additional_msg unless additional_msg.nil?
    send_chessboard @msg_accumulator
    reset_msg_accumulator
  end

  # Game hasn't been started yet
  def game_going?
    !@chess_game.nil?
  end

  # Game was started and ended by now
  def game_end?
    @chess_game.end?
  end

  private

  def handle_message__chess_move_regex(event)
    on_move_message(event.user, ChessMove.from_s(event.content))

    nil
  end

  def handle_command__move(move_text)
    if move_text.nil? || move_text.empty?
      say 'Usage: !move <move>, e.g.: !move e2e4' if move_text.nil? || move_text.empty?
      return
    end

    on_move_message(event.user, ChessMove.from_s(move_text))
    nil
  end
end
