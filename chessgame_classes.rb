require 'yaml'


  Diagnostic_mode = false
  Diagnostic_mode_interactive = false


# color classes

  class Black
    attr_reader :colorstring
    attr_accessor :king_coordinates, :check_condition
    def initialize
      @colorstring = "black"
    end
  end

  class White
    attr_reader :colorstring
    attr_accessor :king_coordinates, :check_condition
    def initialize
      @colorstring = "white"
    end
  end


# Piece class

  class Piece
    attr_reader :type, :color, :colorchar

    def initialize(type, color)
	@type = type
	@color = color
	if @color.colorstring == "white"
	  @colorchar = type.whitechar
	else
	  @colorchar = type.blackchar
	end
    end

  end 


# Piece type classes

  CP = 0xE2.chr + 0x99.chr

  class Pawn
    attr_reader :typestring, :whitechar, :blackchar

    def initialize
      @typestring = "pawn"
      @whitechar = CP + 0x97.chr
      @blackchar = CP + 0x9d.chr
    end
  end

  class King
    attr_reader :typestring, :whitechar, :blackchar

    def initialize
      @typestring = "king"
      @whitechar = CP + 0x94.chr
      @blackchar = CP + 0x9a.chr
    end
  end

  class Queen
    attr_reader :typestring, :whitechar, :blackchar

    def initialize
      @typestring = "queen"
      @whitechar = CP + 0x95.chr
      @blackchar = CP + 0x9b.chr
    end
  end

  class Bishop
    attr_reader :typestring, :whitechar, :blackchar

    def initialize
      @typestring = "bishop"
      @whitechar = CP + 0x99.chr
      @blackchar = CP + 0x9f.chr
    end
  end

  class Knight
    attr_reader :typestring, :whitechar, :blackchar

    def initialize
      @typestring = "knight"
      @whitechar = CP + 0x98.chr
      @blackchar = CP + 0x9e.chr
    end
  end

  class Rook
    attr_reader :typestring, :whitechar, :blackchar

    def initialize
      @typestring = "rook"
      @whitechar = CP + 0x96.chr
      @blackchar = CP + 0x9c.chr
    end
  end





