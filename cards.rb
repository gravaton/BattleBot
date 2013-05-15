#!/usr/local/bin/ruby

require './actions.rb'

module BSG
module Cards
	class Deck
		attr_reader :drawpile
		def initialize(args)
			args[:cards] ||= []

			@discardpile = Array.new
			@drawpile = Array.new
			@drawpile.concat(args[:cards])
			@drawpile.each { |i| i.homedeck = self }
		end
		def draw(count = 1)
			cards = []
			count.times do
				cards << @drawpile.shift
				self.reshuffle if @drawpile.length == 0
			end
			return cards
		end
		def view(count = 1)
			return @drawpile[0,count]
		end
		def discard(card)
			@discardpile << card
		end
		def shuffle
			@drawpile.shuffle!
		end
		def reshuffle
			@drawpile.concat(@discardpile)
			@discardpile = []
			@drawpile.shuffle!
		end
	end
	class GenericCard
		CardData = {}
		attr_accessor :homedeck
		def initialize(args = {})
			@homedeck = nil
			args = self.class::CardData.merge(args)
			raise "Mismatched card spec" unless self.class::Spec.sort == args.keys.sort
			args.each_pair { |key, value|
				self.instance_variable_set("@#{key.to_s}",value)
				self.instance_eval("def #{key.to_s}; return @#{key.to_s}; end")
			}
		end
		def gettrigger(args)
			events = Hash.new
			# Check that Trigger is Hashkind because I haven't fixed all the triggers yet
			if((defined? @trigger) and (@trigger.kind_of?Hash) and (@trigger.has_key?(args[:trigger])))
				events[self] = @trigger[args[:trigger]]
			end
			return events
		end
		def fizzle(args)
			# I suppose we can use this for "no effect" results
		end
	end

	# Loyalty Cards
	module LoyaltyDeck
		def self.build(args)
			cards = []
			args[:cylons].times do
				cards << BSG::Cards::AreCylon.new
			end
			(args[:total] + (args[:cylons] - 1)).times do
				cards << BSG::Cards::NotCylon.new
			end
			cards.shuffle!
			return BSG::Cards::Deck.new(:cards => cards)
		end
	end
	class LoyaltyCard < GenericCard
		Spec = [:name, :cylon]
	end
	class NotCylon < LoyaltyCard
		CardData = { :name => "You are not a Cylon", :cylon => false }
	end
	class AreCylon < LoyaltyCard
		Spec = [:name, :cylon, :trigger]
		CardData = {
			:name => "You are a Cylon",
			:cylon => true,
			:trigger => { :action => BSG::GameEvent.new( :text => "I am a Cylon!", :message => :reveal ) }
		}
		def reveal(args)
			print "GASP!  A Cylon!\n"
			raise BSG::ImmediateTurnEnd
		end
	end

	# Crisis Cards
	module CrisisDeck
		def self.build(cardlist = [])
			cards = Array.new
			cardlist = BSG::Cards.constants.map { |i| BSG::Cards.const_get(i) }.select! { |i| i < CrisisCard }
			cardlist.each { |cardclass|
				cards.concat(cardclass::build())
			}
			cards.shuffle!
			return BSG::Cards::Deck.new(:cards => cards)
		end
	end
	class CrisisCard < GenericCard
		Spec = [:name, :crisis, :activation, :jump]
		def crisis
			case @crisis.class
			when BSG::GameChoice
				print "Choice\n"
			when BSG::SkillCheck
				print "Skillcheck\n"
			when BSG::GameEvent
				print "Event\n"
			end
		end
		def activation
		end
		def jump
		end
		def self.build()
			return self.new
		end
	end
	class SampleCrisis < CrisisCard
		CheckSpec = {
			:positive => [ :yellow, :green, :blue ],
			:outcomes => {
				10 => BSG::GameEvent.new( :text => "No Effect", :message => :fizzle ),
				5 => BSG::GameEvent.new( :text => "-1 Food, -1 Morale", :message => :semifail),
				:fail => BSG::GameEvent.new( :text => "-4 Food", :message => :fail)
			}
		}
		ChoiceSpec = [ BSG::SkillCheck.new(CheckSpec), BSG::GameEvent.new( :text => "-2 Food", :message => :bottomchoice) ]
		CardData = {
			:name => "Generic Crisis",
			:crisis => BSG::GameChoice.new( :options => ChoiceSpec ),
			:activation => :raiders,
			:jump => true
		}
		# For now I'm going to return 10 of these cards
		def self.build()
			cards = []
			10.times { cards << self.new }
			return cards
		end
		def bottomchoice(args)
			args[:game].resource(:food => -2)
		end
		def semifail(args)
			args[:game].resource(:food => -1, :morale => -1)
		end
		def fail
			args[:game].resource(:food => -4)
		end
	end

	# Skill Cards
	module SkillCardDecks
		def self.build(cardlist = [])
			cards = Array.new
			decks = Hash.new { |h,k| h[k] = [] }
			cardlist = BSG::Cards.constants.map { |i| BSG::Cards.const_get(i) }.select! { |i| i < SkillCard }
			cardlist.each { |cardclass|
				cards << cardclass::build()
			}
			cards.flatten!
			cards.each { |card|
				decks[card.color] << card
			}
			decks.keys.each { |i| decks[i] = BSG::Cards::Deck.new(:cards => decks[i]) }
			decks.each_value { |i| i.shuffle }
			return decks
		end
	end
	class SkillCard < GenericCard
		Spec = [:name, :trigger, :color, :value]
		def initialize(val)
			super(:value => val)
		end
		def self.build()
			cards = Array.new
			self::CardValues.each_pair { |value, number|
				number.times do
					cards << self.new(value)
				end
			}
			return cards
		end
		def cardaction(args)
			print "Generic Card Action, should never be seen!\n"
		end
		def to_s
			return "[#{@value}|#{@color.to_s.upcase}] - #{@name}"
		end
	end
	class ExecutiveOrder < SkillCard
		CardValues = { 1 => 8, 2 => 6 }
		CardText = "Executive Order text goes here"
		CardData = {
			:name => "Executive Order",
			:trigger => { :action => BSG::GameEvent.new( :text => CardText, :message => :cardaction) },
			:color => :green
		}
		def cardaction(args)
			print "Executive Order!\n"
		end
	end
	class DeclareEmergency < SkillCard
		CardValues = { 5 => 1, 4 => 2, 3 => 4 }
		CardText = "Declare Emergency text goes here"
		CardData = {
			:name => "Declare Emergency",
			:trigger => { :postskillcheck => BSG::GameEvent.new( :text => CardText, :message => :cardaction) },
			:color => :green
		}
		def cardaction(args)
		end
	end
	class ConsolidatePower < SkillCard
		CardValues = { 1 => 8, 2 => 6 }
		CardText = "Consolidate Power text goes here"
		CardData = {
			:name => "Consolidate Power",
			:trigger => { :action => BSG::GameEvent.new( :text => CardText, :message => :cardaction) },
			:color => :yellow
		}
	end
	class InvestigativeCommitte < SkillCard
		CardValues = { 5 => 1, 4 => 2, 3 => 4 }
		CardText = "Investigative Committe text goes here"
		CardData = {
			:name => "Investigative Committe",
			:trigger => { :preskillcheck => BSG::GameEvent.new( :text => CardText, :message => :cardaction) },
			:color => :yellow
		}
	end
	class LaunchScout < SkillCard
		CardValues = { 1 => 8, 2 => 6 }
		CardText = "Launch Scout text goes here"
		CardData = {
			:name => "Launch Scout",
			:trigger => { :action => BSG::GameEvent.new( :text => CardText, :message => :cardaction) },
			:color => :purple
		}
	end
	class StrategicPlanning < SkillCard
		CardValues = { 5 => 1, 4 => 2, 3 => 4 }
		CardText = "Strategic Planning text goes here"
		CardData = {
			:name => "Strategic Planning",
			:trigger => { :predieroll => BSG::GameEvent.new( :text => CardText, :message => :cardaction) },
			:color => :purple
		}
	end
	class EvasiveManeuvers < SkillCard
		CardValues = { 1 => 8, 2 => 6 }
		CardText = "Evasive Maneuvers text goes here"
		CardData = {
			:name => "Evasive Maneuvers",
			:trigger => { :postviperattack => BSG::GameEvent.new( :text => CardText, :message => :cardaction) },
			:color => :red
		}
	end
	class MaximumFirepower < SkillCard
		CardValues = { 5 => 1, 4 => 2, 3 => 4 }
		CardText = "Maximum Firepower text goes here"
		CardData = {
			:name => "Maximum Firepower",
			:trigger => { :action => BSG::GameEvent.new( :text => CardText, :message => :cardaction) },
			:color => :red
		}
	end
	class Repair < SkillCard
		CardValues = { 1 => 8, 2 => 6 }
		CardText = "Repair text goes here"
		CardData = {
			:name => "Repair",
			:trigger => { :action => BSG::GameEvent.new( :text => CardText, :message => :cardaction) },
			:color => :blue
		}
	end
	class ScientificResearch < SkillCard
		CardValues = { 5 => 1, 4 => 2, 3 => 4 }
		CardText = "Scientific Research text goes here"
		CardData = {
			:name => "Scientific Research",
			:trigger => { :preskillcheck => BSG::GameEvent.new( :text => CardText, :message => :cardaction) },
			:color => :blue
		}
	end
end
end
