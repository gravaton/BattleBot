#!/usr/local/bin/ruby


module BSG
	module Characters
                module Baltar
                        def self.attributes
                                return { :name => "Gaius Baltar", :type => "Political Leader" }
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
