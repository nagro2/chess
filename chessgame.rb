require_relative "chessgame_classes"

=begin

This is an interactive chess game creted as a Final Project in the Odin Bootcamp Ruby Programming section

The assignment:
Build a command line Chess game where two players can play against each other.
The game should be properly constrained -- it should prevent players from making illegal moves and declare check or check mate in the correct situations.
Make it so you can save the board at any time (remember how to serialize?)
Write tests for the important parts. You don't need to TDD it (unless you want to), but be sure to use RSpec tests for anything that you find yourself typing into the command line repeatedly.


Classes for chessgame.rb are in chessgame_classes.rb

=end


game = Game.new
game.play

