require_relative 'chesspiece'
require_relative '../directional_moves'

class Queen < ChessPiece
  include DiagonalMoves
  include AxisAlignedMoves

  def attack_cells(from, chessboard)
    attack_cells_diagonal(from, chessboard) + attack_cells_axis_aligned(from, chessboard)
  end
end
