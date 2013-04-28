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
				return "Generic movement handler\n"
			end
			def action
				return "Generic action handler\n"
			end
		end
		class GaiusBaltar < GenericCharacter
			CharData = { :name => "Gaius Baltar", :type => :political, :draw => { yellow: 2, green: 1, blue: 1 }, :loyalty => [2,1]}
		end
		class LauraRoslin < GenericCharacter
			CharData = { :name => "Laura Roslin", :type => :political, :draw => { yellow: 3, green: 2 } }
		end
		class TomZarek < GenericCharacter
			CharData = { :name => "Tom Zarek", :type => :political, :draw => { yellow: 2, green: 2, purple: 1 } }
		end
		class WilliamAdama < GenericCharacter
			CharData = { :name => "William Adama", :type => :military, :draw => { purple: 2, green: 3 } }
		end
		class SaulTigh < GenericCharacter
			CharData = { :name => "Saul Tigh", :type => :military, :draw => { purple: 3, green: 2 } }
		end
		class KarlAgathon < GenericCharacter
			CharData = { :name => "Karl \"Helo\" Agathon", :type => :military, :draw => { purple: 2, green: 2, red: 1 } }
		end
		class KaraThrace < GenericCharacter
			CharData = { :name => "Kara \"Starbuck\" Thrace", :type => :pilot, :draw => { purple: 2, red: 2, [ :green, :blue ] => 1 } }
		end
		class SharonValerii < GenericCharacter
			CharData = { :name => "Sharon \"Boomer\" Valerii", :type => :pilot, :draw => { purple: 2, red: 2, blue: 1 }, :loyalty => [1,2] }
		end
		class LeeAdama < GenericCharacter
			CharData = { :name => "Lee \"Apollo\" Adama", :type => :pilot, :draw => { red: 2, [ :green, :yellow ] => 2, purple: 1 } }
		end
		class GalenTyrol < GenericCharacter
			CharData = { :name => "\"Chief\" Galen Tyrol", :type => :support, :draw => { blue: 2, green: 2, yellow: 1 } }
		end
	end
end
