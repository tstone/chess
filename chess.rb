# encoding: utf-8

class Piece

  attr_accessor :color, :pos

  def initialize(board, pos, color)
    @board = board
    @pos = pos
    @color = color
    @moves = []
  end

  def on_board?(pos)
    (0..7).include?(pos[0]) && (0..7).include?(pos[1])
  end

  def teammate?(pos)
    @board[pos] && (@board[pos].color == @color)
  end

  def enemy?(pos)
    @board[pos] && (@board[pos].color != @color)
  end

  def valid_move?(pos)
    on_board?(pos) && !teammate?(pos) # && !move_into_check?(pos)
  end

  def kill_move?(pos)
    enemy?(pos)
  end

  def move_into_check?(position)
    new_board = @board.dup
    new_board.move(@pos, position, check = false)

    raise "Move would leave you in check" if new_board.in_check?(@color)
  end

end

class SlidingPiece < Piece

  def initalize(board, pos, color)
    super
  end

  DELTAS = {
            up_left: [-1, -1],
            up_right: [-1, 1],
            down_left: [1, -1],
            down_right: [1, 1],
            up: [-1, 0],
            down: [1,0],
            left: [0, -1],
            right: [0, 1]
           }

  def moves(directions)
    moves = []

    directions.each do |dir|
      (1..7).each do |n|
        current_move = [@pos[0] + (n * DELTAS[dir][0]), @pos[1] + (n * DELTAS[dir][1])]
        break if !valid_move?(current_move)
        moves << current_move
        break if kill_move?(current_move)
      end
    end

    moves
  end
end

class Bishop < SlidingPiece

  def initialize(board, pos, color)
    super
  end

  def move_dirs
    [:up_left, :up_right, :down_left, :down_right]
  end

  def moves
    super(move_dirs)
  end
end

class Rook < SlidingPiece

  def initialize(board, pos, color)
    super
  end

  def move_dirs
    [:up, :right, :down, :left]
  end

  def moves
    super(move_dirs)
  end
end

class Queen < SlidingPiece

  def initialize(board, pos, color)
    super
  end

  def move_dirs
    [:up, :right, :down, :left, :up_left, :up_right, :down_left, :down_right]
  end

  def moves
    super(move_dirs)
  end
end



class SteppingPiece < Piece

  def initalize(board, pos, color)
    super
  end

  def moves
    moves = []

    self.class::DELTAS.each do |(dy, dx)|
      current_move = [@pos[0] + dy, @pos[1] + dx]
      next if !valid_move?(current_move)
      moves << current_move
      next if kill_move?(current_move)
    end

    moves
  end

end

class King < SteppingPiece

  def initialize(board, pos, color)
    super
  end

  DELTAS = [[-1,-1],[-1,0],[1,1],[0,-1],[0,1],[1,-1],[1,0],[1,1]]

end

class Knight < SteppingPiece

  def initialize(board, pos, color)
    super
  end

  DELTAS = [[-2, -1],[-2, 1],[2, -1],[2, 1], [-1, -2], [-1, 2], [1, 2], [1, -2]]

end

class Pawn < Piece

  def initialize(board, pos, color)
    super
  end

  def moves
    moves = []
    if @color == :black
      moves << [@pos[0] - 2, @pos[1]] if @pos[0] == 6
      moves << [@pos[0] - 1, @pos[1]]
    end

    if @color == :white
      moves << [@pos[0] + 2, @pos[1]] if @pos[0] == 1
      moves << [@pos[0] + 1, @pos[1]]
    end

    moves.select do |move|
      valid_move?(move)
    end

    moves += kill_moves
  end

  def kill_moves
    kill_moves = []
    if @color == :black
      left = [@pos[0] - 1, @pos[1] - 1]
      right = [@pos[0] - 1, @pos[1] + 1]
      kill_moves << left if kill_move?(left)
      kill_moves << right if kill_move?(right)
    end

    if @color == :white
      right = [@pos[0] + 1, @pos[1] - 1]
      left = [@pos[0] + 1, @pos[1] + 1]
      kill_moves << left if kill_move?(left)
      kill_moves << right if kill_move?(right)
    end

    kill_moves
  end
end


