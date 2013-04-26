#!/usr/local/bin/ruby

module BSG
	class GenericCard
		def initialize(args)
			raise "Mismatched card spec" unless self.class::Spec == args.keys
			args.each_pair { |key, value|
				self.instance_variable_set("@#{key.to_s}",value)
				self.instance_eval("def #{key.to_s}; return @#{key.to_s}; end")
			}
		end
	end
	class LoyaltyCard < GenericCard
		attr_reader :name, :cylon
		def initialize
		end
	end
	class NotCylon < LoyaltyCard
	end
	class AreCylon < LoyaltyCard
	end
	class CrisisCard < GenericCard
	end
	class SkillCard < GenericCard
		Spec = [:name, :trigger, :color, :value]
		def self.build
			cards = []
			self::Values.each_pair { |value, number|
				number.times do
					cards << self.new(value)
				end
			}
			return cards
		end
	end
	class XO < SkillCard
		Values = { 5 => 1, 4 => 2, 3 => 1 }
		def initialize(val)
			super(:name => "Executive Order", :trigger => :action, :color => :green, :value => val)
		end
	end
	class IC < SkillCard
		def initialize(val)
			super(:name => "Investigative Committee", :trigger => :preskillcheck, :color => :yellow, :value => val)
		end
	end
	class Calculations < SkillCard
		def initialize(val)
			super(:name => "Calculations", :trigger => :postroll, :color => :blue, :value => val)
		end
	end
end

tim = BSG::XO::build
print tim[0].name, "\n"
