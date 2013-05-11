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
				# Plance characters in initial locations
				startloc = @boards.values.map { |i| i.locations.values.select { |j| j.kind_of?BSG::Locations.const_get(p.character.startloc) } }.flatten[0]
				execute(:player => p, :target => p.character.method(:movement), :destination => startloc)
			}

			# Perform initial draw
			@players[1..-1].each { |p|
				p.dispatch(:initialdraw)
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
			args[:game] ||= self
			args[:player] ||= @currentplayer
			args[:character] ||= args[:player].character

			return args[:target].call(args)
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
			candidates = [ args[:player].character, args[:player].character.currentloc ]
			candidates.concat(args[:player].hand)
			candidates.concat(args[:player].quorumhand)
			candidates.concat(args[:player].loyalties)
			candidates.concat(args[:player].offices)
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
			print "Cylon Activation \"#{card.activation}\"\n"
			dojump if card.jump
		end
		def dojump
			print "Jump Track Increasing\n"
			if((@jump += 1) == 5)
				# Interrupt the game and perform all the Jump actions
				print "Jumping!\n"
				@jump = 0
			end
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
		def resolve(args)
			case args[:event]
			when BSG::GameEvent
				# Do a game event
				execute(:target => args[:eventtarget].method(args[:event].message))
				print "Game Event Happened!\n"
			when BSG::GameChoice
				# Ask about the choice
				print "Choice!\n#{args[:event].options}\n"
				case args[:event].targetplayer
				when :currentplayer
					args[:player] ||= @currentplayer
				else
					# The Choice targets another player - set the "player" to ask to the appropriate player
					args[:player] ||= @currentplayer
				end
				args[:event] = args[:player].ask(askprompt: 'Choose crisis option:', options: args[:event].options)[0]
				resolve(args)
				#execute(args.merge({:target => self.method(:resolve)}))
			when BSG::SkillCheck
				# Do a skill check
				print "Skill Check Happened!\n"
			end
		end
		def resource(args)
			raise "Invalid Resources" unless (args.keys - [:fuel, :food, :morale, :population]).length == 0
			args.each_pair { |k,v|
				@resources[k] += v
				print "Resource #{k} changed by #{v}\n"
				if @resources[k] < 1
					print "GAME OVER - HUMANS LOSE\n"
				end
			}

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
		def ask(args)
			# A fairly robust way to ask the player to select one or many things
			# This is ugly and stupid and temporary for now
			#args = { :attr => :to_s, :count => 1, :donothing => false, :nothingprompt => "Complete Selection" }.merge(args)
			args[:attr] ||= :to_s
			args[:count] ||= 1
			args[:donothing] ||= false
			args[:nothingprompt] ||= "Complete Selection"

			selections = Array.new
			opts = args[:options].dup
			args[:count].times {
				print args[:askprompt], "\n"
				opts.each_with_index { |opt, index| print "#{(index + 1)})\t#{opt.send(args[:attr])}\n" }
				print "X)\t#{args[:nothingprompt]}\n" if args[:donothing]
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
			return @character
		end
		def dispatch(verb)
			if (@character.currentloc.status == :restricted and @character.currentloc.respond_to?verb)
				verb = @character.currentloc.method(verb)
			else
				verb = @character.method(verb)
			end
			return @game.execute(:target => verb, :player => self)
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
