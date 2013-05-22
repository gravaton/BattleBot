#!/usr/local/bin/ruby

require './actions.rb'

module BSG
module Locations
	class GenericLocation < BSG::GameObject
		ObjectData = { :trigger => { :action => :action } }
		Spec = [ :name, :team, :status, :trigger, :contents ]
		def initialize(args = {})
			args[:contents] ||= Array.new
			super(args)
		end
		def enter(item)
			@contents << item
		end
		def leave(item)
			@contents.delete(item)
		end
		def action(args)
			print "#{self.class}::action has been called\n"
		end
		def gettrigger(args)
			return {} if @status == :damaged
			return super(args)
		end
		def to_s
			return "LOCATION - #{@name}"
		end
	end
	# Colonial One
	class PressRoom < GenericLocation
		ObjectData = ObjectData.merge({ :name => "Press Room", :team => :human, :status => :available })
	end
	class PresidentsOffice < GenericLocation
		ObjectData = ObjectData.merge({ :name => "President's Office", :team => :human, :status => :available })
	end
	class Administration < GenericLocation
		ObjectData = ObjectData.merge({ :name => "Administration", :team => :human, :status => :available })
	end

	# Galactica
	class Sickbay < GenericLocation
		ObjectData = { :name => "Sickbay", :team => :human, :status => :restricted, :trigger => { :draw => :sickdraw } }
		def draw
			print "Draw only one card because you're in Sick Bay!\n"
		end
	end
	class Brig < GenericLocation
		ObjectData = ObjectData.merge({ :name => "Brig", :team => :human, :status => :available })
		def crisis
			print "Don't do a Crisis because you're in the Brig!\n"
		end
	end
	class Armory < GenericLocation
		ObjectData = ObjectData.merge({ :name => "Armory", :team => :human, :status => :available })
	end
	class ResearchLab < GenericLocation
		ObjectData = ObjectData.merge({ :name => "Research Lab", :team => :human, :status => :available })
	end
	class HangerDeck < GenericLocation
		ObjectData = ObjectData.merge({ :name => "Hanger Deck", :team => :human, :status => :available })
	end
	class Communications < GenericLocation
		ObjectData = ObjectData.merge({ :name => "Communications", :team => :human, :status => :available })
	end
	class AdmiralsQuarters < GenericLocation
		ObjectData = ObjectData.merge({ :name => "Admiral's Quarters", :team => :human, :status => :available })
	end
	class WeaponsControl < GenericLocation
		ObjectData = ObjectData.merge({ :name => "Weapons Control", :team => :human, :status => :available })
	end
	class Command < GenericLocation
		ObjectData = ObjectData.merge({ :name => "Command", :team => :human, :status => :available })
	end
	class FTLControl < GenericLocation
		ObjectData = ObjectData.merge({ :name => "FTL Control", :team => :human, :status => :available })
		def gettrigger(args)
			return {} if args[:game].jumptrack < 3
			return super(args)
		end
	end

	# Cylon locations
	class Caprica < GenericLocation
		ObjectData = ObjectData.merge({ :name => "Caprica", :team => :cylon, :status => :available })
	end
	class CylonFleet < GenericLocation
		ObjectData = ObjectData.merge({ :name => "Cylon Fleet", :team => :cylon, :status => :available })
	end
	class HumanFleet < GenericLocation
		ObjectData = ObjectData.merge({ :name => "Human Fleet", :team => :cylon, :status => :available })
	end
	class ResurrectionShip < GenericLocation
		ObjectData = ObjectData.merge({ :name => "Resurrection Ship", :team => :cylon, :status => :available })
	end

	# Space Locations
	class SpaceLocation < GenericLocation
		ObjectData = ObjectData.merge({ :name => "Space location", :team => :space, :status => :available })
	end

	# Gameboards
	module BoardList
		def self.build(args = {})
			boards = Hash.new
			args[:loclist] ||= BSG::Locations.constants.map { |i| BSG::Locations.const_get(i) }.select! { |i| i < GenericBoard }
			args[:loclist].each { |locclass| boards[locclass::ObjectData[:name]] = locclass::build() }
			return boards
		end
	end
	class GenericBoard < BSG::GameObject
		Spec = [ :name, :description, :locations ]
		def initialize(args = {})
			super(args)
			# If it's an array of classnames we'll presume the name should be the same as the classname
			@locations = Hash[@locations.map { |i| [i,i] }] if @locations.kind_of?Array
			@locations.each_pair { |k,v| @locations[k] = BSG::Locations.const_get(v)::build() }
		end
	end
	class GalacticaBoard < GenericBoard
		ObjectData = { :name => :BSG, :description => "Battlestar Galactica", :locations => [:FTLControl, :Command, :WeaponsControl, :AdmiralsQuarters, :Communications, :HangerDeck, :ResearchLab, :Armory, :Brig, :Sickbay ] }
	end
	class ColonialOneBoard < GenericBoard
		ObjectData = { :name => :ColonialOne, :description => "Colonial One", :locations => [ :PressRoom, :PresidentsOffice, :Administration ] }
	end
	class CylonBoard < GenericBoard
		ObjectData = { :name => :Cylon, :description => "Cylon Actions", :locations => [ :Caprica, :CylonFleet, :HumanFleet, :ResurrectionShip ] }
	end
	class SpaceBoard < GenericBoard
		ObjectData = { :name => :Space, :description => "Space Locations", :locations => {
			:SpaceFront => :SpaceLocation,
			:SpaceTopLeft => :SpaceLocation,
			:SpaceTopRight => :SpaceLocation,
			:SpaceBack => :SpaceLocation,
			:SpaceBottomRight => :SpaceLocation,
			:SpaceBottomLeft => :SpaceLocation
			}
		}
	end
end
end
