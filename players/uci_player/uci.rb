

# UCI (Unified Chess Interface). This class provides interface to UCI compatible chess engine
class UCI
  def initialize(execute_command_name = nil)
    @io = IO.popen(execute_command_name, 'r+') unless execute_command_name.nil?
  end

  def start(execute_command_name)
    raise RuntimeError.new('io is still opened') if !@io.nil? && !@io.closed?
    @io = IO.popen(execute_command_name, mode = 'r+')
    @io.closed?
  end

  def prepare(uci_options = nil)
    # Block until 'uciok' is received
    send_and_receive 'uci', 'uciok'

    set_options uci_options

    # Block until 'readyok' is received
    send_and_receive 'isready', 'readyok'
  end

  def set_options(options_array)
    options_array.each { |(name,value)| set_option name, value } unless options_array.nil?
  end

  def set_option(name, value)
    send "setoption name #{name} value #{value}"
  end

  def new_game
    # Notify engine about new game
    send 'ucinewgame' # Engine shouldn't respond to this message
  end

  # Call this function before start_thinking to notify engine about chessboard position
  def send_fen(fen_string)
    send "position fen #{fen_string}"
  end

  # Call this function before receive_best_move to allow engine thinking
  # thinkging_time in seconds
  def start_thinking(thinking_time)
    send "go movetime #{thinking_time * 1000}"
  end

  # Combines above two methods
  def send_fen_and_think(fen_string, thinking_time)
    send_fen fen_string
    start_thinking thinking_time
  end

  # Make sure to send_fen before invoking this method
  # (u may occur in situation when u wait for the best move from engine and
  # engine waits for u to send_fen)
  # (u can do some additional work between send_fen and receive_best_move, then
  # call this function which will block until it receives the best move)
  def receive_best_move
    output = receive_get /^bestmove ([a-h][1-8]){2}[qrbk]?/
    ChessMove.from_s(output[9, 5])
  end

  # Combines above two methods
  def send_fen_and_receive_best_move(fen_string, thinking_time)
    send_fen_and_think(fen_string, thinking_time)
    receive_best_move
  end

  # If block is true this function will wait until engine receives goodbye msg
  def quit(block = true)
    send 'quit'

    # Block until eof is received
    @io.eof? if block

    @io.close
  end

  def send(text)
    @io.puts text
  end

  private

  # Block until text is received
  def receive(text)
    until @io.gets.match?(text); end
  end

  def receive_get(text)
    received_output = ''
    while true
      received_output = p @io.gets
      break if received_output.match? text
    end
    received_output
  end

  def send_and_receive(send_text, receive_text)
    send send_text
    receive receive_text
  end
end
