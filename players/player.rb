# Base class for chess player
# Provides variables:
# @color - accessible since #new_game untill #stop_game
# @prev_chessboard - accessible since second #play until #stop_game
class Player
  def invoke_new_game(chessboard, color)
    @prev_chessboard
    @chessboard = chessboard
    @color = color

    try_invoke :new_game, chessboard, color
  end

  def invoke_play(chessboard, time)
    @prev_chessboard = @chessboard
    @chessboard = chessboard

    play chessboard, time
  end

  def invoke_set_option(name, value)
    try_invoke :stop_game, name, value
  end

  def invoke_stop_game
    try_invoke :stop_game
  end

  def invoke_quit
    try_invoke :quit
  end

  private

  def try_invoke(method_name, *args)
    self.send(method_name, *args) if respond_to? method_name
  end
end
