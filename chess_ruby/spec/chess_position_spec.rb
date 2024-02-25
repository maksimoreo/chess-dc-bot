#spec/chessboard_spec.rb
require './lib/chess_position'

describe ChessPosition do
  describe '.from_s' do
    it 'returns ChessPosition object converted from string' do
      cpos = ChessPosition.from_s('a1')
      expect(cpos.i).to eql(0)
      expect(cpos.j).to eql(0)
    end

    it 'returns ChessPosition object converted from string' do
      cpos = ChessPosition.from_s('e8')
      expect(cpos.i).to eql(7)
      expect(cpos.j).to eql(4)
    end

    it 'returns nil if string is incorrect' do
      cpos = ChessPosition.from_s('a9')
      expect(cpos).to eql(nil)
    end
  end

  describe '.from_a' do
    it 'returns ChessPosition object converted from array' do
      cpos = ChessPosition.from_a([0, 0])
      expect(cpos.i).to eql(0)
      expect(cpos.j).to eql(0)
    end

    it 'returns ChessPosition object converted from array' do
      cpos = ChessPosition.from_a([5, 2])
      expect(cpos.i).to eql(5)
      expect(cpos.j).to eql(2)
    end

    it 'returns nil if array is incorrect' do
      cpos = ChessPosition.from_a([8, 1])
      expect(cpos).to eql(nil)
    end
  end

  describe '.from_i' do
    it 'returns ChessPosition object converted from integer' do
      cpos = ChessPosition.from_i(17)
      expect(cpos.i).to eql(2)
      expect(cpos.j).to eql(1)
    end

    it 'returns nil if array is incorrect' do
      cpos = ChessPosition.from_i(64)
      expect(cpos).to eql(nil)
    end
  end

  describe '#to_s' do
    it 'returns chessboard cell position in algebraic notation' do
      expect(ChessPosition.new(4, 2).to_s).to eql('c5')
    end

    it 'returns same string as .from_s argument' do
      string = 'e8'
      expect(ChessPosition.from_s(string).to_s).to eql(string)
    end
  end

  describe '#to_a' do
    it 'returns chessboard cell position as array' do
      expect(ChessPosition.new(3, 5).to_a).to eql([3, 5])
    end

    it 'returns same array as .from_a argument' do
      array = [6, 0]
      expect(ChessPosition.from_a(array).to_a).to eql(array)
    end
  end

  describe '#to_h' do
    it 'returns chessboard cell position as array' do
      expect(ChessPosition.new(7, 1).to_h).to eql({ i: 7, j: 1})
    end
  end

  describe '#+' do
    it 'returns the sum of two ChessPosition objects' do
      expect(ChessPosition.new(1, 2) + ChessPosition.new(6, 3)).to eql(ChessPosition.new(7, 5))
    end

    it 'returns nil if result is outside the chessboard' do
      expect(ChessPosition.new(7, 2) + ChessPosition.new(1, 4)).to eql(nil)
    end
  end
end
