#!/usr/local/bin/ruby


module BSG
	module Characters
		module CharacterList
			def self.build(args = {})
				chars = Hash.new { |k,j| k[j] = [] }
				retchars = Hash.new
				charlist = BSG::Characters.constants.map { |i| BSG::Characters.const_get(i) }.select! { |i| i < GenericCharacter }
				charlist.map { |charclass| charclass::build() }.each { |charobj| chars[charobj.type] << charobj }
				return chars
			end
		end
		class GenericCharacter
			attr_reader :currentloc
			Spec = [ :name, :type, :skilldraw, :loyalty, :startloc ]
			def initialize(args = {})
				args[:loyalty] = [1,1]
				args = self.class::CharData.merge(args)
				raise "Mismatched character spec" unless self.class::Spec.sort == args.keys.sort
				args.each_pair { |key, value|
					self.instance_variable_set("@#{key.to_s}", value)
					self.instance_eval("def #{key.to_s}; return @#{key.to_s}; end")
				}
			end
			def self.build
				return self.new
			end
			def draw(args)
				drawreq = Hash.new
				@skilldraw.each_pair { |k,v|
					if k.kind_of?Array
						key = args[:player].ask(askprompt: 'Choose which card type to draw', options: k)
					end
					key ||= k
					drawreq[args[:game].decks[:skillcards][key]] = v
				}
				args[:player].hand.concat(args[:game].drawcard(:deck => :skillcards, :spec => drawreq))
			end
			def movement(args)
				choices = args[:game].boards.map { |i| i.locations.select { |j| j.team == :human } }.flatten!
				args[:destination] ||= args[:player].ask(askprompt: 'Choose which location to go to:', options: choices, attr: :name)
				@currentloc = args[:destination]
				# Discard a card if you moved ships!
				# Tell the location that you arrived there!
				print "#{@name} moves to #{@currentloc}\n"
				return args[:destination]
			end
			def action(args)
				choices = args[:player].checktriggers(:action)
				object = args[:player].ask(askprompt: 'Which action would you like to perform:', options: choices.keys.concat(["Nothing"]))
				return if object == "Nothing"
				args[:player].execute(:target => object.method(choices[object]))
				return "Generic action handler\n"
			end
			def crisis(args)
				card = args[:game].drawcard(:spec => { args[:game].decks[:crisis] => 1 })[0]
				args[:game].docrisis(card)
			end
		end
		class GaiusBaltar < GenericCharacter
			CharData = { :name => "Gaius Baltar", :type => :political, :skilldraw => { yellow: 2, green: 1, blue: 1 }, :loyalty => [2,1], :startloc => :HangerDeck }
		end
		class LauraRoslin < GenericCharacter
			CharData = { :name => "Laura Roslin", :type => :political, :skilldraw => { yellow: 3, green: 2 }, :startloc => :HangerDeck}
		end
		class TomZarek < GenericCharacter
			CharData = { :name => "Tom Zarek", :type => :political, :skilldraw => { yellow: 2, green: 2, purple: 1 }, :startloc => :HangerDeck}
		end
		class WilliamAdama < GenericCharacter
			CharData = { :name => "William Adama", :type => :military, :skilldraw => { purple: 2, green: 3 }, :startloc => :HangerDeck}
		end
		class SaulTigh < GenericCharacter
			CharData = { :name => "Saul Tigh", :type => :military, :skilldraw => { purple: 3, green: 2 }, :startloc => :HangerDeck}
		end
		class KarlAgathon < GenericCharacter
			CharData = { :name => "Karl \"Helo\" Agathon", :type => :military, :skilldraw => { purple: 2, green: 2, red: 1 }, :startloc => :HangerDeck}
		end
		class KaraThrace < GenericCharacter
			CharData = { :name => "Kara \"Starbuck\" Thrace", :type => :pilot, :skilldraw => { purple: 2, red: 2, [ :green, :blue ] => 1 }, :startloc => :HangerDeck}
		end
		class SharonValerii < GenericCharacter
			CharData = { :name => "Sharon \"Boomer\" Valerii", :type => :pilot, :skilldraw => { purple: 2, red: 2, blue: 1 }, :loyalty => [1,2], :startloc => :HangerDeck}
		end
		class LeeAdama < GenericCharacter
			CharData = { :name => "Lee \"Apollo\" Adama", :type => :pilot, :skilldraw => { red: 2, [ :green, :yellow ] => 2, purple: 1 }, :startloc => :HangerDeck}
		end
		class GalenTyrol < GenericCharacter
			CharData = { :name => "\"Chief\" Galen Tyrol", :type => :support, :skilldraw => { blue: 2, green: 2, yellow: 1 }, :startloc => :HangerDeck}
		end
	end
end
