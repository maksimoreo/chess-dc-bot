require 'rmagick'
include Magick

CELL_OFFSET_X = 64
CELL_OFFSET_Y = 64
CHESSBOARD_CELL_SIZE = 64
IMAGES_DIRECTORY_NAME = 'chessboard_printer/images'
CHESSBOARD_IMAGE_FILE_NAME = 'chessboard.png'
OUTPUT_IMAGE_FILE_NAME = 'output_chessboard_temp.png'

IMAGE_FILE_NAMES = {
  white: {
    'Pawn' => 'white_pawn.png', 'Knight' => 'white_knight.png', 'Bishop' => 'white_bishop.png', 'Rook' => 'white_rook.png', 'Queen' => 'white_queen.png', 'King' => 'white_king.png'
  },
  black: {
    'Pawn' => 'black_pawn.png', 'Knight' => 'black_knight.png', 'Bishop' => 'black_bishop.png', 'Rook' => 'black_rook.png', 'Queen' => 'black_queen.png', 'King' => 'black_king.png'
  },
  chessboard: 'chessboard.png'
}

class ChessboardPrinter
  def initialize
    @images = load_images
  end

  def print(chessboard)
    put_chess_pieces_on_chessboard_image(chessboard, @images[:chessboard])
  end

  private

  def put_chess_pieces_on_chessboard_image(chessboard, cb_image)
    chessboard.each_chess_piece_with_pos do |chess_piece, pos|
      # Get chess piece image
      chess_piece_image = @images[chess_piece.color][chess_piece.class.name]

      # Put chess piece image on top of the chessboard
      x = pos.j * CHESSBOARD_CELL_SIZE + CELL_OFFSET_X
      y = (7 - pos.i) * CHESSBOARD_CELL_SIZE + CELL_OFFSET_Y
      cb_image = cb_image.composite(chess_piece_image, x, y, OverCompositeOp)
    end

    cb_image
  end

  def path_to_image(image_file_name)
    "#{IMAGES_DIRECTORY_NAME}/#{image_file_name}"
  end

  def load_images
    images = { white: {}, black: {} }

    # Load chess piece images
    %i[white black].each do |color|
      IMAGE_FILE_NAMES[color].each_pair do |chess_piece_name, file_name|
        chess_piece_image_path = path_to_image(file_name)
        images[color][chess_piece_name] = ImageList.new(chess_piece_image_path)
      end
    end

    # Load chessboard image
    images[:chessboard] = ImageList.new(path_to_image(IMAGE_FILE_NAMES[:chessboard]))

    images
  end
end
