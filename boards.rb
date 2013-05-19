#!/usr/local/bin/ruby

module BSG
module Locations
	class GenericLocation
		LocData = { :trigger => { :action => :action } }
		Spec = [ :name, :team, :status, :trigger, :contents ]
		def initialize(args = {})
			args[:contents] ||= Array.new
			args = self.class::LocData.merge(args)
			raise "Mismatched location spec" unless self.class::Spec.sort == args.keys.sort
			args.each_pair { |key, value|
				self.instance_variable_set("@#{key.to_s}", value)
				self.instance_eval("def #{key.to_s}; return @#{key.to_s}; end")
			}
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
			method = Hash.new
			return method if @status == :damaged
			if (@trigger.has_key?args[:trigger])
				method[self] = @trigger[args[:trigger]]
			end
			print "Trigger check for #{@name} returned #{method}\n"
			return method
		end
		def to_s
			return "LOCATION - #{@name}"
		end
		def self.build
			return self.new
		end
	end
	# Colonial One
	class PressRoom < GenericLocation
		LocData = LocData.merge({ :name => "Press Room", :team => :human, :status => :available })
	end
	class PresidentsOffice < GenericLocation
		LocData = LocData.merge({ :name => "President's Office", :team => :human, :status => :available })
	end
	class Administration < GenericLocation
		LocData = LocData.merge({ :name => "Administration", :team => :human, :status => :available })
	end

	# Galactica
	class Sickbay < GenericLocation
		LocData = { :name => "Sickbay", :team => :human, :status => :restricted, :trigger => { :draw => :sickdraw } }
		def draw
			print "Draw only one card because you're in Sick Bay!\n"
		end
	end
	class Brig < GenericLocation
		LocData = LocData.merge({ :name => "Brig", :team => :human, :status => :restricted })
	end
	class Armory < GenericLocation
		LocData = LocData.merge({ :name => "Armory", :team => :human, :status => :available })
	end
	class ResearchLab < GenericLocation
		LocData = LocData.merge({ :name => "Research Lab", :team => :human, :status => :available })
	end
	class HangerDeck < GenericLocation
		LocData = LocData.merge({ :name => "Hanger Deck", :team => :human, :status => :available })
	end
	class Communications < GenericLocation
		LocData = LocData.merge({ :name => "Communications", :team => :human, :status => :available })
	end
	class AdmiralsQuarters < GenericLocation
		LocData = LocData.merge({ :name => "Admiral's Quarters", :team => :human, :status => :available })
	end
	class WeaponsControl < GenericLocation
		LocData = LocData.merge({ :name => "Weapons Control", :team => :human, :status => :available })
	end
	class Command < GenericLocation
		LocData = LocData.merge({ :name => "Command", :team => :human, :status => :available })
	end
	class FTLControl < GenericLocation
		LocData = LocData.merge({ :name => "FTL Control", :team => :human, :status => :available })
		def gettrigger(args)
			return {} if args[:game].jumptrack < 3
			return super
		end
	end

	# Cylon locations
	class Caprica < GenericLocation
		LocData = LocData.merge({ :name => "Caprica", :team => :cylon, :status => :available })
	end
	class CylonFleet < GenericLocation
		LocData = LocData.merge({ :name => "Cylon Fleet", :team => :cylon, :status => :available })
	end
	class HumanFleet < GenericLocation
		LocData = LocData.merge({ :name => "Human Fleet", :team => :cylon, :status => :available })
	end
	class ResurrectionShip < GenericLocation
		LocData = LocData.merge({ :name => "Resurrection Ship", :team => :cylon, :status => :available })
	end

	# Space Locations
	class SpaceLocation < GenericLocation
		LocData = LocData.merge({ :name => "Space location", :team => :space, :status => :available })
	end

	# Gameboards
	module BoardList
		def self.build(args = {})
			boards = Hash.new
			args[:loclist] ||= BSG::Locations.constants.map { |i| BSG::Locations.const_get(i) }.select! { |i| i < GenericBoard }
			args[:loclist].each { |locclass| boards[locclass::BoardData[:name]] = locclass::build() }
			return boards
		end
	end
	class GenericBoard
		BoardData = {}
		Spec = [ :name, :description, :locations ]
		def initialize(args = {})
			args = self.class::BoardData.merge(args)
			raise "Mismatched board spec" unless self.class::Spec.sort == args.keys.sort
			args.each_pair { |key, value|
				self.instance_variable_set("@#{key.to_s}", value)
				self.instance_eval("def #{key.to_s}; return @#{key.to_s}; end")
			}

			# If it's an array of classnames we'll presume the name should be the same as the classname
			if @locations.kind_of?Array
				@locations = Hash[@locations.map { |i| [i,i] }]
			end
			@locations.each_pair { |k,v| @locations[k] = BSG::Locations.const_get(v)::build() }
		end
		def self.build
			return self.new
		end
	end
	class GalacticaBoard < GenericBoard
		BoardData = { :name => :BSG, :description => "Battlestar Galactica", :locations => [:FTLControl, :Command, :WeaponsControl, :AdmiralsQuarters, :Communications, :HangerDeck, :ResearchLab, :Armory, :Brig, :Sickbay ] }
	end
	class ColonialOneBoard < GenericBoard
		BoardData = { :name => :ColonialOne, :description => "Colonial One", :locations => [ :PressRoom, :PresidentsOffice, :Administration ] }
	end
	class CylonBoard < GenericBoard
		BoardData = { :name => :Cylon, :description => "Cylon Actions", :locations => [ :Caprica, :CylonFleet, :HumanFleet, :ResurrectionShip ] }
	end
	class SpaceBoard < GenericBoard
		BoardData = { :name => :Space, :description => "Space Locations", :locations => {
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
