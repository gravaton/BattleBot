#!/usr/local/bin/ruby

require './character.rb'
require './cards.rb'
require './tokens.rb'
require './boards.rb'


module BSG
	class BSGGame
		attr_reader :players, :options, :characters, :status, :locations
	
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
			# Populate the lists with available object
			@locations = BSG::Locations::LocationList::build()
			@decks[:skillcards] = BSG::Cards::SkillCardDecks::build()
			@tokens[:viperreserves] = Array.new(8,BSG::Viper.new)
			@tokens[:raptorreserves] = Array.new(4,BSG::Raptor.new)
			@characters = BSG::Characters::CharacterList::build()

			# Shuffle our players and let them pick their character
			@players.shuffle!
			@charavailable = @characters.keys
			@players.each { |p|
				choosechar(p)
			}
			@status = :playing
		end
		def choosechar(playerobj)
			charlist = Array.new
			@charavailable.each { |i| charlist.concat(@characters[i]) }
			selected = playerobj.choosechar(charlist)
			@characters[selected.type].delete(selected)
			@charavailable.delete(selected.type) unless selected.type == :support
			if @charavailable == [ :support ]
				print "We've chosen one of each type, reseting\n"
				@charavailable = @characters.keys
			end
		end
		def drawcard(req)
			draw = []
			req.each_pair { |color, quant|
				print "Draw request for #{quant} #{color} cards\n"
				draw.concat(@decks[:skillcards][color].draw(quant))
			}
			return draw
		end
		def drawcrisis(num)
			print "Draw request for #{num} crisis cards\n"
		end
		def gamestart
		end

	end

	# BSGPlayer class should handle all communication with players as well as player specific data maybe
	class BSGPlayer
		attr_reader :hand
		def initialize(gameref)
			@game = gameref
			@character = nil
			@loyaltycount = [1,1]
			@loyalties = []
			@offices = []
			@hand = []
		end
		def ask(askparams)
			askparams[:attr] ||= :to_s
			print askparams[:askprompt], "\n"
			askparams[:options].each_with_index { |opt, index| print "#{(index + 1)})\t#{opt.send(askparams[:attr])}\n" }
			sel = gets.to_i
			return askparams[:options][sel - 1]
		end
		def choosechar(opts)
			selected = ask(askprompt: 'Choose your character:', options: opts, attr: :name)
			print "Selecting #{selected}\n"
			@character = selected
			return @character
		end
		def checktriggers(trigger)
			opts = Array.new
			opts.concat(@hand.select { |i| i.trigger == trigger })
			return opts
		end
		def draw
			drawreq = Hash.new
			@character.draw.each_pair { |k,v|
				if k.kind_of?Array
					key = ask(askprompt: 'Choose which card type to draw:', options: k)
				end
				key ||= k
				drawreq[key] = v
			}
			@hand.concat(@game.drawcard(drawreq))
		end
		def movement
			destination = ask(askprompt: 'Choose which location to go to:', options: @game.locations.select { |i| i.team == :human }, attr: :name)
			return @character.movement
		end
		def action
			ask(askprompt: 'Which action would you like to perform:', options: self.checktriggers(:action).map { |i| i.to_s }.concat(["Nothing"]))
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
	player.hand.each { |i| print "#{i}\n" }
	print player.movement
	print player.action
	player.crisis
}
