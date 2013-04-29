#!/usr/local/bin/ruby

module BSG
	class GenericToken
		TokenData = {}
		def initialize(args = {})
			args = self.class::TokenData.merge(args)
			raise "Mismatched token spec" unless self.class::Spec.sort == args.keys.sort
			args.each_pair { |key, value|
				self.instance_variable_set("@#{key.to_s}",value)
				self.instance_eval("def #{key.to_s}; return @#{key.to_s}; end")
			}
		end
	end
	class Viper < GenericToken
		Spec = [ :status ]
		TokenData = { :status => :ready }
	end
	class Raptor < GenericToken
		Spec = [ :status ]
		TokenData = { :status => :ready }
	end
	class CivShip < GenericToken
		Spec = [ :status ]
		TokenData = { :status => :ready }
	end
	class BaseStar < GenericToken
		Spec = [ :status ]
		TokenData = { :status => :ready }
	end
	class Raider < GenericToken
		Spec = [ :status ]
		TokenData = { :status => :ready }
	end
	class HeavyRaider < GenericToken
		Spec = [ :status ]
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
