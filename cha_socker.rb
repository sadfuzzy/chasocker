#!/usr/bin/env ruby
require "gserver"
require "json"
require "digest/sha1"

class ChaSocker < GServer
  def initialize(*args)
    super

    # Keep a list for broadcasting messages
    @chatters = { }

    # We'll need this for thread safety
    @mutex = Mutex.new
  end

  #Send message out to everyone but sender
  def broadcast(message, sender=nil)

    message = message.strip << "\n"

    # Mutex for safety - GServer uses threads
    @mutex.synchronize do
      @chatters.each do |chatter|
        begin
          chatter[1].print(message) if chatter[1] != sender
        rescue
          @chatters.delete(chatter[0])
        end
      end
    end
  end

  # Handle each connection
  def serve(io)

    # Send status "ok" in json
    status = status(:ok)
    io.print(status)

    # Listen for identifier
    user = io.gets

    # They might disconnect
    return if user.nil?

    # Add to list of connections, @chatters
    @mutex.synchronize do
      # Use md5 for secure store
      # user = Digest::MD5.hexdigest(user)

      @chatters[user] = io
      @chatters << io
    end

    # Get and broadcast input until connection returns nil
    loop do
      message = io.gets

      if message
        broadcast(message, io)
      else
        break
      end
    end
  end

  def status(kind)
    status = case kind
               when :ok
                 { :status => "ok" }
               else
                 { :status => "ok" }
             end
    JSON.generate(status)
  end
end

# Show Help page if ARGV includes "-h" option
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