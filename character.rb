#!/usr/local/bin/ruby


module BSG
	module Characters
		module CharacterList
			def self.build(args = {})
				chars = Array.new
				charlist = BSG::Characters.constants.map { |i| BSG::Characters.const_get(i) }.select! { |i| i < GenericCharacter }
				print charlist, "\n"
				charlist.each { |charclass| chars << charclass::build() }
				return chars
			end
		end
		class GenericCharacter
			Spec = [ :name, :type, :draw, :loyalty ]
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
			def movement
				return "Generic movement handler"
			end
			def action
				return "Generic action handler"
			end
		end
		class Baltar < GenericCharacter
			CharData = { :name => "Gaius Baltar", :type => "Political Leader", :draw => { yellow: 2, green: 1, blue: 1 }, :loyalty => [2,1]}
		end
		class WillAdama < GenericCharacter
			CharData = { :name => "William Adama", :type => "Military Leader", :draw => { purple: 2, green: 3 } }
		end
		class TomZarek < GenericCharacter
			CharData = { :name => "Tom Zarek", :type => "Political Leader", :draw => { yellow: 3, green: 2, blue: 1 } }
		end
		class Callie < GenericCharacter
			CharData = { :name => "Callie", :type => "Support Leader", :draw => { purple: 2, green: 2, blue: 1 } }
		end
	end
end
