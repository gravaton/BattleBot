#!/usr/local/bin/ruby

module BSG
module Locations
	class GenericLocation
		LocData = {:events => {:action => :action }}
		Spec = [ :name, :team, :status, :events ]
		def initialize(args = {})
			args = self.class::LocData.merge(args)
			raise "Mismatched location spec" unless self.class::Spec.sort == args.keys.sort
			args.each_pair { |key, value|
				self.instance_variable_set("@#{key.to_s}", value)
				self.instance_eval("def #{key.to_s}; return @#{key.to_s}; end")
			}
		end
		def action(args)
			return "Generic action handler"
		end
		def self.build
			return self.new
		end
	end
	# Colonial One
	class PressRoom < GenericLocation
		LocData = { :name => "Press Room", :team => :human, :status => :available }
	end
	class PresidentsOffice < GenericLocation
		LocData = { :name => "President's Office", :team => :human, :status => :available }
	end
	class Administration < GenericLocation
		LocData = { :name => "Administration", :team => :human, :status => :available }
	end

	# Galactica
	class Sickbay < GenericLocation
		LocData = { :name => "Sickbay", :team => :human, :status => :restricted }
	end
	class Brig < GenericLocation
		LocData = { :name => "Brig", :team => :human, :status => :restricted }
	end
	class Armory < GenericLocation
		LocData = { :name => "Armory", :team => :human, :status => :available }
	end
	class ResearchLab < GenericLocation
		LocData = { :name => "Research Lab", :team => :human, :status => :available }
	end
	class HangerDeck < GenericLocation
		LocData = { :name => "Hanger Deck", :team => :human, :status => :available }
	end
	class Communications < GenericLocation
		LocData = { :name => "Communications", :team => :human, :status => :available }
	end
	class AdmiralsQuarters < GenericLocation
		LocData = { :name => "Admiral's Quarters", :team => :human, :status => :available }
	end
	class WeaponsControl < GenericLocation
		LocData = { :name => "Weapons Control", :team => :human, :status => :available }
	end
	class Command < GenericLocation
		LocData = { :name => "Command", :team => :human, :status => :available }
	end
	class FTLControl < GenericLocation
		LocData = { :name => "FTL Control", :team => :human, :status => :available }
	end

	# Cylon locations
	class Caprica < GenericLocation
		LocData = { :name => "Caprica", :team => :cylon, :status => :available }
	end
	class CylonFleet < GenericLocation
		LocData = { :name => "Cylon Fleet", :team => :cylon, :status => :available }
	end
	class HumanFleet < GenericLocation
		LocData = { :name => "Human Fleet", :team => :cylon, :status => :available }
	end
	class ResurrectionShip < GenericLocation
		LocData = { :name => "Resurrection Ship", :team => :cylon, :status => :available }
	end

	# Space Locations
	class SpaceLocation < GenericLocation
		LocData = { :name => "Space location", :team => :space, :status => :available }
	end

	# Gameboards
	module BoardList
		def self.build(args = {})
			boards = Array.new
			loclist = BSG::Locations.constants.map { |i| BSG::Locations.const_get(i) }.select! { |i| i < GenericBoard }
			loclist.each { |locclass| boards << locclass::build() }
			return boards
		end
	end
	class GenericBoard
		BoardData = {}
		Spec = [ :name, :locations ]
		def initialize(args = {})
			args = self.class::BoardData.merge(args)
			raise "Mismatched board spec" unless self.class::Spec.sort == args.keys.sort
			args.each_pair { |key, value|
				self.instance_variable_set("@#{key.to_s}", value)
				self.instance_eval("def #{key.to_s}; return @#{key.to_s}; end")
			}
			@locations.map! { |i| BSG::Locations.const_get(i)::build() }
		end
		def self.build
			return self.new
		end
	end
	class GalacticaBoard < GenericBoard
		BoardData = { :name => "Battlestar Galactica", :locations => [:FTLControl, :Command, :WeaponsControl, :AdmiralsQuarters, :Communications, :HangerDeck, :ResearchLab, :Armory, :Brig, :Sickbay ] }
	end
	class ColonialOneBoard < GenericBoard
		BoardData = { :name => "Colonial One", :locations => [ :PressRoom, :PresidentsOffice, :Administration ] }
	end
	class CylonBoard < GenericBoard
		BoardData = { :name => "Cylon Actions", :locations => [ :Caprica, :CylonFleet, :HumanFleet, :ResurrectionShip ] }
	end
	class SpaceBoard < GenericBoard
		BoardData = { :name => "Space Locations", :locations => [ :SpaceLocation, :SpaceLocation, :SpaceLocation, :SpaceLocation, :SpaceLocation ] }
	end
end
end
