#!/usr/local/bin/ruby

require './actions.rb'

module BSG
module Characters
	module CharacterList
		def self.build(args = {})
			chars = Hash.new { |k,j| k[j] = [] }
			retchars = Hash.new
			charlist = BSG::Characters.constants.map { |i| BSG::Characters.const_get(i) }.select! { |i| i < Character }
			charlist.map { |charclass| charclass::build() }.each { |charobj| chars[charobj.type] << charobj }
			return chars
		end
	end

	class Character < BSG::GameObject
		Spec = [ :name, :type, :skilldraw, :loyalty, :startloc, :currentloc ]
		def initialize(args = {})
			args[:currentloc] ||= nil
			args[:loyalty] ||= [1,1]
			super(args)
		end
		def initialdraw(args)
			drawopts = Array.new
			@skilldraw.each_pair { |k,v|
				v.times { drawopts << k }
			}
			initdraw = args[:player].ask(askprompt: 'Choose your initial draw:', options: drawopts.flatten, count: 3)
			drawreq = Hash.new
			initdraw.each { |i|
				drawreq[args[:game].decks[:skillcards][i]] ||= 0
				drawreq[args[:game].decks[:skillcards][i]] += 1
			}
			args[:player].hand.concat(args[:game].drawcard(:spec => drawreq))
		end
		def loyaltydraw(args)
			drawreq = { args[:game].decks[:loyalty] => @loyalty[args[:round] - 1] }
			args[:player].loyalty.concat(args[:game].drawcard(:spec => drawreq))
		end
		def draw(args)
			drawreq = Hash.new
			@skilldraw.each_pair { |k,v|
				if k.kind_of?Array
					key = args[:player].ask(askprompt: 'Choose which card type to draw', options: k)[0]
				end
				key ||= k
				drawreq[args[:game].decks[:skillcards][key]] = v
			}
			args[:player].hand.concat(args[:game].drawcard(:deck => :skillcards, :spec => drawreq))
		end
		def discard(args)
			# Have the player select a number of cards from their hand
		end
		def movement(args)
			choices = args[:game].boards.values.map { |i| i.locations.values.select { |j| j.team == :human } }.flatten!
			args[:destination] ||= args[:player].ask(askprompt: 'Choose destination location:', options: choices, attr: :name, donothing: true, nothingprompt: "Do not move")[0]
			return if args[:destination] == nil
			
			@currentloc.leave(self) unless currentloc == nil
			@currentloc = args[:destination]
			@currentloc.enter(self)
			# Discard a card if you moved ships!
			# Tell the location that you arrived there!
			print "#{@name} moves to #{@currentloc}\n"
			return args[:destination]
		end
		def action(args)
			choices = args[:game].checktriggers(trigger: :action)
			object = args[:player].ask(askprompt: 'Choose action:', options: choices.keys, donothing: true, nothingprompt: "No action")[0]
			return if object == nil
			if choices[object].kind_of?Symbol
				message = choices[object]
			else
				message = choices[object].message
			end
			args[:game].execute(:target => object.method(message))
			return "Generic action handler\n"
		end
		def crisis(args)
			args[:card] ||= args[:game].drawcard(:spec => { args[:game].decks[:crisis] => 1 })[0]
			# Do this to the target
			args[:game].resolve(event: args[:card].crisis, eventtarget: args[:card])
			args[:game].docrisis(args[:card])
		end
	end
	class GaiusBaltar < Character
		ObjectData = { :name => "Gaius Baltar", :type => :political, :skilldraw => { yellow: 2, green: 1, blue: 1 }, :loyalty => [2,1], :startloc => :HangerDeck }
	end
	class LauraRoslin < Character
		ObjectData = { :name => "Laura Roslin", :type => :political, :skilldraw => { yellow: 3, green: 2 }, :startloc => :HangerDeck}
	end
	class TomZarek < Character
		ObjectData = { :name => "Tom Zarek", :type => :political, :skilldraw => { yellow: 2, green: 2, purple: 1 }, :startloc => :HangerDeck}
	end
	class WilliamAdama < Character
		ObjectData = { :name => "William Adama", :type => :military, :skilldraw => { purple: 2, green: 3 }, :startloc => :HangerDeck}
	end
	class SaulTigh < Character
		ObjectData = { :name => "Saul Tigh", :type => :military, :skilldraw => { purple: 3, green: 2 }, :startloc => :HangerDeck}
	end
	class KarlAgathon < Character
		ObjectData = { :name => "Karl \"Helo\" Agathon", :type => :military, :skilldraw => { purple: 2, green: 2, red: 1 }, :startloc => :HangerDeck}
	end
	class KaraThrace < Character
		ObjectData = { :name => "Kara \"Starbuck\" Thrace", :type => :pilot, :skilldraw => { purple: 2, red: 2, [ :green, :blue ] => 1 }, :startloc => :HangerDeck}
	end
	class SharonValerii < Character
		ObjectData = { :name => "Sharon \"Boomer\" Valerii", :type => :pilot, :skilldraw => { purple: 2, red: 2, blue: 1 }, :loyalty => [1,2], :startloc => :HangerDeck}
	end
	class LeeAdama < Character
		ObjectData = { :name => "Lee \"Apollo\" Adama", :type => :pilot, :skilldraw => { red: 2, [ :green, :yellow ] => 2, purple: 1 }, :startloc => :HangerDeck}
	end
	class GalenTyrol < Character
		ObjectData = { :name => "\"Chief\" Galen Tyrol", :type => :support, :skilldraw => { blue: 2, green: 2, yellow: 1 }, :startloc => :HangerDeck}
	end
end
end
