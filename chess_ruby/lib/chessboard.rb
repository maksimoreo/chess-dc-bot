require_relative 'chess_position'
require_relative 'chesspieces/chesspiece'
require_relative 'chesspieces/king'
require_relative 'chesspieces/queen'
require_relative 'chesspieces/rook'
require_relative 'chesspieces/bishop'
require_relative 'chesspieces/knight'
require_relative 'chesspieces/pawn'
require 'json'

# Container of 64 spaces for chess pieces
# Allows indexing by ChessPosition object
class Chessboard
  protected

  attr_reader :board

  public

  attr_reader :info
  attr_reader :en_passant

  def self.default_chessboard
    cb = Chessboard.new

    # Pawns
    (0..7).each do |j|
      cb[ChessPosition.new(1, j)] = Pawn.white
      cb[ChessPosition.new(6, j)] = Pawn.black
    end

    # Other chess pieces
    [[0, :white], [7, :black]].each do |row, color|
      [Rook, Knight, Bishop, Queen, King, Bishop, Knight, Rook].each_with_index do |chess_piece, column|
        cb[ChessPosition.new(row, column)] = chess_piece[color]
      end
    end

    cb
  end

  def self.from_json(str)
    cb = Chessboard.new
    cb.from_json(str)
    cb
  end

  # Creates an empty chess board
  def initialize
    @board = Array.new(64)

    @info = {
      white: {
        castling: {
          queenside: true, kingside: true
        }
      },
      black: {
        castling: {
          queenside: true, kingside: true
        }
      }
    }

    # En passant target square, position behind the pawn that has just made a two-square move
    @en_passant = nil

    # Number of half moves since the last capture or pawn advance. Used by fifty-move rule
    @half_moves = 0

    # Number of full moves. Increments after Black's move
    @move_count = 1
  end

  def initialize_copy(original)
    @board = original.board.dup

    @info = {
      white: { castling: original.info[:white][:castling].dup },
      black: { castling: original.info[:black][:castling].dup }
    }
  end

  def to_json
    board = @board.map { |chess_piece| chess_piece.nil? ? ' ' : [chess_piece.name, chess_piece.color] }
    { board: board, info: @info }.to_json
  end

  def from_json(str)
    hash = JSON.parse(str, { symbolize_names: true })
    @info = hash[:info]
    @board = hash[:board].map do |(chess_piece_name, color)|
      chess_piece_table = { 'Pawn' => Pawn, 'Knight' => Knight, 'Bishop' => Bishop,
        'Rook' => Rook, 'Queen' => Queen, 'King' => King }
      chess_piece_class = chess_piece_table[chess_piece_name]
      chess_piece_class.nil? ? nil : chess_piece_class[color.to_sym]
    end
  end

  def to_a
    @board.clone
  end

  def to_two_dimensional_array
    Array.new(8) { |row| Array.new(8) { |column| @board[row * 8 + column] } }
  end

  def ==(other)
    @board == other.board && @info == other.info
  end

  def board_eq?(other)
    @board == other.board
  end

  def [](position)
    @board[position.i * 8 + position.j]
  end

  def []=(position, object)
    @board[position.i * 8 + position.j] = object
  end

  def reposition(from, to)
    self[to] = self[from]
    self[from] = nil
  end

  def reset_half_move_counter
    @half_moves = 0
  end

  # This method follows en passant rule and 50 moves rule
  def move(chess_move)
    @updated_en_passant = false

    # If isn't a capturing move
    if self[chess_move.to].nil?
      @half_moves += 1
    else
      reset_half_move_counter # 50 moves rule counter resets after capturing
    end

    # Perform move by chess piece rules
    chess_piece_color = self[chess_move.from].color
    self[chess_move.from].perform_chess_move(chess_move, self)

    # Erase en passant if chess piece didn't update en passant
    @en_passant = nil unless @updated_en_passant

    # Increment move counter after black move
    @move_count += 1 if chess_piece_color == :black
  end

  def en_passant=(cell)
    @en_passant = cell
    @updated_en_passant = true
  end

  def can_move_or_take?(pos, color)
    self[pos].nil? || self[pos].color != color
  end

  def can_take?(pos, color)
    !self[pos].nil? && self[pos].color != color
  end

  def cell_empty?(pos)
    self[pos].nil?
  end

  def check?(color)
    king_pos = find_pos(King, color)
    cell_under_attack?(king_pos, ChessPiece.opposite_color(color))
  end

  def cell_under_attack?(check_cell, by_color)
    each_chess_piece_with_pos.any? do |chess_piece, pos|
      chess_piece.color == by_color && chess_piece.attack_cells(pos, self).include?(check_cell)
    end
  end

  # if color is :white or :black, returns each chess piece of specified color
  # if color is nil returns all chess pieces
  def each_chess_piece(color = nil)
    return to_enum(:each_chess_piece, color) unless block_given?
    @board.each do |cell|
      if !cell.nil? && (color.nil? || cell.color == color)
        yield(cell)
      end
    end
  end

  def each_chess_piece_with_pos(color = nil)
    return to_enum(:each_chess_piece_with_pos, color) unless block_given?
    @board.each_with_index do |cell, index|
      if !cell.nil? && (color.nil? || cell.color == color)
        yield(cell, ChessPosition.from_i(index))
      end
    end
  end

  def each_that_attacks(attack_pos, color = nil)
    return to_enum(:each_that_attacks, attack_pos, color) unless block_given?
    each_chess_piece_with_pos(color) do |piece, from_pos|
      yield(piece, from_pos) if piece.attack_cells(from_pos, self).include?(attack_pos)
    end
  end

  def find_pos(chess_piece_class, color = nil)
    index = @board.find_index do |cell|
      !cell.nil? && cell.class == chess_piece_class && (color.nil? || cell.color == color)
    end
    index.nil? ? nil : ChessPosition.from_i(index)
  end

  def attack_cells_from(pos)
    self[pos].attack_cells(pos, self)
  end

  def available_moves_from(pos)
    self[pos].available_moves(pos, self)
  end

  def allowed_cells_from(pos)
    self[pos].allowed_cells(pos, self)
  end

  def allowed_moves_from(pos)
    self[pos].allowed_moves(pos, self)
  end

  def allowed_moves(color)
    moves = []
    each_chess_piece_with_pos(color) do |chess_piece, pos|
      moves.push(*chess_piece.allowed_moves(pos, self))
    end
    moves
  end

  def to_fen(color_move)
    parts = []

    # 1 (piece placement)
    row_strings = []
    naming = { pawn: 'p', knight: 'n', bishop: 'b', rook: 'r', queen: 'q', king: 'k' }

    (0..7).reverse_each do |row_i|
      current_row = []
      empty_cell_counter = 0

      @board.slice(row_i * 8, 8).each do |cell|
        if cell.nil?
          empty_cell_counter += 1
        else
          unless empty_cell_counter.zero?
            current_row << empty_cell_counter
            empty_cell_counter = 0
          end

          char = naming[cell.name.downcase.to_sym]
          current_row << (cell.color == :white ? char.upcase : char)
        end
      end

      unless empty_cell_counter.zero?
        current_row << empty_cell_counter
      end

      row_strings << current_row.join('')
    end
    parts << row_strings.join('/')

    # 2 (active color)
    parts << color_move.to_s[0]

    # 3 (castling availability)
    castling_info = []
    ChessPiece.colors.each do |color|
      available_castlings = []
      available_castlings << 'k' if @info[color][:castling][:queenside]
      available_castlings << 'q' if @info[color][:castling][:queenside]

      if available_castlings.empty?
        castling_info << '-'
      else
        available_castlings = available_castlings.join('')
        castling_info << (color == :white ? available_castlings.upcase : available_castlings)
      end
    end
    parts << castling_info.join('')

    # 4 (En passant target cell)
    # lichess.org/editor (and prob some other engines too) specify en passant
    # square only if it possible for opposite color to make this move but wiki
    # says that en passant square should be recorded "regardless of whether
    # there is a pawn in position to make an en passant capture"
    # https://en.wikipedia.org/wiki/Forsyth%E2%80%93Edwards_Notation
    parts << (@en_passant.nil? ? '-' : @en_passant.to_s)

    # 5 (Number of half moves since capture or pawn move)
    parts << @half_moves

    # 6 (Move counter)
    parts << @move_count

    parts.join(' ')
  end
end