class Board

  def initialize(fresh_pieces = true)
    @board = Array.new(8) { Array.new(8) }
    create_pieces if fresh_pieces
  end


  def [](pos)
    y, x = pos
    @board[y][x]
  end

  def []=(pos, mark)
    y, x = pos
    @board[y][x] = mark
  end

  def dup
    new_board = Board.new(fresh_pieces = false)
    @board.each_with_index do |row, i|
      row.each_with_index do |tile, j|
        if tile == nil
          new_board[[i,j]] = nil
          next
        else
          new_board[[i,j]] = copy_piece(new_board, tile)
        end
      end
    end

    new_board
  end

  def copy_piece(board, piece)
    class_name = piece.class
    position = piece.pos
    color = piece.color

    class_name.new(board, position, color)
  end

  def create_pieces
    # create the pawns
    8.times do |j|
      self[[1,j]] = Pawn.new(self, [1,j], :white)
      self[[6,j]] = Pawn.new(self, [6,j], :black)
    end

    # create the rooks
    self[[0,0]] = Rook.new(self, [0,0], :white)
    self[[0,7]] = Rook.new(self, [0,7], :white)
    self[[7,0]] = Rook.new(self, [7,0], :black)
    self[[7,7]] = Rook.new(self, [7,7], :black)

    # create the knights
    self[[0,1]] = Knight.new(self, [0,1], :white)
    self[[0,6]] = Knight.new(self, [0,6], :white)
    self[[7,1]] = Knight.new(self, [7,1], :black)
    self[[7,6]] = Knight.new(self, [7,6], :black)

    # create the bishops
    self[[0,2]] = Bishop.new(self, [0,2], :white)
    self[[0,5]] = Bishop.new(self, [0,2], :white)
    self[[7,2]] = Bishop.new(self, [0,2], :black)
    self[[7,5]] = Bishop.new(self, [0,2], :black)

    # create the queens
    self[[0,4]] = Queen.new(self, [0,4], :white)
    self[[7,4]] = Queen.new(self, [7,4], :black)

    # create the kings
    self[[0,3]] = King.new(self, [0,3], :white)
    self[[7,3]] = King.new(self, [7,3], :black)
  end

  def in_check?(enemy_color)
    enemy_king = @board.flatten.select do |piece|
       piece.class == "King" && piece.color == enemy_color
    end

    team_color = (enemy_color == :black) ? :white : :black

    all_team_moves(team_color).include?(enemy_king.pos)

  end

  def all_team_moves(team_color)
    all_moves = []
    pieces = board.flatten.select { |piece| piece.color == team_color }

    pieces.each do |piece|
      all_moves += piece.moves
    end

    all_moves
  end

  def checkmate?
    pieces = board.flatten.select { |piece| piece.color == team_color }

    pieces.each do |piece|
      return false if piece.moves.any? {|move| !piece.move_into_check?(move)}
    end

    true
  end

  def move(start, end_pos, check = true)
    piece = self[start]
    if !piece
      raise "No piece at start position"
    end

    begin
      piece.move_into_check?(end_pos) if check
    rescue
      "Caught move into check exception"

    end

    if piece.moves.include?(end_pos)
      self[end_pos] = piece
      self[start] = nil
      piece.pos = end_pos
    else
      raise "End position not valid"
    end

  end

  # def checkmate?
  #   if in_check?(:black) && all_team_moves(:black).empty?
  #     return true
  #   end
  #
  #   if in_check?(:white) && all_team_moves(:white).empty?
  #     return true
  #   end
  #
  #   false
  # end


  def print_board
    white_unicode_map = {
                         "King" => "♔",
                         "Queen" => "♕",
                         "Rook" => "♖",
                         "Bishop" => "♗",
                         "Knight" => "♘",
                         "Pawn" => "♙"
                         }
    black_unicode_map = {
                        "King" => "♚",
                        "Queen" => "♛",
                        "Rook" => "♜",
                        "Bishop" => "♝",
                        "Knight" => "♞",
                        "Pawn" => "♟"
                        }

    puts ""
    puts "              ┌───┬───┬───┬───┬───┬───┬───┬───┐"
    n = 8
    @board.each do |row|
      row_string = "            #{n} │ "
      row.each do |piece|
        row_string += "  │ " if piece.nil?
        next if piece.nil?
        row_string += black_unicode_map[piece.class.to_s] if piece.color == :black
        row_string += white_unicode_map[piece.class.to_s] if piece.color == :white
        row_string += " │ "
      end
      puts row_string
      break if n == 1
      n = n - 1
      puts "              ├───┼───┼───┼───┼───┼───┼───┼───┤"
    end
            puts "              └───┴───┴───┴───┴───┴───┴───┴───┘"
            puts "                a   b   c   d   e   f   g   h  "
  end
end


if $PROGRAM_NAME == __FILE__

  b = Board.new
  b.print_board
  b.move([1,1],[2,1])
  b.print_board

end