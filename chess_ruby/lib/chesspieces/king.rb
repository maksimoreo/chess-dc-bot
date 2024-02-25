# frozen_string_literal: true

require_relative 'chesspiece'
require_relative '../directional_moves'
require_relative '../chess_position'

# King chess piece
class King < ChessPiece
  def allowed_cells(from, chessboard)
    # Not using available_cells(from, cb) here, because it also returns unchecked castlings
    moves = attack_cells(from, chessboard).reject do |cell|
      # Reject occupied cells
      next true unless chessboard.can_move_or_take?(cell, color)

      # Copy chessboard
      temp_chessboard = chessboard.clone

      # Perform the move on a temporary chessboard
      perform_chess_move(ChessMove.new(from, cell), temp_chessboard)

      # Reject moves that result in check
      temp_chessboard.check?(color)
    end

    castlings = allowed_castlings(chessboard, from, color == :white ? 0 : 7)

    moves + castlings
  end

  def available_cells(from, chessboard)
    moves = attack_cells(from, chessboard).select do |cell|
      chessboard.can_move_or_take?(cell, color)
    end

    castlings = available_castlings(chessboard, from, color == :white ? 0 : 7)

    moves + castlings
  end

  # King always attacks 8 cells around it (5 if on the edge, 3 if in the corner)
  def attack_cells(from, _chessboard)
    (DiagonalMoves.directions + AxisAlignedMoves.directions)
      .map { |direction| from + direction }
      .reject(&:nil?)
  end

  def move(chess_move, chessboard)
    # Move King
    chessboard.reposition(chess_move[:from], chess_move[:to])

    # Move Rook if performing a castling
    row = chess_move[:from].i
    if chess_move[:from].j == 4 && (row == 0 || row == 7)
      if chess_move[:to].j == 2 # Queenside
        chessboard.reposition(ChessPosition.new(row, 0), ChessPosition.new(row, 3))
      elsif chess_move[:to].j == 6 # Kingside
        chessboard.reposition(ChessPosition.new(row, 7), ChessPosition.new(row, 5))
      end
    end

    # disallow castling
    chessboard.info[color][:castling][:queenside] = false
    chessboard.info[color][:castling][:kingside] = false
  end

  def perform_chess_move(chess_move, chessboard)
    # Move King
    chessboard.reposition(chess_move.from, chess_move.to)

    # Move Rook if performing a castling
    row = chess_move.from.i
    if chess_move.from.j == 4 && (row == 0 || row == 7)
      if chess_move.to.j == 2 # Queenside
        chessboard.reposition(ChessPosition.new(row, 0), ChessPosition.new(row, 3))
      elsif chess_move.to.j == 6 # Kingside
        chessboard.reposition(ChessPosition.new(row, 7), ChessPosition.new(row, 5))
      end
    end

    # disallow castling
    chessboard.info[color][:castling][:queenside] = false
    chessboard.info[color][:castling][:kingside] = false
  end

  private

  def available_castlings(chessboard, pos, row)
    cells = []

    check = lambda do |side, rook_column, empty_from, empty_to|
        pos == ChessPosition.new(row, 4) && # King is on e1 or e8
        chessboard.info[color][:castling][side] && # Neither the king nor the chosen rook has previously moved.
        chessboard[ChessPosition.new(row, rook_column)] == Rook[color] && # There is a rook in the corner
        (empty_from..empty_to).all? { |n| chessboard.cell_empty?(ChessPosition.new(row, n)) } # There are no pieces between the king and the chosen rook
    end

    if pos == ChessPosition.new(row, 4)
      cells << ChessPosition.new(row, 2) if check.call(:queenside, 0, 1, 3)
      cells << ChessPosition.new(row, 6) if check.call(:kingside, 7, 5, 6)
    end

    cells
  end

  def allowed_castlings(chessboard, from, row)
    available_castlings(chessboard, from, row).select do |move|
      range = [from.j, move.j].minmax

      # King's cell, rook's cell and cells between them are not under attack
      (range[0]..range[1]).none? { |n| chessboard.cell_under_attack?(ChessPosition.new(row, n), ChessPiece.opposite_color(color)) }
    end
  end
end
