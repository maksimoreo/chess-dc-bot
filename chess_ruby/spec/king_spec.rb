require './lib/chesspieces/king'
require './lib/chesspieces/knight'
require './lib/chesspieces/rook'
require './lib/chesspieces/bishop'
require './lib/chessboard'

describe King do
  describe '#available_moves' do
    it 'returns 8 moves when placed in the center of the chessboard' do
      moves = King.white.available_moves(ChessPosition.from_s('e4'), Chessboard.new)
      expect(moves.size).to eql(8)
    end

    it 'returns 3 moves when placed in the corner of the chessboard' do
      moves = King.white.available_moves(ChessPosition.from_s('a1'), Chessboard.new)
      expect(moves.size).to eql(3)
    end

    it 'returns 3 moves' do
      cb = Chessboard.new
      cb[ChessPosition.from_s('a2')] = Knight.white
      cb[ChessPosition.from_s('b1')] = Knight.white
      moves = King.black.available_moves(ChessPosition.from_s('a1'), cb)
      expect(moves.size).to eql(3)
    end

    it 'returns 1 move' do
      cb = Chessboard.new
      cb[ChessPosition.from_s('a2')] = Knight.white
      cb[ChessPosition.from_s('b1')] = Knight.black
      cb[ChessPosition.from_s('b2')] = Knight.black
      moves = King.black.available_moves(ChessPosition.from_s('a1'), cb)
      expect(moves.size).to eql(1)
    end

    it 'returns 0 moves' do
      cb = Chessboard.new
      cb[ChessPosition.from_s('a2')] = Knight.black
      cb[ChessPosition.from_s('b1')] = Knight.black
      cb[ChessPosition.from_s('b2')] = Knight.black
      moves = King.black.available_moves(ChessPosition.from_s('a1'), cb)
      expect(moves.size).to eql(0)
    end
  end

  describe '#allowed_moves' do
    it "doesn't allow to move on cells that are under attack" do
      cb = Chessboard.new
      cb[ChessPosition.from_s('e8')] = Rook.black
      cb[ChessPosition.from_s('d4')] = King.white
      moves = King.white.allowed_moves(ChessPosition.from_s('d4'), cb)
      expect(moves.size).to eql(5)
    end

    it 'allows queenside castling' do
      cb = Chessboard.new
      king_pos = ChessPosition.from_s('e1')

      cb[king_pos] = King.white
      cb[ChessPosition.from_s('a1')] = Rook.white

      moves = cb.allowed_moves_from(king_pos)
      expect(moves.size).to eql(6)
      expect(moves).to include(ChessMove.from_s('e1c1'))
    end

    it 'allows kingside castling' do
      cb = Chessboard.new
      king_pos = ChessPosition.from_s('e8')

      cb[king_pos] = King.black
      cb[ChessPosition.from_s('h8')] = Rook.black

      moves = cb.allowed_moves_from(king_pos)
      expect(moves.size).to eql(6)
      expect(moves).to include(ChessMove.from_s('e8g8'))
    end

    it "doesn't allow queenside castling when king is under attack" do
      cb = Chessboard.new
      king_pos = ChessPosition.from_s('e1')

      cb[king_pos] = King.white
      cb[ChessPosition.from_s('a1')] = Rook.white
      cb[ChessPosition.from_s('e8')] = Rook.black

      moves = cb.allowed_moves_from(king_pos)
      expect(moves.size).to eql(4)
      expect(moves).not_to include(ChessMove.from_s('e1c1'))
    end

    it "doesn't allow kingside castling when cells between king and king's destination are under attack" do
      cb = Chessboard.new
      king_pos = ChessPosition.from_s('e1')

      cb[king_pos] = King.white
      cb[ChessPosition.from_s('h1')] = Rook.white
      cb[ChessPosition.from_s('g3')] = Knight.black

      moves = cb.allowed_moves_from(king_pos)
      expect(moves.size).to eql(3)
      expect(moves).not_to include(ChessMove.from_s('e1g1'))
    end

    it "doesn't allow castling if there are pieces between king and rook" do
      cb = Chessboard.new
      king_pos = ChessPosition.from_s('e8')

      cb[king_pos] = King.black
      cb[ChessPosition.from_s('a8')] = Rook.black
      cb[ChessPosition.from_s('b8')] = Bishop.white

      moves = cb.allowed_moves_from(king_pos)
      expect(moves.size).to eql(5)
      expect(moves).not_to include(ChessMove.from_s('e8c8'))
    end

    it "doesn't allow castling if king moved previously" do
      cb = Chessboard.new
      king_pos = ChessPosition.from_s('e8')

      cb[king_pos] = King.black
      cb[ChessPosition.from_s('h8')] = Rook.black

      # move king
      cb.move(ChessMove.from_s('e8f7'))
      cb.move(ChessMove.from_s('f7e8'))

      moves = cb.allowed_moves_from(king_pos)
      expect(moves.size).to eql(5)
      expect(moves).not_to include(ChessMove.from_s('e8g8'))
    end

    it "doesn't allow castling if rook moved previously" do
      cb = Chessboard.new
      king_pos = ChessPosition.from_s('e1')
      rook_pos = ChessPosition.from_s('a1')

      cb[king_pos] = King.white
      cb[rook_pos] = Rook.white

      # move rook
      cb.move(ChessMove.from_s('a1a5'))
      cb.move(ChessMove.from_s('a5a1'))

      moves = cb.allowed_moves_from(king_pos)
      expect(moves).not_to include(ChessMove.from_s('e1c1'))
      expect(moves.size).to eql(5)
    end

    it "doesn't allow to go on attacked cells when in check" do
      cb = Chessboard.new
      cb[ChessPosition.from_s('b3')] = King.white
      cb[ChessPosition.from_s('e3')] = Queen.white
      cb[ChessPosition.from_s('e6')] = King.black

      moves = cb.allowed_moves_from(ChessPosition.from_s('e6'))

      expect(moves.size).to eql(6)
      expect(moves).not_to include(ChessMove.from_s('e6e7'))
    end
  end

  describe '#move' do
    it 'performs kingside castling correctly' do
      result_cb = Chessboard.new
      result_cb[ChessPosition.from_s('g1')] = King.white
      result_cb[ChessPosition.from_s('f1')] = Rook.white

      cb = Chessboard.new
      cb[ChessPosition.from_s('e1')] = King.white
      cb[ChessPosition.from_s('h1')] = Rook.white
      cb.move(ChessMove.from_s('e1g1'))

      expect(cb.board_eq?(result_cb))
    end

    it 'performs queenside castling correctly' do
      result_cb = Chessboard.new
      result_cb[ChessPosition.from_s('c8')] = King.black
      result_cb[ChessPosition.from_s('d8')] = Rook.black

      cb = Chessboard.new
      cb[ChessPosition.from_s('e8')] = King.black
      cb[ChessPosition.from_s('a8')] = Rook.black
      cb.move(ChessMove.from_s('e8c8'))

      expect(cb.board_eq?(result_cb))
    end
  end
end