class Board
  attr_accessor :square, :move_count, :error_text, :player_turn_color, :black, :white, :checkmate, :pawn, :king, :queen, :bishop, :knight, :rook

  def initialize
    @square= Array.new(9) { Array.new(9) } #squares is an 8 x 8 array of chess board squares.

    @move_count = 1
    print "initilaized @move_count= #{@move_count}\n" if Diagnostic_mode

    @checkmate = false

    @black = Black.new
    @white = White.new

    @pawn = Pawn.new
    @king = King.new
    @queen = Queen.new
    @bishop = Bishop.new
    @knight = Knight.new
    @rook = Rook.new

    @player_turn_color = white
  end


  def populate_one_color(colornow, backrow, frontrow)
      @square[1][backrow] = Piece.new(@rook, colornow)
      @square[8][backrow] = Piece.new(@rook, colornow)
      @square[2][backrow] = Piece.new(@knight, colornow)
      @square[7][backrow] = Piece.new(@knight, colornow)
      @square[3][backrow] = Piece.new(@bishop, colornow)
      @square[6][backrow] = Piece.new(@bishop, colornow)
      @square[4][backrow] = Piece.new(@queen, colornow)
      @square[5][backrow] = Piece.new(@king, colornow)
      for column in 1..8 do
        @square[column][frontrow] = Piece.new(@pawn, colornow)
      end
      colornow.king_coordinates = [5, backrow]
      colornow.check_condition = false

  end #populate_one_color

  def populate
    populate_one_color(@black, 1, 2)
    populate_one_color(@white, 8, 7)
  end #populate


  def print_board
    for row in 1..8
      for column in 1..8
	# set the background color for the square
	if (column + row) % 2 == 0
          print "\033[47m" # 'black' background
	else
	  print "\033[0m" #restore color settings to default for 'white' square
        end # if (column

	#print the piece present at the square
	if @square[column][row] == nil
	  print "  "
	else
	  print " #{@square[column][row].colorchar}"
	end # if @square
      end # for column
      print "\033[0m" #restore color settings at end of row
      print row
      print "\n"
    end # for row
    print "\033[0m" #restore color settings at end of printing board
    print " 1 2 3 4 5 6 7 8"
    print "\n"

  end # print_board

  def path_is_blocked?(start, finish)
        # determine the x direction increment
	if finish[0] - start[0] == 0
	  x_increment = 0
	elsif finish[0] - start[0] > 0
	  x_increment = 1
	else
	  x_increment = -1
	end #if finish[0] - start[0] > 0
	print "#{@square[start[0]][start[1]].type.typestring} block check x increment = #{x_increment}\n" if Diagnostic_mode

        # determine the y direction increment
	if finish[1] - start[1] == 0
	  y_increment = 0
	elsif finish[1] - start[1] > 0
	  y_increment = 1
	else
	  y_increment = -1
	end #if finish[0] - start[0] > 0
	print "#{@square[start[0]][start[1]].type.typestring} block check y increment = #{y_increment}\n" if Diagnostic_mode

      square_to_check_x = start[0] + x_increment
      square_to_check_y = start[1] + y_increment
      print "prior to loop, #{@square[start[0]][start[1]].type.typestring} block check checking square at [#{square_to_check_x},#{square_to_check_y}]\n" if Diagnostic_mode
      while square_to_check_x != finish[0] || square_to_check_y != finish[1] do
	print "#{@square[start[0]][start[1]].type.typestring} block check checking square at [#{square_to_check_x},#{square_to_check_y}]\n" if Diagnostic_mode
	if @square[square_to_check_x][square_to_check_y] != nil
	   @error_text =  "Move is not valid, #{@square[start[0]][start[1]].type.typestring} is blocked by #{@square[square_to_check_x][square_to_check_y].type.typestring}. Try again.\n"
	  print @error_text
	  return true
	else
	  print "square at [#{square_to_check_x},#{square_to_check_y}] is clear\n" if Diagnostic_mode
      	  square_to_check_x += x_increment
      	  square_to_check_y += y_increment
	  print "next square to check will be [#{square_to_check_x},#{square_to_check_y}]\n" if Diagnostic_mode
	  #return
	end #if square_to_check != nil
      end # square_to_check != finish do
      print "move is not blocked by any piece along the move path.\n" if Diagnostic_mode
      return false

  end #path_is_blocked?(start, finish)

  def diagonal_move?(start,finish)
      if (start[0] - finish[0]).abs == (start[1] - finish[1]).abs
	return true
      else 
	return false
      end
  end #diagonal_move?(start,finish)

  def add_vector(v1, v2)
    result = []
    result[0] = v1[0] + v2[0]
    result[1] = v1[1] + v2[1]
    return result
  end # def add_vector


  def move_is_not_valid?(start, finish, moves)
    moves.each do |move|
      if add_vector(move, start) == finish
        return false
      end #f add_vector(move, start) == finish
    end #moves.each do |move|
    return true
  end #move_is_not_valid?


  def capture_player_color_fail?(finish)
    # check whether piece being captured belogs to the opposite player
    if @square[finish[0]][finish[1]] != nil  && @player_turn_color == @square[finish[0]][finish[1]].color
      @error_text = "Move is not valid, attempting to capture your own piece. Try again\n"
      print @error_text
      return true
    elsif @square[finish[0]][finish[1]] != nil 
      print "captured #{@square[finish[0]][finish[1]].type.typestring}\n"
      return false
    else
      return false
    end
  end # def capture_check_fail(finish)


  def king_in_check_vert_horiz?(king_to_check_coordinates, king_to_check_color, potential_moves, pieces_to_check)

    in_check = false

    potential_moves.each do |pmove|
      stop_condition = false
      next_square_coordinates = king_to_check_coordinates
      next_square_coordinates = add_vector(king_to_check_coordinates, pmove)

      print "'check' checker looking at #{pmove} direction.\n" if Diagnostic_mode

      while ! stop_condition
        if ( !(1..8).include?(next_square_coordinates[0]) || !(1..8).include?(next_square_coordinates[1]) )
  	  print "  #{next_square_coordinates} is off the board. Stopping in this direction.\n" if Diagnostic_mode
	  stop_condition = true
        elsif @square[next_square_coordinates[0]][next_square_coordinates[1]] == nil
	  print "  square at #{next_square_coordinates} is empty, moving to next square.\n" if Diagnostic_mode
	  next_square_coordinates = add_vector(next_square_coordinates, pmove)
        else
	  #at this point a piece was found at the square to check. Now need to see whether it can capture the king
	  print "  'check' checker found a #{@square[next_square_coordinates[0]][next_square_coordinates[1]].type.typestring} at #{next_square_coordinates}.\n" if Diagnostic_mode
	  stop_condition = true
	  if king_to_check_color == @square[next_square_coordinates[0]][next_square_coordinates[1]].color
	    print "  piece at #{next_square_coordinates} is current player's own color so no check condition in this direction.\n" if Diagnostic_mode
	  else
	    print "  piece at #{next_square_coordinates} is opposite color.\n" if Diagnostic_mode

	    if pieces_to_check.include?@square[next_square_coordinates[0]][next_square_coordinates[1]].type
	      #king_to_check_color.check_condition = true
	      print "#{king_to_check_color.colorstring} king is in check!\n" if Diagnostic_mode
	      in_check = true
		# could stop here at the first check condition found, but for troubleshooting prefer to find all possible check conditions.
	    elsif @square[next_square_coordinates[0]][next_square_coordinates[1]].type == pawn
	      if (@square[next_square_coordinates[0]][next_square_coordinates[1]].color == black && next_square_coordinates[1] == king_to_check_color.king_coordinates[1] - 1) ||
		 (@square[next_square_coordinates[0]][next_square_coordinates[1]].color == white && next_square_coordinates[1] == king_to_check_color.king_coordinates[1] + 1)
	        print "#{king_to_check_color.colorstring} king is in check!\n" if Diagnostic_mode
		in_check = true
	      end #if @square[next_square_coordinates[0]][next_square_coordinates[1]].color

	    end #if [bishop, queen, king].include?

	  end #if @player_turn_color == @square
	end #if ( !(1..8).include?(n
      end #while ! stop_condition
      print "king_in_check_vert_horiz? returning in_check =#{in_check}\n" if Diagnostic_mode

    end # potential_moves.each do |pmove|

    return in_check
  end #king_in_check_vert_horiz(pieces_to_check)


  def king_is_in_check?(king_to_check_coordinates, king_to_check_color = @square[king_to_check_coordinates[0]][king_to_check_coordinates[1]].color )
    # check whether move results in a 'check' against the opponent
	# trace outward from the King in each diagonal and perpendicular direction until reaching
	# the end of the board or a piece. When a piece is found, determine if it can capture the
	# king. If yes, declare a 'check' and return.


    verticals_horizontals = [ [1,0], [-1,0], [0,1], [0,-1] ]
    diagonals = [ [1,1], [-1, 1], [-1,-1], [1,-1] ]
    knights = [ [-1,-2], [1,-2], [-2,-1], [2,-1], [-1,2], [1,2], [-2,1], [2,1] ]

    diagonal_pieces = [@bishop, @queen, @king]
    vertical_pieces = [@rook, @queen, @king]

    in_check = false

    print ">>>Starting check checker for #{king_to_check_color.colorstring} king at #{king_to_check_coordinates}\n" if Diagnostic_mode

    in_check = true if king_in_check_vert_horiz?(king_to_check_coordinates, king_to_check_color, diagonals, diagonal_pieces)
    in_check = true if king_in_check_vert_horiz?(king_to_check_coordinates, king_to_check_color, verticals_horizontals, vertical_pieces)

    knights.each do |knight_now|
      next_square_coordinates = add_vector(king_to_check_coordinates, knight_now)
      print "'check' checker knight looking at #{next_square_coordinates} position.\n" if Diagnostic_mode
      if ( (1..8).include?(next_square_coordinates[0]) && (1..8).include?(next_square_coordinates[1]) ) && 
         @square[next_square_coordinates[0]][next_square_coordinates[1]] != nil && 
         @square[next_square_coordinates[0]][next_square_coordinates[1]].type == knight && 
         @square[next_square_coordinates[0]][next_square_coordinates[1]].color != king_to_check_color
        print "found #{@square[next_square_coordinates[0]][next_square_coordinates[1]].color.colorstring} #{@square[next_square_coordinates[0]][next_square_coordinates[1]].type.typestring}\n" if Diagnostic_mode
        print "#{king_to_check_color.colorstring} king is in check!\n" if Diagnostic_mode
        #king_to_check_color.check_condition = true
        in_check = true
      end #if @square[next_square_coordinates[0]

    end #knights.each do |knight_now|

    print "  returning #{in_check} for check condition of #{king_to_check_color.colorstring} king at #{king_to_check_coordinates}.\n" if Diagnostic_mode
    return in_check
  end # def king_is_in_check?


  def restore_king_position(king_position, king_holder)
    print "restoring #{king_holder.color.colorstring} king back to the board.\n" if Diagnostic_mode
    @square[king_position[0]][king_position[1]] = king_holder
  end #restore_king_position(king_position)



  def king_is_in_checkmate?(king_to_check_coordinates)

    directions = [ [1,1], [-1, 1], [-1,-1], [1,-1], [1,0], [-1,0], [0,1], [0,-1] ]

    color_to_check = @square[king_to_check_coordinates[0]][king_to_check_coordinates[1]].color
    print "---starting checkmate checker for #{color_to_check.colorstring}.\n" if Diagnostic_mode
    print "temporarily removing #{color_to_check.colorstring} king from the board so it is not in the way during checking.\n" if Diagnostic_mode
    king_temp_holder = @square[king_to_check_coordinates[0]][king_to_check_coordinates[1]]
    @square[king_to_check_coordinates[0]][king_to_check_coordinates[1]] = nil

    directions.each do |pdirection|
      stop_condition = false
      next_square_coordinates = king_to_check_coordinates
      next_square_coordinates = add_vector(king_to_check_coordinates, pdirection)

      print "+checkmate checker looking at #{diagonal} direction.\n" if Diagnostic_mode

      while ! stop_condition
        if ( !(1..8).include?(next_square_coordinates[0]) || !(1..8).include?(next_square_coordinates[1]) )
  	  print "#{next_square_coordinates} is off the board. Stopping in this direction.\n" if Diagnostic_mode
	  stop_condition = true
        elsif @square[next_square_coordinates[0]][next_square_coordinates[1]] == nil
	  print "square at #{next_square_coordinates} is empty, checking this square.\n" if Diagnostic_mode
	    if ! king_is_in_check?(next_square_coordinates, color_to_check)
	      print "(empty space) move to #{next_square_coordinates} results in king not in check. King is not in checkmate.\n" if Diagnostic_mode
	      restore_king_position(king_to_check_coordinates, king_temp_holder)
	      return false
	    end # if ! king_is_in_check?
	  next_square_coordinates = add_vector(next_square_coordinates, pdirection)
        else
	  #at this point a piece was found at the square to check. 
	  print "checkmate checker found a #{@square[next_square_coordinates[0]][next_square_coordinates[1]].type.typestring} at #{next_square_coordinates}.\n" if Diagnostic_mode
	  stop_condition = true
	  if @square[next_square_coordinates[0]][next_square_coordinates[1]].color != color_to_check && 
	  ! king_is_in_check?(next_square_coordinates, color_to_check)
	    print "(occupied space) move to #{next_square_coordinates} results in king not in check. King is not in checkmate.\n" if Diagnostic_mode
            restore_king_position(king_to_check_coordinates, king_temp_holder)
	    return false
	  end # if ! king_is_in_check?

	end #if ( !(1..8).include?(n
      end #while ! stop_condition

    end #diagonals.each do |diagonal|



  restore_king_position(king_to_check_coordinates, king_temp_holder)
  return true
  end # def king_is_in_checkmate?



  #-------------------------------------------
  #  move
  def move(start, finish)

    print "requested move #{start} #{finish}\n"

    print "processing #{@square[start[0]][start[1]].type.typestring}\n" if @square[start[0]][start[1]] != nil  && Diagnostic_mode

    # check whether there is a piece at the start position to be moved
    if @square[start[0]][start[1]] == nil
       @error_text = "Move is not valid, no piece is at the start position. Try again.\n"
       print @error_text
       return

    # check whether piece being moved belongs to the player
    elsif @player_turn_color != @square[start[0]][start[1]].color
      @error_text = "Move is not valid, you are attempting to move your opponent's piece. Try again.\n"
      print "@player_turn_color = #{@player_turn_color},  @square[start[0]][start[1]].color = #{ @square[start[0]][start[1]].color}\n"  if Diagnostic_mode
      print @error_text
      return
    #end #f @player_turn_color != @square[start[0]][start[1]].color

    # check whether move will go off the board
    elsif ( !(1..8).include?(finish[0]) || !(1..8).include?(finish[1]) )
      @error_text = "Move is not valid, it would go off the board. Try again.\n"
      print @error_text
      return  

    # check whether start and finish are same square
    elsif start == finish
      @error_text = "Move is not valid, start and finish are same. Try again.\n"
      print @error_text
      return  

    #--------------
    #  pawn
    elsif @square[start[0]][start[1]].type == pawn
      directionsign = 1
      if @square[start[0]][start[1]].color == white
	directionsign = -1
      end #if @square[start[0]]


      print "'pawn' processing #{@square[start[0]][start[1]].type.typestring}\n" if Diagnostic_mode
      if finish[0] == start[0] && finish[1] == start[1] + 1 * directionsign #move one square forward
        print "processing move one square forward\n" if Diagnostic_mode
	if @square[finish[0]][finish[1]] != nil
	  @error_text =  "Move is not valid, there is a #{@square[finish[0]][finish[1]].type.typestring} blocking your pawn. Try again.\n"
	  print @error_text
	  return
	end #@square [finish
      elsif finish[0] == start[0] && finish[1] == start[1] + 2 * directionsign #move two squares forward
	if (@square[start[0]][start[1]].color == black && start[1] > 2) || (@square[start[0]][start[1]].color == white && start[1] < 7) 
          print "#{@square[start[0]][start[1]].color.colorstring} pawn at row #{start[1]} attempting to move 2 spaces\n"
	  @error_text = "Move is not valid. Pawn can only advance two squares on first move. Try again.\n"
	  print @error_text
	  return
	elsif @square[finish[0]][finish[1]] != nil
	  @error_text =  "Move is not valid, there is a #{@square[finish[0]][finish[1]].type.typestring} blocking your pawn. Try again.\n"
	  print errortext
	  return
	elsif @square[start[0]][start[1] + 1* directionsign] != nil
	  @error_text =  "Move is not valid, there is a #{@square[start[0]][start[1] + 1* directionsign].type.typestring} blocking your pawn. Try again.\n"
	  print @error_text
	  return
	end # if move_count > 2
      elsif finish[0] == start[0] -1 && finish[1] == start[1] + 1 * directionsign || #capture a piece left
	    finish[0] == start[0] +1 && finish[1] == start[1] + 1 * directionsign # capture a piece right
	     print "processing pawn capture a piece.\n" if Diagnostic_mode
	     if @square[finish[0]][finish[1]] == nil
		@error_text =  "Move is not valid. Pawn cannot move diagonally unless capturing a piece. Try again.\n"
	   	print @error_text
		return
	     end #if @square[finish[0]][finish[1]] == nil


            if capture_player_color_fail?(finish)
	      return
            end #if capture_player_color_fail?(finish)

	     #print "capturing #{@square[finish[0]][finish[1]].type.typestring}\n"
      elsif finish[0] != start[0]  || (finish[1] - start[1]).abs > 1
	    @error_text =  "Move is not valid, outside the range of pawn moves. Try again.\n"
	    print @error_text
	    return

      end # if finish[0] ... move one square forward


    #--------------
    #  rook
    elsif @square[start[0]][start[1]].type == rook
      print "'rook' processing #{@square[start[0]][start[1]].type.typestring}\n" if Diagnostic_mode

      if diagonal_move?(start, finish)
	@error_text =  "Move is not valid, rook cannot move diagonally. Try again.\n"
	print error_text
        return
      end #diagonal_move?(start, finish)

      if path_is_blocked?(start, finish)
	return
      end #if path_is_blocked?(start, finish)

      if capture_player_color_fail?(finish)
	return
      end #if capture_player_color_fail?(finish)


    #--------------
    #  bishop
    elsif @square[start[0]][start[1]].type == bishop
      print "'bishop' processing #{@square[start[0]][start[1]].type.typestring}\n" if Diagnostic_mode

      if ! diagonal_move?(start, finish)
	  @error_text =  "Move is not valid, attempt to move bishop non-diagonally. Try again.\n"
	  print @error_text
	  return
      end #if ! diagonal_move?(start, finish)

      if path_is_blocked?(start, finish)
	return
      end #if path_is_blocked?(start, finish)

      if capture_player_color_fail?(finish)
	return
      end #if capture_player_color_fail?(finish)


    #--------------
    #  queen or king
    elsif @square[start[0]][start[1]].type == queen || @square[start[0]][start[1]].type == king
      print "'queen or king' processing #{@square[start[0]][start[1]].type.typestring}\n" if Diagnostic_mode

      # check for non- symmetrical diagonal move
      if ! diagonal_move?(start, finish) && ! (start[0] == finish[0] || start[1] == finish[1])
	  @error_text =  "Move is not valid, attempt to move #{@square[start[0]][start[1]].type.typestring} on a non symmetrical diagonal. Try again.\n"
	  print @error_text
	  return
      end

      if path_is_blocked?(start, finish)
	return
      end #if path_is_blocked?(start, finish)


      if capture_player_color_fail?(finish)
	return
      end #if capture_player_color_fail?(finish)

      if @square[start[0]][start[1]].type == king
        @player_turn_color.king_coordinates = finish
        print "queen or king changed king position to ##{@player_turn_color.king_coordinates}.\n" if Diagnostic_mode
      end #if @square[start[0]][start[1]].type == king 

    #--------------
    #  knight
    elsif @square[start[0]][start[1]].type == knight
      print "'knight' processing #{@square[start[0]][start[1]].type.typestring}\n" if Diagnostic_mode

      # check that the destination is one of the eight possible moves
      moves = [[-2,1], [-1,2], [1,2], [2,1], [-2, -1], [-1,-2], [1,-2], [2,-1]] 

      if move_is_not_valid?(start, finish, moves)
	@error_text = "Move is not valid, it is not one of the eight possible knight moves. Try again.\n"
	print @error_text
	return
      end #move_is_not_valid?(start, finish, moves)

      if capture_player_color_fail?(finish)
	return
      end #if capture_player_color_fail?(finish)


    end  #if ! (1..)

    # for all piece types, if the move tests pass, move the piece
    print "all move tests passed, moving piece #{start} #{finish}\n" if Diagnostic_mode
    @square[finish[0]][finish[1]] = @square[start[0]][start[1]]
    @square[start[0]][start[1]] = nil


    #check for king in check
    white.check_condition = king_is_in_check?(white.king_coordinates)
    if white.check_condition
      print "white king is in check!\n" 
      if @player_turn_color == white
        print "white moved self into checkmate. Game over!\n"
	@checkmate = true
        return
      end #if @player_turn_color = white
    end #if white.check_condition

    black.check_condition = king_is_in_check?(black.king_coordinates)
    if black.check_condition
      print "black king is in check!\n" 
      if @player_turn_color == black
        print "black moved self into checkmate. Game over!\n"
	@checkmate = true
        return
      end #if @player_turn_color = white
    end #f black.check_condition

    #check for king in checkmate
    @checkmate = king_is_in_checkmate?(white.king_coordinates) if white.check_condition
    if @checkmate
      print "Checkmate against white. Game over!\n"
      true
    else
      @checkmate = king_is_in_checkmate?(black.king_coordinates) if black.check_condition
      print "Checkmate against black. Game over!\n" if @checkmate
    end





    @move_count += 1
    print "incremented @move_count to #{@move_count}\n" if Diagnostic_mode_interactive

    if @move_count % 2 == 0
	print "-- (in 'move') black's turn\n" if  Diagnostic_mode_interactive
	@player_turn_color = black
    else
	print "-- (in 'move') white's turn\n" if  Diagnostic_mode_interactive
	@player_turn_color = white
    end #if @move_count % 2 == 0



  end # move


  def save_game
    # save game must save all objects, otherwise they receive a different object id when restored
    all_to_save = [@move_count, @black, @white, @pawn, @king, @queen, @bishop, @knight, @rook, @square]
    f=File.open("save.yml", "w")
    f.write all_to_save.to_yaml
    f.close
    print "game saved.\n"
  end #save_game

  def restore_game
    begin
      print "restoring previously saved game.\n\n"
      all=YAML.load(File.open("save.yml"))
      all
    rescue
      puts "Could not restore game"
      all=[ [], [] ]
    end
  end


