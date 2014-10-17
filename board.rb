# encoding: utf-8 
require 'colorize'
require './piece.rb'

class Board
	attr_accessor :grid

	def initialize(fill = false)
		@grid = Array.new(8) { Array.new(8) }
		populate if fill
	end

	def [](pos)
		@grid[pos[0]][pos[1]]
	end

	def []=(pos, value)
		@grid[pos[0]][pos[1]] = value
	end

	def populate
		flag = true
		0.upto(2) do |row|
			flag = !flag
			0.upto(7) do |col|
				flag = !flag
				self[[row, col]] = Piece.new([row, col], self) if flag
			end
		end

		5.upto(7) do |row|
			flag = !flag
			0.upto(7) do |col|
				flag = !flag
				self[[row, col]] = Piece.new([row, col], self) if flag
			end
		end
	end

	def dup
		dup_board = Board.new

		dup_helper(:white, dup_board)
		dup_helper(:black, dup_board)

		dup_board
	end

	def dup_helper(color, board)
		self.team(color).each do |piece|
			board[piece.pos] = piece.class.new(piece.pos, board, color)
			board[piece.pos].king = true if piece.king
		end
	end

	def team(color)
		@grid.flatten.compact.select { |piece| piece.color == color }
	end

	def set_uni_string(piece)
		if piece.color == :white
			piece.uni_string = "\u26AA" 
			piece.uni_string = "\u2606" if piece.king
		else
			piece.uni_string = "\u26AB" 
			piece.uni_string = "\u2605" if piece.king
		end
	end

	def set_attributes
		(team(:black) + team(:white)).each do |piece|
			set_uni_string(piece)
		end
	end

	def display(highlight_pos)
		system("clear")
		set_attributes
		flag = true
		(0..7).each do |row|
			flag = !flag
			puts
			(0..7).each do |col|
				if [row,col] == highlight_pos
					print (" " * 2).colorize(:background => :red)
				elsif self[[row, col]].nil?
					print (" " * 2).colorize(:background => :blue) if flag
					print (" " * 2).colorize(:background => :light_green) if !flag
				else
					print (self[[row, col]].uni_string + " ").colorize(:background => :blue) if flag
					print (self[[row, col]].uni_string + " ").colorize(:background => :light_green) if !flag
				end

				flag = !flag
			end
		end
	end
end


