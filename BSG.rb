#!/usr/local/bin/ruby

require './character.rb'
require './cards.rb'
require './tokens.rb'
require './boards.rb'


module BSG
	class BSGGame
		attr_reader :players, :currentplayer, :options, :characters, :status, :boards, :decks
	
		def initialize(args = nil)
			# Somewhere in here we want to set the game options and figure out hwo that all works
			@status = :forming
			@options = []
			@decks = Hash.new
			@tokens = Hash.new

			@players = Array.new
			addplayer(BSG::BSGPlayer.new(self))
			@currentplayer = players[0]
		end
		def addplayer(player)
			raise "Attempted to add a nonplayer" unless player.kind_of?BSG::BSGPlayer
			@players << player
		end
		def startgame
			# Populate the lists with available object
			@boards = BSG::Locations::BoardList::build()
			@decks[:skillcards] = BSG::Cards::SkillCardDecks::build()
			@decks[:crisis] = BSG::Cards::CrisisDeck::build()
			@tokens[:viperreserves] = Array.new(8,BSG::Viper.new)
			@tokens[:raptorreserves] = Array.new(4,BSG::Raptor.new)
			@characters = BSG::Characters::CharacterList::build()
			@charavailable = @characters.keys

			# Shuffle our players and let them pick their character
			@players.shuffle!
			@currentplayer = @players[0]
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
				@charavailable = @characters.keys
			end
		end
		def drawcard(args)
			req = args[:spec]
			draw = []
			args[:spec].each_pair { |drawdeck, quant|
				draw.concat(drawdeck.draw(quant))
			}
			return draw
		end
		def drawcrisis(num)
			return @decks[:crisis].draw(1)
			print "Draw request for #{num} crisis cards\n"
		end
		def docrisis(card)
			print "Performing crisis \"#{card.name}\"\n"
			print "Crisis Action \"#{card.crisis}\"\n"
			print "Cylon Activation \"#{card.activation}\"\n"
			print "Jump Status \"#{card.jump}\"\n"
		end

	end

	# BSGPlayer class should handle all communication with players as well as player specific data maybe
	class BSGPlayer
		attr_reader :hand
		def initialize(gameref)
			@game = gameref
			@character = nil
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
		def skilldraw
			drawreq = Hash.new
			@character.draw.each_pair { |k,v|
				if k.kind_of?Array
					key = ask(askprompt: 'Choose which card type to draw:', options: k)
				end
				key ||= k
				drawreq[@game.decks[:skillcards][key]] = v
			}
			@hand.concat(@game.drawcard(:deck => :skillcards, :spec => drawreq))
		end
		def movement
			choices = @game.boards.map { |i| i.locations.select { |j| j.team == :human } }.flatten!
			destination = ask(askprompt: 'Choose which location to go to:', options: choices, attr: :name)
			return @character.movement
		end
		def action
			choices = self.checktriggers(:action).map { |i| i.to_s }.concat(["Nothing"])
			ask(askprompt: 'Which action would you like to perform:', options: choices)
			return @character.action
		end
		def crisis
			@game.docrisis(@game.drawcrisis(1)[0])
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
	player.skilldraw	
	print player.movement
	print player.action
	player.crisis
}
