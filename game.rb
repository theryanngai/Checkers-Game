require './board.rb'
require 'byebug'
require 'io/console'

class Game
	attr_accessor :board 
	
	def initialize
		@board = Board.new(true)
	end

	def play
		flag = true
		player = HumanPlayer.new(@board)

		until game_over?
			begin
				from = player.selection("choose", flag)
				p @board[from].moves
				queue = player.selection("sequence", flag)
				p queue
				@board[from].perform_moves(queue)
			rescue InvalidMoveError => e
				puts "\nIllegal Move! Please try again. (Space to continue)"
				retry if STDIN.getch == " "
			end
			flag  = !flag
		end	
	end

	def game_over?
		if @board.team(:black).count == 0 || @board.team(:white).count == 0
			return true 
		end

		false
	end

	def winner?
		return "white" if @board.team(:black).count == 0
		return "black" if @board.team(:white).count == 0
	end
end

class HumanPlayer
	attr_accessor :board

	def initialize(board)
		@board = board
	end

	def playturn
		selection("choose")
		selection("sequence")
	end

	def selection(phase, flag)
		display_pos = [3, 3]
		@board.display(display_pos)
		puts "\nWhich piece would you like to move? (WASD/Space)" if phase == "choose"
		puts "\nUse 'C' to add to sequence; Space to complete." if phase == "sequence"

		if phase == "choose"
			start = choose_helper(display_pos, flag)
			return start
		end
		
		if phase == "sequence"
			queue = queue_helper(display_pos)
			return queue 
		end
	end

	def choose_helper(display_pos, flag)
		flag ? (color = :white) : (color = :black)
		input = ''
		valid = false
		until valid
			input = STDIN.getch

			case input

			when "w"
				next if !(0..7).include?(display_pos[0] - 1)
				display_pos[0] -= 1
			when "a"
				next if !(0..7).include?(display_pos[1] - 1)
				display_pos[1] -= 1
			when "s"
				next if !(0..7).include?(display_pos[0] + 1)
				display_pos[0] += 1
			when "d"
				next if !(0..7).include?(display_pos[1] + 1)
				display_pos[1] += 1
			when "q"
				exit
			when " "
				unless @board[display_pos].nil? || @board[display_pos].color != color
					valid = true
					return display_pos 
				end
			end

			@board.display(display_pos)
			puts "\nWhite's Turn:" if color == :white
			puts "\nBlack's Turn:" if color == :black
			puts "\nWhich piece would you like to move? (WASD/Space)"
		end
	end

	def queue_helper(display_pos)
		queue = []
		input = ''
		until input == " "
			input = STDIN.getch

			case input

			when "w"
				next if !(0..7).include?(display_pos[0] - 1)
				display_pos[0] -= 1
			when "a"
				next if !(0..7).include?(display_pos[1] - 1)
				display_pos[1] -= 1
			when "s"
				next if !(0..7).include?(display_pos[0] + 1)
				display_pos[0] += 1
			when "d"
				next if !(0..7).include?(display_pos[1] + 1)
				display_pos[1] += 1
			when "c"
				queue << display_pos.dup
			when "q"
				exit
			when " "
				return 	queue
			end

			@board.display(display_pos)
			puts "\nUse 'C' to add to sequence; Space to complete."
			print "#{queue} added to sequence so far..." if !queue.empty?
		end
	end
end

g = Game.new
g.play
# board = Board.new
# # board.display([3,3])
# p1 = Piece.new([5,3], board, :white)
# p1.king = true
# p2 = Piece.new([4,4], board, :black)
# board[[5,3]] = p1
# board[[4,4]] = p2
# # board.display([3,3])
# board[[5,3]].perform_moves([[6,2]])
# p board
# p board
# board.display