require_relative "chessgame_classes"

describe "chessgame" do

  attr_accessor :x

  before(:each) do
    #print "\nstarting new test:\n"
    @x = Board.new
    @x.populate
  end

  describe 'pawn' do

    it "can move 1 square forward" do
      @x.move([3,7], [3,6]) 
      @x.square[3][6].type.typestring.should == "pawn"
    end

    it "can move 2 squares forward on first move" do
      @x.move([1,7], [1,5]) 
      @x.square[1][5].type.typestring.should == "pawn"
    end

    it "cannot move 2 squares forward after the first move" do
      @x.move([1,7], [1,6]) 
      @x.move([7,2], [7,3]) 
      @x.move([1,6], [1,4]) 
      @x.error_text.should == "Move is not valid. Pawn can only advance two squares on first move. Try again.\n"
    end

    it "cannot move > 2 squares forward" do
      @x.move([1,7], [1,3]) 
      @x.error_text.should == "Move is not valid, outside the range of pawn moves. Try again.\n"
    end

    it "cannot move forward when blocked" do
      @x.square[1][6] = @x.square[1][1]
      @x.move([1,7], [1,6]) 
      @x.error_text.should == "Move is not valid, there is a rook blocking your pawn. Try again.\n"
    end

    it "can move diagonally when capturing a piece" do
      @x.square[1][6] = @x.square[1][1]
      @x.move([2,7], [1,6]) 
      @x.square[1][6].type.typestring.should == "pawn"
    end

    it "cannot move diagonally when not capturing a piece" do
      @x.move([2,7], [1,6]) 
      @x.error_text.should == "Move is not valid. Pawn cannot move diagonally unless capturing a piece. Try again.\n"
    end

  end # describe pawn


  describe 'rook' do
    it "cannot move forward when blocked" do
      @x.move([1,8], [1,5]) 
      @x.error_text.should == "Move is not valid, rook is blocked by pawn. Try again.\n"
    end

    it "can move forward" do
      @x.square[1][7] = nil
      @x.move([1,8], [1,5]) 
      @x.square[1][5].type.typestring.should == "rook"
    end

    it "can move backwards" do
      @x.square[1][7] = nil
      @x.move([1,8], [1,5]) 
      @x.move([7,2], [7,3]) 
      @x.move([1,5], [1,6]) 
      @x.square[1][6].type.typestring.should == "rook"
    end

    it "can move sideways" do
      @x.square[1][7] = nil
      @x.move([1,8], [1,5]) 
      @x.move([7,2], [7,3]) 
      @x.move([1,5], [4,5]) 
      @x.square[4][5].type.typestring.should == "rook"
    end

    it "cannot move diagonally" do
      @x.square[1][7] = nil
      @x.move([1,8], [1,5]) 
      @x.move([7,2], [7,3]) 
      @x.move([1,5], [2,4]) 
      @x.error_text.should == "Move is not valid, rook cannot move diagonally. Try again.\n"
    end

    it "can capture a piece" do
      @x.square[1][7] = nil
      @x.square[1][6] = @x.square[2][1]
      @x.move([1,8], [1,6]) 
      @x.square[1][6].type.typestring.should == "rook"
    end


  end # describe rook

  describe 'bishop' do

    it "can move diagonally forward left" do
      @x.square[4][5] = @x.square[3][8]
      @x.move([4,5], [2,3]) 
      @x.square[2][3].type.typestring.should == "bishop"
    end

    it "can move diagonally forward right" do
      @x.square[4][5] = @x.square[3][8]
      @x.move([4,5], [6,3]) 
      @x.square[6][3].type.typestring.should == "bishop"
    end

    it "can move diagonally backward left" do
      @x.square[4][5] = @x.square[3][8]
      @x.move([4,5], [3,6]) 
      @x.square[3][6].type.typestring.should == "bishop"
    end

    it "can move diagonally forward right" do
      @x.square[4][5] = @x.square[3][8]
      @x.move([4,5], [5,6]) 
      @x.square[5][6].type.typestring.should == "bishop"
    end

    it "cannot move vertically" do
      @x.square[4][5] = @x.square[3][8]
      @x.move([4,5], [4,4]) 
      @x.error_text.should == "Move is not valid, attempt to move bishop non-diagonally. Try again.\n"
    end

    it "cannot move horizontally" do
      @x.square[4][5] = @x.square[3][8]
      @x.move([4,5], [5,5]) 
      @x.error_text.should == "Move is not valid, attempt to move bishop non-diagonally. Try again.\n"
    end

    it "cannot move along a non symmetrical diagonal" do
      @x.square[4][5] = @x.square[3][8]
      @x.move([4,5], [7,4]) 
      @x.error_text.should == "Move is not valid, attempt to move bishop non-diagonally. Try again.\n"
    end

    it "can capture a piece" do
      @x.square[6][3] = @x.square[6][2]
      @x.square[4][5] = @x.square[3][8]
      @x.move([4,5], [6,3])
      @x.square[6][3].type.typestring.should == "bishop"
    end

    it "cannot move when blocked forward-right" do
      @x.square[5][4] = @x.square[6][2]
      @x.square[4][5] = @x.square[3][8]
      @x.move([4,5], [6,3])
      @x.error_text.should == "Move is not valid, bishop is blocked by pawn. Try again.\n"
    end

    it "cannot move when blocked forward-left" do
      @x.square[3][4] = @x.square[6][2]
      @x.square[4][5] = @x.square[3][8]
      @x.move([4,5], [2,3])
      @x.error_text.should == "Move is not valid, bishop is blocked by pawn. Try again.\n"
    end

    it "cannot move when blocked backward-left" do
      @x.square[4][5] = @x.square[6][2]
      @x.square[5][4] = @x.square[3][8]
      @x.move([5,4], [3,6])
      @x.error_text.should == "Move is not valid, bishop is blocked by pawn. Try again.\n"
    end

    it "cannot move when blocked backward-right" do
      @x.square[6][5] = @x.square[6][2]
      @x.square[5][4] = @x.square[3][8]
      @x.move([5,4], [7,6])
      @x.error_text.should == "Move is not valid, bishop is blocked by pawn. Try again.\n"
    end


  end # describe bishop

  describe 'queen' do
    it "can move diagonally forward left" do
      @x.square[4][5] = @x.square[4][8]
      @x.move([4,5], [2,3]) 
      @x.square[2][3].type.typestring.should == "queen"
    end

    it "can move diagonally forward right" do
      @x.square[4][5] = @x.square[4][8]
      @x.move([4,5], [6,3]) 
      @x.square[6][3].type.typestring.should == "queen"
    end

    it "can move diagonally backward left" do
      @x.square[4][5] = @x.square[4][8]
      @x.move([4,5], [3,6]) 
      @x.square[3][6].type.typestring.should == "queen"
    end

    it "can move diagonally forward right" do
      @x.square[4][5] = @x.square[4][8]
      @x.move([4,5], [5,6]) 
      @x.square[5][6].type.typestring.should == "queen"
    end

    it "cannot move along a non symmetrical diagonal" do
      @x.square[4][5] = @x.square[4][8]
      @x.move([4,5], [7,4]) 
      @x.error_text.should == "Move is not valid, attempt to move queen on a non symmetrical diagonal. Try again.\n"
    end

    it "can capture a piece" do
      @x.square[6][3] = @x.square[6][2]
      @x.square[4][5] = @x.square[4][8]
      @x.move([4,5], [6,3])
      @x.square[6][3].type.typestring.should == "queen"
    end

    it "cannot move when blocked forward-right" do
      @x.square[5][4] = @x.square[6][2]
      @x.square[4][5] = @x.square[4][8]
      @x.move([4,5], [6,3])
      @x.error_text.should == "Move is not valid, queen is blocked by pawn. Try again.\n"
    end

    it "cannot move when blocked forward-left" do
      @x.square[3][4] = @x.square[6][2]
      @x.square[4][5] = @x.square[4][8]
      @x.move([4,5], [2,3])
      @x.error_text.should == "Move is not valid, queen is blocked by pawn. Try again.\n"
    end

    it "cannot move when blocked backward-left" do
      @x.square[4][5] = @x.square[6][2]
      @x.square[5][4] = @x.square[4][8]
      @x.move([5,4], [3,6])
      @x.error_text.should == "Move is not valid, queen is blocked by pawn. Try again.\n"
    end

    it "cannot move when blocked backward-right" do
      @x.square[6][5] = @x.square[6][2]
      @x.square[5][4] = @x.square[4][8]
      @x.move([5,4], [7,6])
      @x.error_text.should == "Move is not valid, queen is blocked by pawn. Try again.\n"
    end

    it "cannot move forward when blocked" do
      @x.move([4,8], [4,5]) 
      @x.error_text.should == "Move is not valid, queen is blocked by pawn. Try again.\n"
    end

    it "can move forward" do
      @x.square[4][7] = nil
      @x.move([4,8], [4,5]) 
      @x.square[4][5].type.typestring.should == "queen"
    end

    it "can move backwards" do
      @x.square[4][7] = nil
      @x.move([4,8], [4,5]) 
      @x.move([7,2], [7,3]) 
      @x.move([4,5], [4,6]) 
      @x.square[4][6].type.typestring.should == "queen"
    end

    it "can move sideways" do
      @x.square[4][7] = nil
      @x.move([4,8], [4,5]) 
      @x.move([7,2], [7,3]) 
      @x.move([4,5], [6,5]) 
      @x.square[6][5].type.typestring.should == "queen"
    end

  end #describe queen

  describe 'king' do
    it "can move diagonally forward left" do
      @x.square[4][5] = @x.square[5][8]
      @x.move([4,5], [2,3]) 
      @x.square[2][3].type.typestring.should == "king"
    end

    it "can move diagonally forward right" do
      @x.square[4][5] = @x.square[5][8]
      @x.move([4,5], [6,3]) 
      @x.square[6][3].type.typestring.should == "king"
    end

    it "can move diagonally backward left" do
      @x.square[4][5] = @x.square[5][8]
      @x.move([4,5], [3,6]) 
      @x.square[3][6].type.typestring.should == "king"
    end

    it "can move diagonally forward right" do
      @x.square[4][5] = @x.square[5][8]
      @x.move([4,5], [5,6]) 
      @x.square[5][6].type.typestring.should == "king"
    end

    it "cannot move along a non symmetrical diagonal" do
      @x.square[4][5] = @x.square[5][8]
      @x.move([4,5], [7,4])
      @x.error_text.should == "Move is not valid, attempt to move king on a non symmetrical diagonal. Try again.\n"
    end

    it "can capture a piece" do
      @x.square[6][3] = @x.square[6][2]
      @x.square[4][5] = @x.square[5][8]
      @x.move([4,5], [6,3])
      @x.square[6][3].type.typestring.should == "king"
    end

    it "cannot move when blocked forward-right" do
      @x.square[5][4] = @x.square[6][2]
      @x.square[4][5] = @x.square[5][8]
      @x.move([4,5], [6,3])
      @x.error_text.should == "Move is not valid, king is blocked by pawn. Try again.\n"
    end

    it "cannot move when blocked forward-left" do
      @x.square[3][4] = @x.square[6][2]
      @x.square[4][5] = @x.square[5][8]
      @x.move([4,5], [2,3])
      @x.error_text.should == "Move is not valid, king is blocked by pawn. Try again.\n"
    end

    it "cannot move when blocked backward-left" do
      @x.square[4][5] = @x.square[6][2]
      @x.square[5][4] = @x.square[5][8]
      @x.move([5,4], [3,6])
      @x.error_text.should == "Move is not valid, king is blocked by pawn. Try again.\n"
    end

    it "cannot move when blocked backward-right" do
      @x.square[6][5] = @x.square[6][2]
      @x.square[5][4] = @x.square[5][8]
      @x.move([5,4], [7,6])
      @x.error_text.should == "Move is not valid, king is blocked by pawn. Try again.\n"
    end

    it "cannot move forward when blocked" do
      @x.move([5,8], [5,5]) 
      @x.error_text.should == "Move is not valid, king is blocked by pawn. Try again.\n"
    end

    it "can move forward" do
      @x.square[5][7] = nil
      @x.move([5,8], [5,5]) 
      @x.square[5][5].type.typestring.should == "king"

    end

    it "can move backwards" do
      @x.square[5][7] = nil
      @x.move([5,8], [5,5]) 
      @x.move([7,2], [7,3]) 
      @x.move([5,5], [5,6]) 
      @x.square[5][6].type.typestring.should == "king"
    end

    it "can move sideways" do
      @x.square[5][7] = nil
      @x.move([5,8], [5,5]) 
      @x.move([7,2], [7,3]) 
      @x.move([5,5], [6,5]) 
      @x.square[6][5].type.typestring.should == "king"
    end

  end #describe king

  describe 'knight' do
    it "can move two forward, one left" do
      @x.move([7,8], [6,6])
      @x.square[6][6].type.typestring.should == "knight"
    end

    it "can move two forward, one right" do
      @x.move([7,8], [8,6])
      @x.square[8][6].type.typestring.should == "knight"
    end

    it "can move two left, one forward" do
      @x.move([7,8], [8,6])
      @x.move([1,2], [1,3])
      @x.move([8,6], [6,5])
      @x.square[6][5].type.typestring.should == "knight"
    end

    it "cannot move one forward" do
      @x.move([7,8], [8,6])
      @x.move([1,2], [1,3])
      @x.move([8,6], [8,5])
      @x.error_text.should == "Move is not valid, it is not one of the eight possible knight moves. Try again.\n"
    end

    it "cannot move one left" do

      @x.move([7,8], [8,6])
      @x.move([1,2], [1,3])
      @x.move([8,6], [7,6])
      @x.error_text.should == "Move is not valid, it is not one of the eight possible knight moves. Try again.\n"
    end

    it "can capture a piece" do
      @x.square[6][6] = @x.square[6][1]
      @x.move([7,8], [6,6])
      @x.square[6][6].type.typestring.should == "knight"
    end

  end #describe knight

  describe 'board constraints' do

    it "does not allow a move where the start position is empty" do
      @x.move([5,5], [5,4])
      @x.error_text.should == "Move is not valid, no piece is at the start position. Try again.\n"
    end

    it "does not allow a move that would go off the board" do
      @x.move([5,8], [5,9])
      @x.error_text.should == "Move is not valid, it would go off the board. Try again.\n"
    end

    it "does not allow a player to capture their own piece" do
      @x.move([8,8], [8,7])
      @x.error_text.should == "Move is not valid, attempting to capture your own piece. Try again\n"
    end

    it "does not allow a player to move out of turn" do
      @x.move([8,7], [8,6])
      @x.move([8,6], [8,5])
      @x.error_text.should == "Move is not valid, you are attempting to move your opponent's piece. Try again.\n"
    end


  end # describe board constraints

  describe 'check and checkmate checkers' do
    it "warns when a move results in a king being in check from a diagonal direction" do
      @x.square[6][4] = @x.square[5][8]
      @x.square[7][3] = @x.square[7][2]
      @x.square[4][2] = nil
      @x.white.king_coordinates = [6,4]
      @x.move([1,7], [1,6])
      @x.white.check_condition.should == true
    end

    it "warns when a move results in a king being in check from a vertical direction" do
      @x.square[6][4] = @x.square[5][8]
      @x.square[1][4] = @x.square[1][1]
      @x.square[6][6] = @x.square[4][1]
      @x.white.king_coordinates = [6,4]
      @x.move([1,7], [1,6])
      @x.white.check_condition.should == true
    end

    it "warns when a move results in a king being in check by a knight" do
      @x.square[6][4] = @x.square[5][8]
      @x.white.king_coordinates = [6,4]
      @x.square[5][6] = @x.square[2][1]
      @x.move([1,7], [1,6])
      @x.white.check_condition.should == true
    end

    it "does not give a false positive check condition" do
      @x.square[6][4] = @x.square[5][8]
      @x.square[7][3] = @x.square[7][2]
      @x.square[4][2] = nil
      @x.white.king_coordinates = [6,4]
      @x.move([1,7], [1,6])
      @x.black.check_condition.should == false
    end



    it "indicates when a move results in a checkmate" do
      @x.square[8][5] = @x.square[4][1]
      @x.square[4][1] = nil
      @x.square[5][4] = @x.square[5][2]
      @x.square[5][2] = nil
      @x.square[7][5] = @x.square[7][7]
      @x.square[7][7] = nil
      @x.square[6][3] = @x.square[6][1]
      @x.square[6][1] = nil
      @x.move([6,7], [6,6])
      @x.checkmate.should == true

    end

    it "indicates when king moves out of check from a diagonal direction" do
      @x.square[6][4] = @x.square[5][8]
      @x.square[7][3] = @x.square[7][2]
      @x.square[4][2] = nil
      @x.white.king_coordinates = [6,4]
      @x.move([1,7], [1,6])
      @x.move([1,2], [1,3])
      @x.move([6,4], [6,5])
      @x.white.check_condition.should == false
    end


  end #describe 'check and checkmate checkers'

end
