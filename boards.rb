#!/usr/local/bin/ruby

module BSG
module Locations
	module LocationList
		def self.build(args = {})
			locations = Array.new
			loclist = BSG::Locations.constants.map { |i| BSG::Locations.const_get(i) }.select! { |i| i < GenericLocation }
			loclist.each { |locclass| locations << locclass::build() }
			return locations
		end
	end
	class GenericLocation
		LocData = {}
		Spec = [ :name, :ship, :team, :status ]
		def initialize(args = {})
			args = self.class::LocData.merge(args)
			raise "Mismatched location spec" unless self.class::Spec.sort == args.keys.sort
			args.each_pair { |key, value|
				self.instance_variable_set("@#{key.to_s}", value)
				self.instance_eval("def #{key.to_s}; return @#{key.to_s}; end")
			}
		end
		def self.build
			return self.new
		end
	end
	# Colonial One
	class PressRoom < GenericLocation
		LocData = { :name => "Press Room", :ship => "Colonial One", :team => :human, :status => :available }
	end
	class PresidentsOffice < GenericLocation
		LocData = { :name => "President's Office", :ship => "Colonial One", :team => :human, :status => :available }
	end
	class Administration < GenericLocation
		LocData = { :name => "Administration", :ship => "Colonial One", :team => :human, :status => :available }
	end

	# Galactica
	class Sickbay < GenericLocation
		LocData = { :name => "Sickbay", :ship => "Galactica", :team => :human, :status => :restricted }
	end
	class Brig < GenericLocation
		LocData = { :name => "Brig", :ship => "Galactica", :team => :human, :status => :restricted }
	end
	class Armory < GenericLocation
		LocData = { :name => "Armory", :ship => "Galactica", :team => :human, :status => :available }
	end
	class ResearchLab < GenericLocation
		LocData = { :name => "Research Lab", :ship => "Galactica", :team => :human, :status => :available }
	end
	class HangerDeck < GenericLocation
		LocData = { :name => "Hanger Deck", :ship => "Galactica", :team => :human, :status => :available }
	end
	class Communications < GenericLocation
		LocData = { :name => "Communications", :ship => "Galactica", :team => :human, :status => :available }
	end
	class AdmiralsQuarters < GenericLocation
		LocData = { :name => "Admiral's Quarters", :ship => "Galactica", :team => :human, :status => :available }
	end
	class WeaponsControl < GenericLocation
		LocData = { :name => "Weapons Control", :ship => "Galactica", :team => :human, :status => :available }
	end
	class Command < GenericLocation
		LocData = { :name => "Command", :ship => "Galactica", :team => :human, :status => :available }
	end
	class FTLControl < GenericLocation
		LocData = { :name => "FTL Control", :ship => "Galactica", :team => :human, :status => :available }
	end

	# Cylon locations
	class Caprica < GenericLocation
		LocData = { :name => "Caprica", :ship => "Cylon", :team => :cylon, :status => :available }
	end
	class CylonFleet < GenericLocation
		LocData = { :name => "Cylon Fleet", :ship => "Cylon", :team => :cylon, :status => :available }
	end
	class HumanFleet < GenericLocation
		LocData = { :name => "Human Fleet", :ship => "Cylon", :team => :cylon, :status => :available }
	end
	class ResurrectionShip < GenericLocation
		LocData = { :name => "Resurrection Ship", :ship => "Cylon", :team => :cylon, :status => :available }
	end
end
end
