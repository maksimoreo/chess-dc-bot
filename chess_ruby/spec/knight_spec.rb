require './lib/chesspieces/knight'
require './lib/chessboard'
require './lib/chess_position'

describe Knight do
  describe '#available_moves' do
    it 'returns 8 available moves when placed in the center of ab empty chessboard' do
      moves = Knight.white.available_moves(ChessPosition.from_s('d4'), Chessboard.new)
      expect(moves.size).to eql(8)
    end

    it 'returns 4 available moves when placed near the edge of an empty chessboard' do
      moves = Knight.white.available_moves(ChessPosition.from_s('a5'), Chessboard.new)
      expect(moves.size).to eql(4)
    end

    it 'returns 2 available moves when placed in the corner of an emtpy chessboard' do
      moves = Knight.white.available_moves(ChessPosition.from_s('a1'), Chessboard.new)
      expect(moves.size).to eql(2)
    end

    it "doesn't allow move on a cell with a figure of the same color" do
      cb = Chessboard.new
      cb[ChessPosition.from_s('b3')] = Knight.white
      moves = Knight.white.available_moves(ChessPosition.from_s('a1'), cb)
      expect(moves.size).to eql(1)
    end

    it 'does allow move on a cell with a figure of different color' do
      cb = Chessboard.new
      cb[ChessPosition.from_s('b3')] = Knight.black
      moves = Knight.white.available_moves(ChessPosition.from_s('a1'), Chessboard.new)
      expect(moves.size).to eql(2)
    end
  end
end
