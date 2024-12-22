# frozen_string_literal: true

require 'stringio'

require_relative '../chess_ruby/lib/chessboard'
require_relative '../chess_ruby/lib/chesspieces/chesspiece'
require_relative '../chess_ruby/lib/chess_move'

require_relative 'chessboard_printer/chessboard_printer'

class ChessGame
  attr_reader :current_color, :state

  def initialize(white_player: nil, black_player: nil, chessboard: Chessboard.default_chessboard, max_moves: 0)
    @cb_printer = ChessboardPrinter.new
    @chessboard = chessboard
    @current_color = :white
    update_allowed_moves

    @color_player_hash = { white: white_player, black: black_player }
    white_player&.invoke_new_game(@chessboard, :white)
    black_player&.invoke_new_game(@chessboard, :black)

    @state = nil

    @moves_counter = 0
    @max_moves = max_moves
  end

  def play_player_move(move_time)
    return if current_player.nil?

    move = current_player.invoke_play(@chessboard, move_time)
    try_move(move)

    move
  end

  def try_move(move)
    unless move_allowed?(move)
      puts "this move is not allowed: #{move}"
      return
    end

    @chessboard.move(move)
    puts "performed this move: #{move}"
    switch_current_color
    @moves_counter += 1 if @current_color == :white
    update_allowed_moves
    update_state
  end

  def send_chessboard(bot, channel_id, message)
    message ||= 'Rendered chessboard image:'

    image = @cb_printer.print(@chessboard)
    image_io = StringIO.new(image.to_blob)

    # hax
    # saw usage of this here:
    # https://stackoverflow.com/questions/7984902/restclient-multipart-upload-from-io
    # and here:
    # https://gist.github.com/Burgestrand/850377
    def image_io.path
      'message.png'
    end

    bot.send_file(channel_id, image_io, caption: message)
  end

  def move_allowed?(move)
    @allowed_moves.include? move
  end

  # If array is passed, selects allowed moves from a given array for current game state
  def allowed_moves(moves_array = nil)
    if moves_array.nil?
      @allowed_moves
    else
      moves_array.select { |move| @allowed_moves.inlcude?(move) }
    end
  end

  def end?
    !@state.nil?
  end

  def waiting_for_move?
    current_player.nil?
  end

  def update_allowed_moves
    @allowed_moves = @chessboard.allowed_moves(@current_color)
  end

  def moves_left
    @max_moves.zero? ? nil : @max_moves - @moves_counter
  end

  def uninitialize
    @color_player_hash.each_value do |player|
      player&.invoke_stop_game
    end
  end

  private

  def current_player
    @color_player_hash[@current_color]
  end

  def switch_current_color
    @current_color = @current_color == :white ? :black : :white
  end

  def update_state
    # If no moves for current color
    @state = if @allowed_moves.empty?
               # If current player is in check (checkmate)
               if @chessboard.check?(@current_color)
                 ChessPiece.opposite_color(@current_color)
               else
                 :draw
               end
             # If counting moves and moves counter exceeded max moves
             elsif !@max_moves.zero? && @moves_counter >= @max_moves
               :out_of_moves
             end
  end
end
