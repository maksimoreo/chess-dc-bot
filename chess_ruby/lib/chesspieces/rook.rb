require_relative 'chesspiece'
require_relative '../directional_moves'

class Rook < ChessPiece
  include AxisAlignedMoves

  def attack_cells(from, chessboard)
    attack_cells_axis_aligned(from, chessboard)
  end

  def perform_chess_move(chess_move, chessboard)
    super
    update_castling_info(chessboard, chess_move.from)
  end

  private

  def update_castling_info(chessboard, pos)
    if color == :white
      chessboard.info[:white][:castling][:queenside] = false if pos == ChessPosition.from_s('a1')
      chessboard.info[:white][:castling][:kingside] = false if pos == ChessPosition.from_s('h1')
    elsif color == :black
      chessboard.info[:black][:castling][:queenside] = false if pos == ChessPosition.from_s('a8')
      chessboard.info[:black][:castling][:kingside] = false if pos == ChessPosition.from_s('h8')
    end
  end
end
