require_relative 'chesspiece'
require_relative '../point'

class Knight < ChessPiece
  # 8 default knight's moves
  @default_moves = [[2, 1], [2, -1], [1, 2], [1, -2], [-1, 2], [-1, -2], [-2, 1], [-2, -1]].map do |array|
    Point.from_a(array)
  end

  def self.default_moves
    @default_moves
  end

  def attack_cells(from, _chessboard)
    Knight.default_moves
      .map { |direction| from + direction }
      .reject { |move| move.nil? }
  end
end
