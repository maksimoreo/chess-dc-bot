require './lib/chesspieces/queen'
require './lib/chessboard'

describe Queen do
  describe '#available_moves' do
    it 'returns 27 moves when placed in the center of the chessboard' do
      moves = Queen.white.available_moves(ChessPosition.from_s('e4'), Chessboard.new)
      expect(moves.size).to eql(27)
    end

    it 'returns 21 moves when placed in the corner of the chessboard' do
      moves = Queen.white.available_moves(ChessPosition.from_s('a1'), Chessboard.new)
      expect(moves.size).to eql(21)
    end

    it 'returns 4 moves' do
      cb = Chessboard.new
      cb[ChessPosition.from_s('a3')] = Queen.white
      cb[ChessPosition.from_s('b1')] = Queen.white
      cb[ChessPosition.from_s('b2')] = Queen.white
      moves = Queen.black.available_moves(ChessPosition.from_s('a1'), cb)
      expect(moves.size).to eql(4)
    end

    it 'returns 1 move' do
      cb = Chessboard.new
      cb[ChessPosition.from_s('d3')] = Queen.black
      cb[ChessPosition.from_s('d5')] = Queen.white
      cb[ChessPosition.from_s('c4')] = Queen.white
      cb[ChessPosition.from_s('e4')] = Queen.white
      cb[ChessPosition.from_s('e5')] = Queen.white
      cb[ChessPosition.from_s('e3')] = Queen.white
      cb[ChessPosition.from_s('c5')] = Queen.white
      cb[ChessPosition.from_s('c3')] = Queen.white
      moves = Queen.white.available_moves(ChessPosition.from_s('d4'), cb)
      expect(moves.size).to eql(1)
    end

    it 'returns 0 moves (empty array)' do
      cb = Chessboard.new
      cb[ChessPosition.from_s('a2')] = Queen.white
      cb[ChessPosition.from_s('b2')] = Queen.white
      cb[ChessPosition.from_s('b1')] = Queen.white
      moves = Queen.white.available_moves(ChessPosition.from_s('a1'), cb)
      expect(moves.size).to eql(0)
    end
  end
end
