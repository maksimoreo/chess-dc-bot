module Console
  def self.ask(question, *options)
    puts question
    options.each_with_index { |option, index| puts "#{index + 1}. #{option}" }

    input = 0
    until input.between?(1, options.size)
      print "[1-#{options.size}] > "
      input = gets.chomp.to_i
    end

    input - 1
  end

  def self.ask_file_name(question)
    puts question
    print '> '
    # TODO: check regex
    # TODO: check if file exists
    gets.chomp
  end

  def self.ask_color
    ask('Choose color:', 'White', 'Black') == 0 ? :white : :black
  end

  def self.print_chessboard(chessboard, cp_map = ChessPieceMaps[:chess_piece_map_unicode_reverse])
    empty = ->(i, j) { (i + j).even? ? cp_map[:empty_white] : cp_map[:empty_black]}

    puts '    ' + '_' * 18
    puts '   /' + ' ' * 18 + '\\'
    chessboard.to_two_dimensional_array.each_with_index.reverse_each do |row, row_index|
      row_string = row.each_with_index.map do |cell, column_index|
        cell.nil? ? empty.call(row_index, column_index) : cp_map[cell.color][cell.name.to_sym]
      end.join('')
      puts "#{row_index + 1} |  #{row_string}  |"
    end
    puts '   \\' + '_' * 18 + '/'
    puts "     #{(0..7).map { |j| (j + 'a'.ord).chr }.to_a.join(' ')}"
  end

  def self.print_moves(chessboard, color)
    moves = chessboard.allowed_moves(color)
    moves.keys.each do |key|
      puts "#{key}: #{moves[key].join(', ')}"
    end
  end
end

module ChessPieceMaps
  def self.[](table_name)
    raise "cannot find table: #{table_name}" unless @tables.key?(table_name)
    @tables[table_name]
  end

  @tables = {
    chess_piece_map_unicode: {
      white: { King: "\u2654 ", Queen: "\u2655 ", Rook: "\u2656 ", Bishop: "\u2657 ", Knight: "\u2658 ", Pawn: "\u2659 " },
      black: { King: "\u265a ", Queen: "\u265b ", Rook: "\u265c ", Bishop: "\u265d ", Knight: "\u265e ", Pawn: "\u265f " },
      empty_white: "\u2591" * 2,
      empty_black: '  '
    },
    chess_piece_map_unicode_reverse: {
      white: { King: "\u265a ", Queen: "\u265b ", Rook: "\u265c ", Bishop: "\u265d ", Knight: "\u265e ", Pawn: "\u265f " },
      black: { King: "\u2654 ", Queen: "\u2655 ", Rook: "\u2656 ", Bishop: "\u2657 ", Knight: "\u2658 ", Pawn: "\u2659 " },
      empty_white: "\u2591" * 2,
      empty_black: '  '
    }
  }
end
