#!/usr/local/bin/ruby

require './actions.rb'
require './character.rb'
require './cards.rb'
require './tokens.rb'
require './boards.rb'


module BSG
	class BSGGame
		attr_reader :players, :currentplayer, :options, :characters, :status, :boards, :decks
		attr_accessor :jump
	
		def initialize(args = nil)
			# Somewhere in here we want to set the game options and figure out hwo that all works
			@status = :forming
			@options = []

			@players = Array.new
			addplayer(BSG::BSGPlayer.new(self))
			@currentplayer = players[0]
		end
		def addplayer(player)
			raise "Attempted to add a nonplayer" unless player.kind_of?BSG::BSGPlayer
			@players << player
		end
		def startgame
			@decks = Hash.new
			@tokens = Hash.new
			
			# Populate the lists with available object
			@boards = BSG::Locations::BoardList::build()
			@decks[:skillcards] = BSG::Cards::SkillCardDecks::build()
			@decks[:crisis] = BSG::Cards::CrisisDeck::build()
			@tokens[:viperreserves] = Array.new(8,BSG::Viper.new)
			@tokens[:raptorreserves] = Array.new(4,BSG::Raptor.new)
			@jump = 0
			@raiders = [ 0,0,0,0,0 ]
			@resources = { :fuel => 8, :population => 12, :food => 10, :morale => 10 }
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
		def playerturn
			print "#{@currentplayer.character.name}'s Turn Begins!\n"
			@currentplayer.dispatch(:draw)
			@currentplayer.dispatch(:movement)
			@currentplayer.dispatch(:action)
			@currentplayer.dispatch(:crisis)
			@players.rotate!
			@currentplayer = players[0]
		end
		def drawcard(args)
			req = args[:spec]
			draw = []
			args[:spec].each_pair { |drawdeck, quant|
				draw.concat(drawdeck.draw(quant))
			}
			return draw
		end
		def docrisis(card)
			print "Performing crisis \"#{card.name}\"\n"
			print "Crisis Action \"#{card.crisis}\"\n"
			print "Cylon Activation \"#{card.activation}\"\n"
			dojump if card.jump
		end
		def dojump
			if((@jump += 1) == 5)
				print "Jumping!\n"
				@jump = 0
			end
		end
		def docylon(args)
			space = args[:board]
			type = args[:activation]
		end
		def doskillcheck(args)
			order = @players.rotate
			# Perform any pre-skill-check actions that might modify the skill check
			# Destiny deck is contributed to the skill check
			# Players contribute cards to the skill check - (Could be modified to make this open)
			# Cards are shuffled, revealed and counted - (Expansions can have happenings occur here)
			# Perform any post-skill-check actions that might modify the skill check
			# Execute the result of the skill check
		end
	end

	# BSGPlayer class should handle all communication with players as well as player specific data maybe
	class BSGPlayer
		attr_reader :hand, :offices, :character
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
			startloc = @game.boards.map { |i| i.locations.select { |j| j.kind_of?BSG::Locations.const_get(@character.startloc) } }.flatten[0]
			execute(:target => @character.method(:movement), :destination => startloc)
			return @character
		end
		def execute(args)
			params = {:game => @game, :player => self, :character => @character}.merge(args)
			return args[:target].call(params)
		end
		def checktriggers(trigger)
			opts = Hash.new
			@hand.each { |i| opts.update(execute( :target => i.method(:gettrigger), :trigger => trigger)) }
			opts.update(execute( :target => @character.currentloc.method(:gettrigger), :trigger => trigger))
			# Check for loyalty card abilities
			# Check for character abilities
			return opts
		end
		def dispatch(verb)
			if (@character.currentloc.status == :restricted and @character.currentloc.respond_to?verb)
				verb = @character.currentloc.method(verb)
			else
				verb = @character.method(verb)
			end
			return execute(:target => verb)
		end
	end
end
# Figure out how many players
game = BSG::BSGGame.new

2.times do
	game.addplayer(BSG::BSGPlayer.new(game))
end

game.startgame

3.times do
	game.playerturn
end
