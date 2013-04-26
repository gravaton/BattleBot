#!/usr/local/bin/ruby

module BSG
	module Cards
		module XO
			def self.attributes
				return { :name => "Executive Order", :color => :green, :value => 4}
			end
		end
		module IC
			def self.attributes
				return { :name => "Investigative Committee", :color => :yellow, :value => 4}
			end
		end
		module Calculations
			def self.attributes
				return { :name => "Calculations", :color => :blue, :value => 4}
			end
		end
	end
end
