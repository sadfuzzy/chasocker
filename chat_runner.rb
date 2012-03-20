#!/usr/bin/env ruby
require File.expand_path("chat_server.rb", "lib")

# Help
if ARGV.include?("-h")
  $stderr.puts "Usage: #{$0} host:port\n\tDefault settings: localhost:46969"
  exit 1
else
	# Customized start
	if ARGV[0]
		args = ARGV[0].split(':')
		host, port = args[0], args[1]
	else
	# Start without params
		host, port = "localhost", 46969
	end
end

ChatServer.new(host, port).run
