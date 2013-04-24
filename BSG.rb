#!/usr/local/bin/ruby

require './character.rb'
require './boards.rb'


module BSG
	class BSGGame
		attr_reader :players, :options
	
		def initialize
			@players = []
		end
		def addplayer(player)
			@players << player
		end
		def drawcard(req)
			req.each_pair { |color, quant|
				print "Draw request for #{quant} #{color} cards\n"
			}
		end
		def drawcrisis(num)
			print "Draw request for #{num} crisis cards\n"
		end
	end

	class BSGPlayer
		def initialize(gameref)
			@game = gameref
			@character = nil
			@loyaltycount = [1,1]
			@loyalties = []
			@offices = []
			@hand = []
		end
		def choosechar
			print "Selecting Gaius Baltar...\n"
			extend BSG::Characters::Baltar
			charinit
		end
		def draw
			@game.drawcard(@draw)
		end
		def movement
			return "Default movement handler\n"
		end
		def action
			return "Default action handler\n"
		end
		def crisis
			@game.drawcrisis(1)
		end
	end
	
	module Characters
		module Baltar
			def self.attributes
				return { :name => "Gaius Baltar", :type => :political }
			end
			def charinit
				@draw = { :yellow => 2, :green => 1, :blue => 1 }
				@loyaltycount = [2,1]
			end
			def crisis
				print "Choose a new card to draw\n"
				super
			end
		end
		module WillAdama
			def self.attributes
				return { :name => "William Adama", :type => "Military Leader" }
			end
			def charinit
				@draw = { :green => 3, :purple => 2 }
			end
		end
		module TomZarek
			def self.attributes
				return { :name => "Tom Zarek", :type => "Political Leader" }
			end
			def charinit
				@draw = { :yellow => 3, :green => 2 }
			end
		end
		module Callie
			def self.attributes
				return { :name => "Callie", :type => "Support Leader" }
			end
			def charinit
				@draw = { :green => 2, :purple => 2, :blue => 1 }
			end
		end
	end
end
# Figure out how many players
game = BSG::BSGGame.new

3.times do
	game.addplayer(BSG::BSGPlayer.new(game))
end

print BSG::Characters::Baltar.attributes, "\n"

game.players.each { |player|
	player.choosechar
}
game.players.each { |player|
	player.draw	
	print player.movement
	print player.action
	player.crisis
}

BSG::Characters.constants.each { |i| print BSG::Characters.const_get(i).attributes, "\n" }