end # class Board


class Game

  attr_accessor :board

  def initialize
    print "\n\n\n\n\nCommand Line Chess Game\n"
    @board = Board.new

  end # initialize

  def play
    @board.populate
    @board.print_board
    print "* white's turn.\n"

    command = ""
    while command != "q"
      printf "enter command: "
      input = gets.chomp
      parts = input.split(" ")
      print "command parts: #{parts}.\n" if Diagnostic_mode_interactive
      command = parts[0]
      case command
        when 'q' then puts "Goodbye!"
        when 'h' then puts "Enter a move as 'x,y(start) x,y(end)' or s - save game, r - restore game, -f - forefeit, q - quit, h - help"
        when 's' then @board.save_game
        when 'r' then
	  all = @board.restore_game
	  @board.move_count = all[0]
	  @board.black = all[1]
	  @board.white = all[2]
          @board.pawn = all[3]
	  @board.king = all[4]
	  @board.queen = all[5]
	  @board.bishop = all[6]
	  @board.knight = all[7]
	  @board.rook = all[8]
	  @board.square = all[9]

	  @board.print_board
	  if @board.move_count % 2 == 0
	    print "** black's turn\n" #if  Diagnostic_mode
	    @board.player_turn_color = @board.black
	  else
	    print "** white's turn\n" #if  Diagnostic_mode
	    @board.player_turn_color = @board.white
	  end #if @move_count % 2 == 0

	when nil then #print "Unknown command #{command}. Use 'h' for help\n"
	when 'f' then puts "Ending game due to forefeit.\n"
        else
	  if !(1..9).include?(command[0].to_i) || input.length != 7 || input[3] != " "
            puts "Unknown command #{command}. Use 'h' for help"
	  else
	    start_coordinates = parts[0].split(",")
	    start_coordinates.collect! {|coordinate| coordinate.to_i}

	    finish_coordinates = parts[1].split(",")
	    finish_coordinates.collect! {|coordinate| coordinate.to_i}
	    @board.move(start_coordinates, finish_coordinates)
	    @board.print_board
	    if @board.checkmate
	      return
	    end #if @checkmate

	    if @board.move_count % 2 == 0
		print "* black's turn\n"
	    else
		print "* white's turn\n"
	    end #if @move_count % 2 == 0


	  end #if !(0..9)include?.command[0].to_int
        end # case
    end #while command

  end #def play

end #class Game
