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
		end
		def addplayer(player)
			@players << player
		end
		def startgame
			@tokens[:viperreserves] = Array.new(8,BSG::Viper.new)
			@tokens[:raptorreserves] = Array.new(4,BSG::Raptor.new)
			@players.shuffle!
			# Populate the character database
			@characters = BSG::Characters::CharacterList::build()
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
		def choosechar(opts = nil)
			opts ||= @game.characters.map { |v| v.name }
			name = ask(askprompt: 'Choose your character:', options: opts)
			print "Selecting #{name}\n"
			@character = (@game.characters.select { |v| v.name == name })[0]
		end
		def draw
			@game.drawcard(@character.draw)
		end
		def movement
			return @character.movement
		end
		def action
			return @character.action
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

game.startgame

game.players.each { |player|
	player.draw	
	print player.movement
	print player.action
	player.crisis
}

