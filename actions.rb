#!/usr/local/bin/ruby

module BSG
	class ImmediateTurnEnd < StandardError; end

	class GameObject
		ObjectData = {}
		ObjectCount = 1
		def initialize(args = {})
			args = self.class::ObjectData.merge(args)
			raise "Mismatched spec" unless self.class::Spec.sort === args.keys.sort
			args.each_pair { |key, value|
				self.instance_variable_set("@#{key.to_s}",value)
				self.instance_eval("def #{key.to_s}; return @#{key.to_s}; end")
			}
		end
		def self.build(args = {})
			objects = Array.new
			case self::ObjectCount
			when Fixnum
				self::ObjectCount.times do
					objects << self.new(args)
				end
			when Hash
				self::ObjectCount.each_pair { |property, map|
					map.each_pair { |value, count|
						count.times do
							objects << self.new(property => value)
						end
					}
				}
			else
				raise "Unknown ObjectCount type!"
			end
			objects = objects[0] if objects.length == 1
			return objects
		end
	end

	class Action < GameObject
	end

	class SkillCheck < Action
		Spec = [ :positive, :outcomes, :cards ]
		def initialize(args)
			args[:cards] ||= Array.new
			super(args)
		end
		def addcard(card)
			@cards << card
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
	class GameEvent < Action
		Spec = [ :text, :message, :type, :target]
		def initialize(args)
			args[:type] ||= :optional
			args[:target] ||= :currentplayer
			super(args)
		end
		def to_s
			return @text
		end
	end
	class GameChoice < Action
		Spec = [ :options, :targetplayer ]
		def initialize(args)
			args[:targetplayer] ||= :currentplayer
			super(args)
		end
	end
end
