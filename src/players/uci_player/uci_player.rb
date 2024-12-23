# frozen_string_literal: true

require_relative 'uci'
require_relative '../player'

# UCI engine chess player
class UCIPlayer < Player
  def initialize(uci_engine_path, options: nil)
    super()

    @uci = UCI.new(uci_engine_path)
    @uci.prepare options
  end

  def new_game(_chessboard, _color)
    @uci.new_game
  end

  def play(chessboard, time)
    @uci.send_fen_and_receive_best_move(chessboard.to_fen(@color), time)
  end

  def quit
    @uci.quit
  end
end
