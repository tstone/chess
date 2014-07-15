class Piece

  def initialize(board, pos)
    @board = board
    @pos = pos
    moves
  end

  def moves
    # returns array of places piece can move to
    @moves = []
  end

  def on_board?(pos)
    (0..7).include?(pos[0]) && (0..7).include?(pos[1])
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
        current_move = [pos[0] + (n * DELTAS[dir][0]), pos[1] + (n * DELTAS[dir][1]])
        break if !valid_move?(current_move)
        moves << current_move
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

  def moves
  end

end

class King < SteppingPiece

end

class Knight < SteppingPiece

end

class Pawn < SteppingPiece

end