#!/usr/local/bin/ruby

require './actions.rb'

module BSG
module Tokens
	class Token < BSG::GameObject
		def initialize(args = {})
			args[:currentloc] ||= nil
			super
		end
		def move(args)
			@currentloc.leave(self) unless @currentloc == nil
			@currentloc = args[:destination]
			@currentloc.enter(self)
		end
		def self.build
		end
	end
	class Viper < Token
		Spec = [ :status, :currentloc ]
		TokenValues = { :ready => 8 }
		ObjectData = { :status => :ready }
	end
	class Raptor < Token
		Spec = [ :status, :currentloc ]
		TokenValues = { :ready => 4 }
		ObjectData = { :status => :ready }
	end
	class CivShip < Token
		Spec = [ :status, :currentloc ]
		TokenValues = {
			:blank => 2,
			:twopop => 2,
			:onepop => 6,
			:popmorale => 1,
			:popfuel => 1
		}
		ObjectData = { :status => :ready }
	end
	class BaseStar < Token
		Spec = [ :status, :currentloc ]
		TokenValues = { :ready => 2 }
		ObjectData = { :status => :ready }
	end
	class Raider < Token
		Spec = [ :status, :currentloc ]
		TokenValues = { :ready => 16 }
		ObjectData = { :status => :ready }
	end
	class HeavyRaider < Token
		Spec = [ :status, :currentloc ]
		TokenValues = { :ready => 2 }
		ObjectData = { :status => :ready }
	end
	class GalacticaDamage < Token
		Spec = [ :status, :location, :currentloc ]
		ObjectData = { :status => :ready }
		def initialize(location)
			super(:location => location)
		end
		def self.build
			tokens = []
			locations = [ :Armory, :HangerDeck, :Food, :Fuel, :AdmiralsQuarters, :WeaponsControl, :FTLControl, :Command ]
			locations.each { |i| tokens << self.new(i) }
			return tokens
		end
	end
end
end
