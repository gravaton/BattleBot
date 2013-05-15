#!/usr/local/bin/ruby

module BSG
	class GenericToken
		TokenValues = {}
		TokenData = {}
		def initialize(args = {})
			args = self.class::TokenData.merge(args)
			raise "Mismatched token spec" unless self.class::Spec.sort == args.keys.sort
			args.each_pair { |key, value|
				self.instance_variable_set("@#{key.to_s}",value)
				self.instance_eval("def #{key.to_s}; return @#{key.to_s}; end")
			}
		end
		def self.build
		end
	end
	class Viper < GenericToken
		Spec = [ :status ]
		TokenValues = { :ready => 8 }
		TokenData = { :status => :ready }
	end
	class Raptor < GenericToken
		Spec = [ :status ]
		TokenValues = { :ready => 4 }
		TokenData = { :status => :ready }
	end
	class CivShip < GenericToken
		Spec = [ :status ]
		TokenValues = {
			:blank => 2,
			:twopop => 2,
			:onepop => 6,
			:popmorale => 1,
			:popfuel => 1
		}
		TokenData = { :status => :ready }
	end
	class BaseStar < GenericToken
		Spec = [ :status ]
		TokenValues = { :ready => 2 }
		TokenData = { :status => :ready }
	end
	class Raider < GenericToken
		Spec = [ :status ]
		TokenValues = { :ready => 16 }
		TokenData = { :status => :ready }
	end
	class HeavyRaider < GenericToken
		Spec = [ :status ]
		TokenValues = { :ready => 2 }
		TokenData = { :status => :ready }
	end
	class GalacticaDamage < GenericToken
		Spec = [ :status, :location ]
		Tokendata = { :status => :ready }
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
