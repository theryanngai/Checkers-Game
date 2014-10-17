# encoding: utf-8 

class InvalidMoveError < RuntimeError
end

class Piece
	attr_accessor :king, :pos, :board, :uni_string
	attr_reader :color

	DELTAS = [[1, 1],
	[1, -1],
	[2, 2],
	[2, -2],
	[-1, 1],
	[-1, -1],
	[-2, 2],
	[-2, -2]]

	def initialize(pos, board, color = nil)
		@king = false
		@pos = pos
		@board = board
		@color = color
		@color = starting_color unless @color
	end

	def starting_color
		if (0..2).include?(@pos[0])
			return :black
		elsif (5..7).include?(@pos[0])
			return :white
		end
	end

	def valid_move?(to)
		moves.include?(to) && board[to].nil?
	end

	def make_move(to)
		@board[to], @board[@pos] = self, nil
		@pos = to
		maybe_promote
	end

	def perform_slide(to)
		if !valid_move?(to)
			raise InvalidMoveError.new "Illegal Move!"
		end

		if (to[0] - @pos[0]).abs == 2 
			raise InvalidMoveError.new "Illegal Move!"
		end 

		make_move(to)
		true
	end

	def perform_jump(to)
		unless valid_move?(to) && (to[0] - @pos[0]).abs > 1
			raise InvalidMoveError.new "Illegal Move!" 
		end

		halfway = [(@pos[0] + to[0]) / 2, (@pos[1] + to[1]) / 2]
		@board[halfway] = nil

		make_move(to)
		true
	end

	def move_diffs
		self.king ? (offsets = DELTAS) : (offsets = DELTAS[0..3])
		if @color == :white
			return offsets.map{ |offset| offset.map{ |item| item * -1 } }
		end

		offsets
	end

	def moves
		moves = []
		move_diffs.each do |offset|
			new_pos = [@pos[0] + offset[0], @pos[1] + offset[1]]

			if offset.any? { |x| x.abs == 2 }
				halfway = [(@pos[0] + new_pos[0]) / 2, (@pos[1] + new_pos[1])/ 2]
				next if @board[halfway].nil? || @board[halfway].color == @color
			end

			moves << new_pos unless new_pos.any? { |pos| !(0..7).include?(pos) }
		end
		moves
	end

	def maybe_promote
		@king = true if @color == :white && @pos[0] == 0
		@king = true if @color == :black && @pos[0] == 7
	end

	def perform_moves!(sequence)
		sequence.each do |move|
			if sequence.count == 1
				begin
					perform_slide(move) 
				rescue InvalidMoveError => e
					perform_jump(move)
				end	
			else
				perform_jump(move)
			end
		end
	end

	def perform_moves(sequence)
		if valid_move_seq?(sequence)
			perform_moves!(sequence)
		else
			raise InvalidMoveError.new "Invalid Sequence!"
		end
	end

	def valid_move_seq?(sequence)
		dup_board = @board.dup
		begin
			dup_board[@pos].perform_moves!(sequence)
		rescue
			return false
		else
			true
		end
	end
end






