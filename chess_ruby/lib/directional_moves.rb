require_relative 'point'

module DirectionalMoves
  def attack_cells_directions(from, cb_grid, directions)
    directions.reduce([]) do |moves, direction|
      moves + attack_cells_direction(from, cb_grid, direction)
    end
  end

  def attack_cells_direction(from, cb_grid, direction)
    cells = []
    current_cell = from + direction

    until current_cell.nil?
      cells << current_cell
      break unless cb_grid[current_cell].nil?
      current_cell = current_cell + direction
    end

    cells
  end
end

module DiagonalMoves
  include DirectionalMoves

  @directions = [[1, 1], [1, -1], [-1, -1], [-1, 1]].map { |e| Point.from_a(e) }.freeze

  class << self
    attr_reader :directions
  end

  def attack_cells_diagonal(from, cb_grid)
    attack_cells_directions(from, cb_grid, DiagonalMoves.directions)
  end
end

module AxisAlignedMoves
  include DirectionalMoves

  @directions = [[0, 1], [0, -1], [1, 0], [-1, 0]].map { |e| Point.from_a(e) }.freeze

  class << self
    attr_reader :directions
  end

  def attack_cells_axis_aligned(from, cb_grid)
    attack_cells_directions(from, cb_grid, AxisAlignedMoves.directions)
  end
end
