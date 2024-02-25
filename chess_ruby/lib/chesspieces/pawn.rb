# frozen_string_literal: true

require_relative 'chesspiece'
require_relative 'queen'
require_relative 'rook'
require_relative 'bishop'
require_relative 'knight'

# Pawn chesspiece
class Pawn < ChessPiece
  @promotion = { queen: Queen, rook: Rook, bishop: Bishop, knight: Knight }

  def self.promotion(promote_to, color)
    @promotion.fetch(promote_to, Queen)[color]
  end

  # Pawn only attacks cells diagonally forward
  def attack_cells(from, _chessboard)
    forward = from.up(color == :white ? 1 : -1)
    forward.nil? ? [] : [forward.right, forward.left].reject(&:nil?)
  end

  def perform_chess_move(chess_move, chessboard)
    super

    # After move was performed check if pawn can be promoted
    if (color == :white && chess_move.to.i == 7) || (color == :black && chess_move.to.i == 0)
      promote(chessboard, chess_move.to, chess_move.promotion)
    end

    # After two-square move notify that en passant move is available
    if (chess_move.from.i - chess_move.to.i).abs == 2
      chessboard.en_passant = behind(chess_move.to)
    end

    # If performing en passant move remove pawn that is being captured
    if chess_move.to == chessboard.en_passant
      chessboard[behind(chess_move.to)] = nil
    end

    # All pawn moves reset 50 moves rule counter
    chessboard.reset_half_move_counter
  end

  def available_cells(from, chessboard)
    start_row, direction = start_row_and_direction

    cells = []
    forward = from.up(direction)

    unless forward.nil?
      # Forward
      if chessboard[forward].nil?
        cells << forward

        double_forward = forward.up(direction)
        cells << double_forward if !double_forward.nil? && chessboard[double_forward].nil?
      end

      # Side capturing, En passant
      [forward.left, forward.right].each do |forward_side|
        if !forward_side.nil? && (chessboard.can_take?(forward_side, color) || forward_side == chessboard.en_passant)
          cells << forward_side
        end
      end
    end

    cells
  end

  def available_moves(from_cell, chessboard)
    add_promotion_moves(from_cell, available_cells(from_cell, chessboard))
  end

  def allowed_moves(from_cell, chessboard)
    add_promotion_moves(from_cell, allowed_cells(from_cell, chessboard))
  end

  private

  def promote(chessboard, pos, promote_to)
    chessboard[pos] = Pawn.promotion(promote_to, color)
  end

  def behind(pos)
    color == :white ? pos.down : pos.up
  end

  def start_row_and_direction
    color == :white ? [1, 1] : [6, -1]
  end

  def add_promotion_moves(from_cell, to_cells)
    last_row = color == :white ? 7 : 0
    to_cells.flat_map do |to_cell|
      if to_cell.i == last_row
        ChessMove.valid_promotions.map do |promotion_piece_class|
          ChessMove.new(from_cell, to_cell, promotion_piece_class)
        end
      else
        ChessMove.new(from_cell, to_cell)
      end
    end
  end
end
