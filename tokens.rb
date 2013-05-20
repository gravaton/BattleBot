#!/usr/local/bin/ruby

require './actions.rb'

module BSG
module Tokens
	class Token < BSG::GameObject
		def initialize(args = {})
			args[:currentloc] ||= nil
			super(args)
		end
		def move(args)
			@currentloc.leave(self) unless @currentloc == nil
			@currentloc = args[:destination]
			@currentloc.enter(self)
		end
	end
	class Viper < Token
		Spec = [ :status, :currentloc ]
		ObjectCount = 8
		ObjectData = { :status => :ready }
	end
	class Raptor < Token
		Spec = [ :status, :currentloc ]
		ObjectCount = 4
		ObjectData = { :status => :ready }
	end
	class CivShip < Token
		Spec = [ :status, :value, :currentloc ]
		ObjectCount = { :value => {
			:blank => 2,
			:twopop => 2,
			:onepop => 6,
			:popmorale => 1,
			:popfuel => 1
		}}
		ObjectData = { :status => :ready }
	end
	class BaseStar < Token
		Spec = [ :status, :currentloc ]
		ObjectCount = 2
		ObjectData = { :status => :ready }
	end
	class Raider < Token
		Spec = [ :status, :currentloc ]
		ObjectCount = 16
		ObjectData = { :status => :ready }
	end
	class HeavyRaider < Token
		Spec = [ :status, :currentloc ]
		ObjectCount = 2
		ObjectData = { :status => :ready }
	end
	class GalacticaDamage < Token
		Spec = [ :status, :value, :currentloc ]
		ObjectCount = { :value => {
			:Armory => 1,
			:HangerDeck => 1,
			:Food => 1,
			:Fuel => 1,
			:AdmiralsQuarters => 1,
			:WeaponsControl => 1,
			:FTLControl => 1,
			:Command => 1
		}}
		ObjectData = { :status => :ready }
	end
end
end
