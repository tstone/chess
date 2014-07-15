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


  def move_dirs
    [:up_left, :up_right, :down_left, :down_right]
  end
end

class Rook < SlidingPiece

  def move_dirs
    [:up, :right, :down, :left]
  end
end

class Queen < SlidingPiece

  def move_dirs
    [:up, :right, :down, :left, :up_left, :up_right, :down_left, :down_right]
  end
end



class SteppingPiece < Piece

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
  DELTAS = [[-1,-1],[-1,0],[1,1],[0,-1],[0,1],[1,-1],[1,0],[1,1]]


end

class Knight < SteppingPiece
  DELTAS = [[-2, -1],[-2, 1],[2, -1],[2, 1], [-1, -2], [-1, 2], [1, 2], [1, -2]]

end

class Pawn < SteppingPiece


  if @color == :black
    #call moves with delta of [-1, 0]
  elsif @color == :white
    #call moves with detla of [0, -1]
  end


end