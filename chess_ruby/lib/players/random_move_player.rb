require_relative 'player'

class RandomMovePlayer < Player
  def move(chessboard)
    chessboard.allowed_moves(@color).sample
  end
end
