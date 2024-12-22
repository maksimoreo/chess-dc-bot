require_relative 'player'

class RandomMovePlayer < Player
  def play(chessboard, move_time)
    sleep move_time - 0.5 if move_time > 1 # imitate thinking
    chessboard.allowed_moves(@color).sample
  end
end
