#!/usr/local/bin/ruby

require './character.rb'
require './boards.rb'


module BSG
	class BSGGame
		attr_reader :players, :options, :characters
	
		def initialize
			# Somewhere in here we want to set the game options and figure out hwo that all works
			@players = []
			@options = []
			@characters = {}
			BSG::Characters.constants.each { |i| @characters[i] = BSG::Characters.const_get(i).attributes }
		end
		def addplayer(player)
			@players << player
		end
		def drawcard(req)
			req.each_pair { |color, quant|
				print "Draw request for #{quant} #{color} cards\n"
			}
		end
		def drawcrisis(num)
			print "Draw request for #{num} crisis cards\n"
		end
		def gamestart
		end

	end

	class BSGPlayer
		def initialize(gameref)
			@game = gameref
			@character = nil
			@loyaltycount = [1,1]
			@loyalties = []
			@offices = []
			@hand = []
		end
		def choosechar
			print "Choose your character...\n"
			@game.characters.keys.each_with_index { |i,j| print j + 1, ")\t", @game.characters[i][:name], "\n"}
			print "\nSelection: \n"
			sel = gets.to_i
			sel = sel - 1
			print "Selecting #{@game.characters[@game.characters.keys[sel]][:name]}\n"
			extend BSG::Characters.const_get(@game.characters.keys[sel])
			charinit
		end
		def draw
			@game.drawcard(@draw)
		end
		def movement
			return "Default movement handler\n"
		end
		def action
			return "Default action handler\n"
		end
		def crisis
			@game.drawcrisis(1)
		end
	end
end
# Figure out how many players
game = BSG::BSGGame.new

3.times do
	game.addplayer(BSG::BSGPlayer.new(game))
end

print BSG::Characters::Baltar.attributes, "\n"

game.players.each { |player|
	player.choosechar
}
game.players.each { |player|
	player.draw	
	print player.movement
	print player.action
	player.crisis
}

