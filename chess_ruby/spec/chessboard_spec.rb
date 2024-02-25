require './lib/chessboard'
require './lib/chesspieces/pawn'
require './lib/chesspieces/queen'

describe Chessboard do
  describe '.default_chessboard' do
    it 'returns default chessboard' do
      cb = Chessboard.default_chessboard

      # Other chess pieces
      [[0, :white], [7, :black]].each do |row, color|
        [Rook, Knight, Bishop, Queen, King, Bishop, Knight, Rook].each_with_index do |chess_piece, column|
          expect(cb[ChessPosition.new(row, column)] == chess_piece[color])
        end
      end
    end
  end

  describe '#[]' do
    it 'returns object at position' do
      cb = Chessboard.new
      expect(cb[ChessPosition.from_s('a1')]).to eql(nil)
    end
  end

  describe '#each_chess_piece_with_pos' do
    it 'returns objects stored in cb with their positions' do
      cb = Chessboard.new
      cb[ChessPosition.from_s('e4')] = Pawn.white # any object
      cb[ChessPosition.from_s('b6')] = 7
      cb[ChessPosition.from_s('g3')] = [] # any object
      expect(cb.each_chess_piece_with_pos.count).to eql(3)
    end
  end

  describe '#each_chess_piece' do
    it 'returns objects stored in cb' do
      cb = Chessboard.new
      cb[ChessPosition.from_s('e4')] = Pawn.white # any object
      cb[ChessPosition.from_s('b6')] = 7
      cb[ChessPosition.from_s('g3')] = [] # any object
      expect(cb.each_chess_piece.count).to eql(3)
    end
  end

  describe '#find_pos' do
    it 'returns the ChessPosition of the first found chess piece' do
      cb = Chessboard.new
      cb[ChessPosition.from_s('g5')] = Pawn.white
      expect(cb.find_pos(Pawn)).to eql(ChessPosition.from_s('g5'))
    end

    it 'returns nil if not found' do
      expect(Chessboard.new.find_pos(Pawn)).to eql(nil)
    end

    it 'returns nil there is a figure of the same class but different color' do
      cb = Chessboard.new
      cb[ChessPosition.from_s('g5')] = Pawn.white
      expect(cb.find_pos(Pawn, :black)).to eql(nil)
    end
  end

  describe '#check?' do
    it 'returns true if king is under attack' do
      cb = Chessboard.new
      cb[ChessPosition.from_s('e1')] = King.white
      cb[ChessPosition.from_s('e8')] = Queen.black
      expect(cb.check?(:white)).to eql(true)
    end

    it 'returns false if king is under attack by a chess piece of the same color' do
      cb = Chessboard.new
      cb[ChessPosition.from_s('e1')] = King.white
      cb[ChessPosition.from_s('e8')] = Queen.white
      expect(cb.check?(:white)).to eql(false)
    end
  end

  describe '#==' do
    it 'returns true if two different Chessboard objects contain same chess piece pattern' do
      cb1 = Chessboard.new
      cb1[ChessPosition.from_s('e1')] = King.white
      cb1[ChessPosition.from_s('b6')] = Queen.black

      cb2 = Chessboard.new
      cb2[ChessPosition.from_s('e1')] = King.white
      cb2[ChessPosition.from_s('b6')] = Queen.black

      expect(cb1).to eq(cb2)
    end

    it 'returns false if two different Chessboard objects contain different chess piece patterns' do
      cb1 = Chessboard.new
      cb1[ChessPosition.from_s('e1')] = King.white
      cb1[ChessPosition.from_s('b6')] = Queen.white

      cb2 = Chessboard.new
      cb2[ChessPosition.from_s('e1')] = King.white
      cb2[ChessPosition.from_s('b6')] = Queen.black

      expect(cb1 == cb2).to eq(false)
    end
  end

  describe '#copy' do
    it 'returns a copy of the Chessboard object' do
      cb1 = Chessboard.new
      cb1[ChessPosition.from_s('a5')] = King.black
      cb1[ChessPosition.from_s('g2')] = Queen.white

      cb2 = cb1.clone

      expect(cb1).to eq(cb2)
    end
  end

  describe '#attack_cells_from' do
    it 'returns the same array as ChessPiece#attack_cells' do
      cb = Chessboard.new
      cpos = ChessPosition.from_s('e2')
      cb[cpos] = Pawn.white

      moves1 = cb.attack_cells_from(cpos)
      moves2 = Pawn.white.attack_cells(cpos, cb)

      expect(moves1).to eql(moves2)
    end
  end

  describe '#allowed_moves_from' do
    it 'returns the same array as ChessPiece#allowed_moves' do
      cb = Chessboard.new
      cpos = ChessPosition.from_s('e7')
      cb[cpos] = Pawn.black

      moves1 = cb.attack_cells_from(cpos)
      moves2 = Pawn.black.attack_cells(cpos, cb)

      expect(moves1).to eql(moves2)
    end
  end

  describe '#allowed_moves' do
    it 'returns all 20 moves from default chessboard' do
      moves = Chessboard.default_chessboard.allowed_moves(:white)
      chess_pieces_n = moves.map { |move| move.from }.uniq.size
      expect(chess_pieces_n).to eql(10) # 8 for pawns, 2 for knights
      expect(moves.size).to eql(20) # 16 for pawns, 4 for knights
    end

    it 'returns 6 moves' do
      cb = Chessboard.new
      cb[ChessPosition.from_s('f7')] = Pawn.white
      cb[ChessPosition.from_s('e8')] = Rook.black
      cb[ChessPosition.from_s('g8')] = Knight.black
      cb[ChessPosition.from_s('f6')] = King.white
      cb[ChessPosition.from_s('h5')] = King.black

      moves = cb.allowed_moves(:white)
      expect(moves.size).to eql(6)
    end
  end

  describe '#to_a' do
    it 'returns one dimensional array' do
      cb = Chessboard.default_chessboard
      cb.to_a.each_with_index do |cell, index|
        expect(cell == cb[ChessPosition.from_i(index)])
      end
    end
  end

  describe '#to_two_dimensional_array' do
    it 'returns one dimensional array' do
      cb = Chessboard.default_chessboard
      cb.to_two_dimensional_array.each_with_index do |row, row_index|
        row.each_with_index do |cell, column_index|
          expect(cell == cb[ChessPosition.new(row_index, column_index)])
        end
      end
    end
  end

  describe '#from_json' do
    it 'creates new chessboard from json string' do
      cb1 = Chessboard.default_chessboard
      json_string = cb1.to_json
      cb2 = Chessboard.from_json(json_string)
      expect(cb2).to eq(cb1)
    end
  end

  describe '#each_that_attacks' do
    it 'returns pieces that attack specified cell' do
      cb = Chessboard.new
      pawn1_pos = ChessPosition.from_s('d3')
      cb[pawn1_pos] = Pawn.white
      pawn2_pos = ChessPosition.from_s('c4')
      cb[pawn2_pos] = Pawn.white
      knight_pos = ChessPosition.from_s('e3')
      cb[knight_pos] = Knight.white
      bishop_pos = ChessPosition.from_s('f3')
      cb[bishop_pos] = Bishop.white
      rook_pos = ChessPosition.from_s('g5')
      cb[rook_pos] = Rook.white
      result = []
      cb.each_that_attacks(ChessPosition.from_s('d5')) { |piece, pos| result << [piece, pos] }
      expect(result).to contain_exactly([Pawn.white, pawn2_pos], [Knight.white, knight_pos], [Bishop.white, bishop_pos], [Rook.white, rook_pos])
    end
  end

  describe '#to_fen' do
    it 'returns FEN notation for start position' do
      fen = Chessboard.default_chessboard.to_fen(:white)
      expect(fen).to eql('rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1')
    end

    it "returns correct FEN string for start position with move 1.e4" do
      cb = Chessboard.default_chessboard
      cb.move(ChessMove.from_s('e2e4'))
      expect(cb.to_fen(:black)).to eql('rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq e3 0 1')
    end

    it "returns correct FEN string for moves 1.e4 c5 2.Nf3" do
      cb = Chessboard.default_chessboard

      cb.move(ChessMove.from_s('e2e4'))
      expect(cb.to_fen(:black)).to eql('rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq e3 0 1')

      cb.move(ChessMove.from_s('c7c5'))
      expect(cb.to_fen(:white)).to eql('rnbqkbnr/pp1ppppp/8/2p5/4P3/8/PPPP1PPP/RNBQKBNR w KQkq c6 0 2')

      cb.move(ChessMove.from_s('g1f3'))
      expect(cb.to_fen(:black)).to eql('rnbqkbnr/pp1ppppp/8/2p5/4P3/5N2/PPPP1PPP/RNBQKB1R b KQkq - 1 2')
    end

    it 'returns correct FEN for C00 French Defence' do
      cb = Chessboard.default_chessboard

      cb.move(ChessMove.from_s('e2e4'))
      cb.move(ChessMove.from_s('e7e6'))

      expect(cb.to_fen(:white)).to eql('rnbqkbnr/pppp1ppp/4p3/8/4P3/8/PPPP1PPP/RNBQKBNR w KQkq - 0 2')
    end

    it 'returns correct FEN for C60 Ruy Lopez' do
      cb = Chessboard.default_chessboard

      cb.move(ChessMove.from_s('e2e4'))
      cb.move(ChessMove.from_s('e7e5'))

      cb.move(ChessMove.from_s('g1f3'))
      cb.move(ChessMove.from_s('b8c6'))

      cb.move(ChessMove.from_s('f1b5'))

      expect(cb.to_fen(:black)).to eql('r1bqkbnr/pppp1ppp/2n5/1B2p3/4P3/5N2/PPPP1PPP/RNBQK2R b KQkq - 3 3')
    end

    it 'returns correct FEN for C00 French Defence' do
      cb = Chessboard.default_chessboard

      cb.move(ChessMove.from_s('e2e4'))
      cb.move(ChessMove.from_s('c7c5'))

      expect(cb.to_fen(:white)).to eql('rnbqkbnr/pp1ppppp/8/2p5/4P3/8/PPPP1PPP/RNBQKBNR w KQkq c6 0 2')
    end
  end
end
