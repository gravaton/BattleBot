#!/usr/local/bin/ruby

require 'rubygems'
require 'cinch'

class BSGPlugin
	include Cinch::Plugin

	def initialize(*args)
		super
		@test = "Yo"
	end

	match "hello"
	def execute(m)
		m.reply "Hello again, #{m.user.nick}, this plugin says #{@test}"
	end
end
