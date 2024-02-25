require './lib/chesspieces/rook'
require './lib/chessboard'

describe Rook do
  describe '#available_moves' do
    it 'returns 14 moves when placed in the center of the chessboard' do
      moves = Rook.white.available_moves(ChessPosition.from_s('e4'), Chessboard.new)
      expect(moves.size).to eql(14)
    end

    it 'returns 14 moves when placed in the corner of the chessboard' do
      moves = Rook.white.available_moves(ChessPosition.from_s('a1'), Chessboard.new)
      expect(moves.size).to eql(14)
    end

    it 'returns 3 moves' do
      cb = Chessboard.new
      cb[ChessPosition.from_s('a3')] = Rook.white
      cb[ChessPosition.from_s('b1')] = Rook.white
      moves = Rook.black.available_moves(ChessPosition.from_s('a1'), cb)
      expect(moves.size).to eql(3)
    end

    it 'returns 1 move' do
      cb = Chessboard.new
      cb[ChessPosition.from_s('d3')] = Rook.black
      cb[ChessPosition.from_s('d5')] = Rook.white
      cb[ChessPosition.from_s('c4')] = Rook.white
      cb[ChessPosition.from_s('e4')] = Rook.white
      moves = Rook.white.available_moves(ChessPosition.from_s('d4'), cb)
      expect(moves.size).to eql(1)
    end

    it 'returns 0 moves (empty array)' do
      cb = Chessboard.new
      cb[ChessPosition.from_s('a2')] = Rook.white
      cb[ChessPosition.from_s('b1')] = Rook.white
      moves = Rook.white.available_moves(ChessPosition.from_s('a1'), cb)
      expect(moves.size).to eql(0)
    end
  end

  describe '#attack_cells' do
    it 'returns array of cells' do
      cb = Chessboard.new
      cb[ChessPosition.from_s('g6')] = Rook.black
      cb[ChessPosition.from_s('g3')] = Pawn.white
      cb[ChessPosition.from_s('d6')] = Pawn.black

      moves = Rook.black.available_moves(ChessPosition.from_s('g6'), cb)
      attack_cells = Rook.black.attack_cells(ChessPosition.from_s('g6'), cb)

      expect(moves.size).to eql(8)
      expect(attack_cells.size).to eql(9)
    end
  end
end
