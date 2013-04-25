#!/usr/local/bin/ruby

module BSG
	module Locations
		module HangerBay
			def self.attributes
				return { :name => "Hanger Bay", :ship => "Galactica" }
			end
		end
		module Brig
			def self.attributes
				return { :name => "Brig", :ship => "Galactica" }
			end
		end
		module FTL
			def self.attributes
				return { :name => "FTL", :ship => "Galactica" }
			end
		end
	end
end
