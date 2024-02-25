require_relative 'chess_position'

class ChessMove
  attr_reader :from, :to, :promotion

  def self.regex
    /^[a-h][1-8][a-h][1-8][qrkb]?$/
  end

  def self.regex_without_promotion
    /^[a-h][1-8][a-h][1-8]$/
  end

  def self.valid_promotions
    [:queen, :rook, :bishop, :knight]
  end

  def self.from_s(s)
    from = ChessPosition.from_s(s[0, 2])
    to = ChessPosition.from_s(s[2, 2])
    promotion = s.size >= 5 ? ChessMove.valid_promotions.find { |e| e[0] == s[4] } : nil
    ChessMove.new(from, to, promotion)
  end

  def initialize(from, to, promotion = nil)
    @from = from
    @to = to
    @promotion = ChessMove.valid_promotions.include?(promotion) ? promotion : nil
  end

  def ==(other)
    @from == other.from && @to == other.to && @promotion == other.promotion
  end

  def eql?(other)
    self == other
  end

  def hash
    promotion_index = promotion.nil? ? 4 : ChessMove.valid_promotions.index(@promotion)
    @from.i + @from.j * 8 + @to.i * 64 + @to.j * 512 + promotion_index * 4096
  end

  def to_s
    "#{from}#{to}#{promotion.nil? ? '' : promotion.to_s[0]}"
  end
end
