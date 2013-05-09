#!/usr/local/bin/ruby

require './actions.rb'
require './character.rb'
require './cards.rb'
require './tokens.rb'
require './boards.rb'


module BSG
	class BSGGame
		attr_reader :players, :currentplayer, :options, :characters, :status, :resources, :centurions, :boards, :decks
		attr_accessor :jump
	
		def initialize(args = {})
			# Somewhere in here we want to set the game options and figure out hwo that all works
			@status = :forming
			@options = {}
			# Allow for player association/signup in here, add one player by default
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
			
			# Build our lists and decks based on available objects
			@boards = BSG::Locations::BoardList::build()
			@decks[:skillcards] = BSG::Cards::SkillCardDecks::build()
			@decks[:crisis] = BSG::Cards::CrisisDeck::build()
			@characters = BSG::Characters::CharacterList::build()

			# Tokens aren't quite in order yet
			@tokens[:viperreserves] = Array.new(8,BSG::Viper.new)
			@tokens[:raptorreserves] = Array.new(4,BSG::Raptor.new)

			# Set game-wide vairables
			@jump = 0
			@centurions = [ 0,0,0,0,0 ]
			@resources = { :fuel => 8, :population => 12, :food => 10, :morale => 10 }
			@charavailable = @characters.keys

			# Shuffle our players and let them pick their character
			@players.shuffle!
			@currentplayer = @players[0]
			@players.each { |p|
				choosechar(p)
			}

			# Now the game is in progress
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
		def execute(args)
			params = {:game => self, :player => @currentplayer, :character => @currentplayer.character}.merge(args)
			return args[:target].call(params)
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
		def checktriggers(args)
			args[:player] ||= @currentplayer
			opts = Hash.new

			# Find all candidate trigger objects
			candidates = [ @currentplayer.character, @currentplayer.character.currentloc ]
			candidates.concat(@currentplayer.hand)
			candidates.concat(@currentplayer.quorumhand)
			candidates.concat(@currentplayer.loyalties)
			candidates.concat(@currentplayer.offices)
			candidates.each { |i| opts.update(execute(target: i.method(:gettrigger), trigger: args[:trigger])) }

			return opts
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
			order.each { |player| print "Pre skillcheck for #{player}\n" }
			# Destiny deck is contributed to the skill check
			# Players contribute cards to the skill check - (Could be modified to make this open)
			order.each { |player|
				contrib = ask(askprompt: 'Contribute cards to skill check:', options: player.hand, count: player.hand.length, donothing: true)
				print "Player contributed #{contrib}\n"
			}
			# Cards are shuffled, revealed and counted - (Expansions can have happenings occur here)
			# Perform any post-skill-check actions that might modify the skill check
			order.each { |player| print "Post skillcheck for #{player}\n" }
			# Execute the result of the skill check
		end
	end

	# BSGPlayer class should handle all communication with players as well as player specific data maybe
	class BSGPlayer
		attr_reader :hand, :quorumhand, :loyalties, :offices, :character
		def initialize(gameref)
			@game = gameref
			@hand = []
			@quorumhand = []
			@loyalties = []
			@offices = []
			@character = nil
		end
		def ask(askparams)
			# A fairly robust way to ask the player to select one or many things
			# This is ugly and stupid and temporary for now
			askparams[:attr] ||= :to_s
			askparams[:count] ||= 1
			askparams[:donothing] ||= false
			askparams[:nothingprompt] ||= "Complete Selection"

			selections = Array.new
			opts = askparams[:options]
			askparams[:count].times {
				print askparams[:askprompt], "\n"
				opts.each_with_index { |opt, index| print "#{(index + 1)})\t#{opt.send(askparams[:attr])}\n" }
				print "X)\t#{askparams[:nothingprompt]}\n" if askparams[:donothing]
				sel = gets.to_i - 1
				break if sel < 0
				selections << opts[sel]
				opts.delete_at(sel)
			}
			return selections
		end
		def choosechar(opts)
			selected = ask(askprompt: 'Choose your character:', options: opts, attr: :name)[0]
			print "Selecting #{selected}\n"
			@character = selected

			# Put the character in their starting location
			startloc = @game.boards.values.map { |i| i.locations.values.select { |j| j.kind_of?BSG::Locations.const_get(@character.startloc) } }.flatten[0]
			execute(:target => @character.method(:movement), :destination => startloc)

			# Perform initial draw
			dispatch(:initialdraw)
			return @character
		end
		def execute(args)
			params = {:game => @game, :player => self, :character => @character}.merge(args)
			return args[:target].call(params)
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
