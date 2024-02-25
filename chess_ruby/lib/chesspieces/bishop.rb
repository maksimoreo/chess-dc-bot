require_relative 'chesspiece'
require_relative '../directional_moves'

class Bishop < ChessPiece
  include DiagonalMoves

  def attack_cells(from, chessboard)
    attack_cells_diagonal(from, chessboard)
  end
end
