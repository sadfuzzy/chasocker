#!/usr/bin/env ruby
require 'gserver'
require 'json'

class ChaSocker < GServer
  def initialize *args
    super

    #Keep a list for broadcasting messages
    @chatters = []

    #We'll need this for thread safety
    @mutex = Mutex.new 
  end

  #Send message out to everyone but sender
  def broadcast message, sender = nil

    message = message.strip << "\n"

    #Mutex for safety - GServer uses threads
    @mutex.synchronize do
      @chatters.each do |chatter|
        begin
          chatter.print message unless chatter == sender
        rescue
          @chatters.delete chatter
        end
      end
    end
  end

  #Handle each connection
  def serve io

    # Log in
    io.print(status_ok)
    user = io.gets

    # Take info and ...

    #They might disconnect
    return if user.nil?

    user.strip!

    #Add to our list of connections
    @mutex.synchronize do
      @chatters << io
    end

    #Get and broadcast input until connection returns nil
    loop do
      message = io.gets

      if message
        broadcast message, io
      else
        break
      end
    end
  end

  def status_ok
    {:status => "ok"}.to_json
  end
end

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

# Start up the server on port 46969
# Accept connections for any IP address
# Allow up to 100 connections
# Send information to stderr
# Turn on informational messages
ChaSocker.new(port, host, 100, $stderr, true).start.join