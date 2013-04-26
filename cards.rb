#!/usr/local/bin/ruby

module BSG
	class GenericCard
	end
	class SkillCard < GenericCard
		attr_reader :name, :trigger, :color, :value
		def initialize(name, trig, color, value)
			@name = name
			@trigger = trig
			@color = color
			@value = value
		end
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
			super("Executive Order", :action, :green, val)
		end
	end
	class IC < SkillCard
		def initialize(val)
			super("Investigative Committee", :preskillcheck, :yellow, val)
		end
	end
	class Calculations < SkillCard
		def initialize(val)
			super("Calculations", :postroll, :blue, val)
		end
	end
end

print BSG::XO::build
