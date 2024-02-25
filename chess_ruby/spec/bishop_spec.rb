require './lib/chesspieces/bishop'
require './lib/chessboard'

describe Bishop do
  describe '#available_moves' do
    it 'returns 13 moves when placed in the center of the chessboard' do
      moves = Bishop.white.available_moves(ChessPosition.from_s('e4'), Chessboard.new)
      expect(moves.size).to eql(13)
    end

    it 'returns 7 moves when placed in the corner of the chessboard' do
      moves = Bishop.white.available_moves(ChessPosition.from_s('a1'), Chessboard.new)
      expect(moves.size).to eql(7)
    end

    it 'returns 2 moves' do
      cb = Chessboard.new
      cb[ChessPosition.from_s('c3')] = Bishop.white
      moves = Bishop.black.available_moves(ChessPosition.from_s('a1'), cb)
      expect(moves.size).to eql(2)
    end

    it 'returns 1 move' do
      cb = Chessboard.new
      cb[ChessPosition.from_s('c3')] = Bishop.black
      cb[ChessPosition.from_s('c5')] = Bishop.white
      cb[ChessPosition.from_s('e3')] = Bishop.white
      cb[ChessPosition.from_s('e5')] = Bishop.white
      moves = Bishop.white.available_moves(ChessPosition.from_s('d4'), cb)
      expect(moves.size).to eql(1)
    end

    it 'returns 0 moves (empty array)' do
      cb = Chessboard.new
      cb[ChessPosition.from_s('b2')] = Bishop.white
      moves = Bishop.white.available_moves(ChessPosition.from_s('a1'), cb)
      expect(moves.size).to eql(0)
    end
  end
end
