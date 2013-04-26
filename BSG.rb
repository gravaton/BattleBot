#!/usr/local/bin/ruby

require './character.rb'
require './cards.rb'
require './tokens.rb'
require './boards.rb'


module BSG
	class BSGGame
		attr_reader :players, :options, :characters, :status
	
		def initialize(args = nil)
			# Somewhere in here we want to set the game options and figure out hwo that all works
			@status = :forming
			@players = [BSG::BSGPlayer.new(self)]
			@currentplayer = players[0]
			@options = []
			@characters = {}
			@decks = {}
			@tokens = {}
			BSG::Characters.constants.each { |i| @characters[i] = BSG::Characters.const_get(i).attributes }
		end
		def addplayer(player)
			@players << player
		end
		def startgame
			@tokens[:viperreserves] = Array.new(8,BSG::Viper.new)
			@tokens[:raptorreserves] = Array.new(4,BSG::Raptor.new)
			@players.shuffle!
			@players.each { |p|
				p.choosechar
			}
			@status = :playing
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

	# BSGPlayer class should handle all communication with players as well as player specific data maybe
	class BSGPlayer
		def initialize(gameref)
			@game = gameref
			@character = nil
			@loyaltycount = [1,1]
			@loyalties = []
			@offices = []
			@hand = []
		end
		def ask(askparams)
			print askparams[:askprompt], "\n"
			askparams[:options].each_with_index { |opt, index| print "#{(index + 1)})\t#{opt}\n" }
			sel = gets.to_i
			return askparams[:options][sel - 1]
		end
		def choosechar
			opts = @game.characters.values.map { |v| v[:name] }
			name = ask(askprompt: 'Choose your character:', options: opts)
			print "Selecting #{name}\n"
			char = (@game.characters.select { |k,v| v[:name] == name }).keys[0]
			extend BSG::Characters.const_get(char)
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

2.times do
	game.addplayer(BSG::BSGPlayer.new(game))
end

print BSG::Characters::Baltar.attributes, "\n"

game.startgame

game.players.each { |player|
	player.draw	
	print player.movement
	print player.action
	player.crisis
}

