require_relative 'point'

class ChessPosition < Point
  # Returns nil if incorrect string
  def self.from_s(str)
    str = str.downcase

    if str =~ /^[a-h][1-8]$/
      ChessPosition.new(str[1].to_i - 1, str[0].ord - 'a'.ord)
    else
      nil
    end
  end

  # Returns nil if incorrect array
  def self.from_a(array)
    if array.size == 2 && array.all? { |e| e.between?(0, 7) }
      ChessPosition.new(array[0], array[1])
    else
      nil
    end
  end

  def self.from_i(integer)
    integer.between?(0, 63) ? ChessPosition.new(integer / 8, integer % 8) : nil
  end

  def initialize(i, j)
    raise "invalid position: #{i}, #{j}" unless i.between?(0, 7) && j.between?(0, 7)

    @i = i
    @j = j
  end

  def to_s
    "#{('a'.ord + j).chr}#{i + 1}"
  end

  def +(other)
    new_i = i + other.i
    new_j = j + other.j
    if new_i.between?(0, 7) && new_j.between?(0, 7)
      ChessPosition.new(new_i, new_j)
    else
      nil
    end
  end

  def up(by = 1)
    (i + by).between?(0, 7) ? ChessPosition.new(i + by, j) : nil
  end

  def down(by = 1)
    (i - by).between?(0, 7) ? ChessPosition.new(i - by, j) : nil
  end

  def right(by = 1)
    (j + by).between?(0, 7) ? ChessPosition.new(i, j + by) : nil
  end

  def left(by = 1)
    (j - by).between?(0, 7) ? ChessPosition.new(i, j - by) : nil
  end
end
