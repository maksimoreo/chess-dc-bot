class Point
  attr_reader :i, :j

  # Returns nil if incorrect array
  def self.from_a(array)
    if array.size == 2 && array.all? { |e| e.is_a?(Integer) }
      Point.new(array[0], array[1])
    end
  end

  def initialize(i, j)
    @i = i
    @j = j
  end

  def to_a
    [i, j]
  end

  def to_h
    {i: i, j: j}
  end

  def ==(other)
    other.is_a?(ChessPosition) && i == other.i && j == other.j
  end

  def eql?(other)
    self == other
  end

  def hash
    [i, j].hash
  end

  def +(other)
    Point.new(i + other.i, j + other.j)
  end
end
