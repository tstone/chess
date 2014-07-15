class Piece

  def initialize(board, pos, color)
    @board = board
    @pos = pos
    @color = color
    moves
  end

  def moves
    # returns array of places piece can move to
    @moves = []
  end

  def on_board?(pos)
    (0..7).include?(pos[0]) && (0..7).include?(pos[1])
  end

  def teammate?(pos)
    @board[pos].color == @color
  end

  def enemy?(pos)
    @board[pos].color != @color
  end

  def valid_move?(pos)
    on_board?(pos) && !@board.teammate?(pos)
  end

  def kill_move?(pos)
    @board.enemy?(pos)
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
        current_move = [pos[0] + (n * DELTAS[dir][0]), pos[1] + (n * DELTAS[dir][1])]
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
end

class Rook < SlidingPiece

  def initialize(board, pos, color)
    super
  end

  def move_dirs
    [:up, :right, :down, :left]
  end
end

class Queen < SlidingPiece

  def initialize(board, pos, color)
    super
  end

  def move_dirs
    [:up, :right, :down, :left, :up_left, :up_right, :down_left, :down_right]
  end
end



class SteppingPiece < Piece

  def initalize(board, pos, color)
    super
  end

  def moves(deltas)
    moves = []

    deltas.each do |(dy, dx)|
      current_move = [pos[0] + dy, pos[1] + dx]
      break if !valid_move?(current_move)
      moves << current_move
      break if kill_move?(current_move)
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

class Pawn < SteppingPiece

  def initialize(board, pos, color)
    super
  end

  if @color == :black
    #call moves with delta of [-1, 0]
  elsif @color == :white
    #call moves with detla of [0, -1]
  end


end


class Board

  def initialize
    @board = Array.new(8) { Array.new(8) }
    create_pieces
  end


  def [](pos)
    y, x = pos[0], pos[1]
    @board[y][x]
  end

  def []=(pos, mark)
    y, x = pos[0], pos[1]
    @board[y][x] = mark
  end

  def create_pieces
    # create the pawns
    8.times do |j|
      board[1,j] = Pawn.new(self, [1,j], :white)
      board[6,j] = Pawn.new(self, [6,j], :black)
    end

    # create the rooks
    self[0,0] = Rook.new(self, [0,0], :white)
    self[0,7] = Rook.new(self, [0,7], :white)
    self[7,0] = Rook.new(self, [7,0], :black)
    self[7,7] = Rook.new(self, [7,7], :black)

    # create the knights
    self[0,1] = Knight.new(self, [0,1], :white)
    self[0,6] = Knight.new(self, [0,6], :white)
    self[7,1] = Knight.new(self, [7,1], :black)
    self[7,6] = Knight.new(self, [7,6], :black)

    # create the bishops
    self[0,2] = Bishop.new(self, [0,2], :white)
    self[0,5] = Bishop.new(self, [0,2], :white)
    self[7,2] = Bishop.new(self, [0,2], :black)
    self[7,5] = Bishop.new(self, [0,2], :black)

    # create the queens
    self[0,4] = Queen.new(self, [0,4], :white)
    self[7,4] = Queen.new(self, [7,4], :black)

    # create the kings
    self[0,3] = King.new(self, [0,3], :white)
    self[7,3] = King.new(self, [7,3], :black)
  end
end