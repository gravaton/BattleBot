#!/usr/local/bin/ruby

module BSG
module Cards
	class Deck
		attr_reader :drawpile
		def initialize(args)
			@drawpile = Array.new
			@drawpile.concat(args[:cards])
			@drawpile.each { |i| i.homedeck = self }
			@discardpile = []
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
			method = Hash.new
			if( (trigs = self.instance_variable_get("@trigger")).kind_of?Hash)
				method[self] = trigs[args[:trigger]]
			end
			return method
		end
	end

	# Loyalty Cards
	module LoyaltyDeck
		def self.build(args)
			cards = []
			args[:cylons].times do
				cards << AreCylon.new
			end
			(args[:total] + (args[:cylons] - 1)).times do
				cards << NotCylon.new
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
		CardData = { :name => "You are a Cylon", :cylon => true }
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
		def self.build()
			return self.new
		end
	end
	class SampleCrisis < CrisisCard
		# For now I'm going to return 10 of these cards
		def self.build()
			return Array.new(10, self.new)
		end
		CardData = { :name => "Generic Crisis", :crisis => "Bad stuff!", :activation => :raiders, :jump => true }
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
		def to_s
			return "[#{@value}|#{@color.to_s.upcase}] - #{@name}"
		end
	end
	class ExecutiveOrder < SkillCard
		CardValues = { 1 => 8, 2 => 6 }
		CardData = { :name => "Executive Order", :trigger => { :action => :action }, :color => :green }
		def action(args)
			print "Executive Order!\n"
		end
	end
	class DeclareEmergency < SkillCard
		CardValues = { 5 => 1, 4 => 2, 3 => 4 }
		CardData = { :name => "Executive Order", :trigger => :postskillcheck, :color => :green }
	end
	class ConsolidatePower < SkillCard
		CardValues = { 1 => 8, 2 => 6 }
		CardData = { :name => "Consolidate Power", :trigger => :action, :color => :yellow }
	end
	class InvestigativeCommitte < SkillCard
		CardValues = { 5 => 1, 4 => 2, 3 => 4 }
		CardData = { :name => "Investigative Committe", :trigger => :preskillcheck, :color => :yellow }
	end
	class LaunchScout < SkillCard
		CardValues = { 1 => 8, 2 => 6 }
		CardData = { :name => "Launch Scout", :trigger => :action, :color => :purple }
	end
	class StrategicPlanning < SkillCard
		CardValues = { 5 => 1, 4 => 2, 3 => 4 }
		CardData = { :name => "Strategic Planning", :trigger => :predieroll, :color => :purple }
	end
	class EvasiveManeuvers < SkillCard
		CardValues = { 1 => 8, 2 => 6 }
		CardData = { :name => "Evasive Maneuvers", :trigger => :afterraiderfire, :color => :red }
	end
	class MaximumFirepower < SkillCard
		CardValues = { 5 => 1, 4 => 2, 3 => 4 }
		CardData = { :name => "Maximum Firepower", :trigger => :action, :color => :red }
	end
	class Repair < SkillCard
		CardValues = { 1 => 8, 2 => 6 }
		CardData = { :name => "Repair", :trigger => :action, :color => :blue }
	end
	class ScientificResearch < SkillCard
		CardValues = { 5 => 1, 4 => 2, 3 => 4 }
		CardData = { :name => "Scientific Research", :trigger => :preskillcheck, :color => :blue }
	end
end
end
