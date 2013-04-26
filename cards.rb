#!/usr/local/bin/ruby

module BSG
	class GenericCard
		CardData = {}
		def initialize(args = {})
			args = self.class::CardData.merge(args)
			raise "Mismatched card spec" unless self.class::Spec.sort == args.keys.sort
			args.each_pair { |key, value|
				self.instance_variable_set("@#{key.to_s}",value)
				self.instance_eval("def #{key.to_s}; return @#{key.to_s}; end")
			}
		end
	end

	# Loyalty Cards
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
	class CrisisCard < GenericCard
		Spec = [:name, :crisis, :activation, :jump]
	end
	class SampleCrisis < CrisisCard
		CardData = { :name => "Water Shortage", :crisis => "Bad stuff!", :activation => :raiders, :jump => true }
	end

	# Skill Cards
	class SkillCard < GenericCard
		Spec = [:name, :trigger, :color, :value]
		def initialize(val)
			super(:value => val)
		end
		def self.build
			cards = Array.new
			self::CardValues.each_pair { |value, number|
				number.times do
					cards << self.new(value)
				end
			}
			return cards
		end
	end
	class XO < SkillCard
		CardValues = { 5 => 1, 4 => 2, 3 => 1 }
		CardData = { :name => "Executive Order", :trigger => :action, :color => :green }
	end
	class IC < SkillCard
		CardValues = { 5 => 1, 4 => 2, 3 => 1 }
		CardData = { :name => "Investigative Committe", :trigger => :preskillcheck, :color => :yellow }
	end
	class Calculations < SkillCard
		CardValues = { 5 => 1, 4 => 2, 3 => 1 }
		CardData = { :name => "Calculations", :trigger => :postdieroll, :color => :blue }
	end
end

tim = BSG::XO::build
print tim[0].name, "\n"
jim = BSG::AreCylon.new
print jim.name, "\n"
