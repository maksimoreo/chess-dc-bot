require './lib/chess_move'

describe ChessMove do
  describe '#new' do
    it "returns a move contructed from 'from' position and 'to' position" do
      from = ChessPosition.from_s('e2')
      to = ChessPosition.from_s('e4')
      move = ChessMove.new(from, to)
      expect(move.from).to eql(from)
      expect(move.to).to eql(to)
    end

    it 'also allows to specify pawn promotion' do
      from = ChessPosition.from_s('a1')
      to = ChessPosition.from_s('h8')
      move = ChessMove.new(from, to, :rook)
      expect(move.from).to eql(from)
      expect(move.to).to eql(to)
      expect(move.promotion).to eql(:rook)
    end
  end

  describe '#to_s' do
    it 'converts move without promotion to string' do
      move = ChessMove.new(ChessPosition.from_s('f6'), ChessPosition.from_s('c8'))
      expect(move.to_s).to eql('f6c8')
    end

    it 'converts move with promotion to string' do
      move = ChessMove.new(ChessPosition.from_s('b7'), ChessPosition.from_s('c8'), :knight)
      expect(move.to_s).to eql('b7c8k')
    end
  end

  describe '.regex' do
    it 'passes valid chess move' do
      expect('e4f8').to match(ChessMove.regex)
    end

    it 'passes valid chess move with promotion' do
      expect('e4f8').to match(ChessMove.regex)
    end
  end
end
