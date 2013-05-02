#!/usr/local/bin/ruby

module BSG
	class GenericAction
		ActionData = {}
		def initialize(args = {})
			args = self.class::ActionData.merge(args)
			raise "Mismatched action spec" unless self.class::Spec.sort == args.keys.sort
			args.each_pair { |key, value|
				self.instance_variable_set("@#{key.to_s}",value)
				self.instance_eval("def #{key.to_s}; return @#{key.to_s}; end")
			}
		end
	end
	class SkillCheck < GenericAction
		Spec = [ :positive, :outcomes, :cards ]
		def initialize(args)
			args[:cards] ||= Array.new
			super(args)
		end
		def addcard(card)
			@cards << card
		end
		def resolve
		end
		def to_s
			output = "SKILL CHECK:\n"
			output += @positive.to_s
			output += "\n\nOutcomes:\n"
			@outcomes.each_pair { |k,v|
				output += "#{k} \t-\t#{v.to_s}\n"
			}
			return output
		end
	end
	class GameEvent < GenericAction
		Spec = [ :text, :message, :type]
		def initialize(args)
			args[:type] ||= :optional
			super(args)
		end
		def to_s
			return @text
		end
	end
	class GameChoice < GenericAction
		Spec = [ :options, :player ]
		def initialize(args)
			args[:player] ||= :currentplayer
			super(args)
		end
	end
end
