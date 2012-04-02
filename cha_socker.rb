#!/usr/bin/env ruby
require "gserver"
require "json"
#require "digest/sha1"

class ChaSocker < GServer
  def initialize(*args)

    super

    # Keep a list for broadcasting messages
    @chatters = { }

    # We'll need this for thread safety
    @mutex = Mutex.new

  end

  #Send message out to everyone, but sender
  def broadcast(message, sender=nil, recipients=[])

    message = message.strip << "\n"

    # Mutex for safety - GServer uses threads
    @mutex.synchronize do

      id, sock = chatter[0], chatter[1]

      @chatters.each do |chatter|
        begin

          # Do not send to Server
          if sock != sender

            sock.print(message) if recipients.include?(id)

          end

        rescue

          @chatters.delete(id)

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
    user = io.gets.strip

    # They might disconnect or send something wrong
    # TODO: Add clever authorisation
    return if user.nil?

    # Reject if user_id cannot be converted to String and not "Server"
    # TODO: Check the server in a better way
    return if user.to_i == 0 && user != "Server"

    user = user.to_i unless user == "Server"

    # Add to list of connections, @chatters
    @mutex.synchronize do

      @chatters[user] = io

    end

    # Get and broadcast input until connection returns nil
    loop do

      incoming = io.gets

      # Kind of scary thing to make JSON parse it
      # TODO: Refactor
      incoming = incoming.strip.gsub(/[\\]/,'').chop.reverse.chop.reverse

      parsed = JSON.parse(incoming)
      message = parsed["message"].strip << "\n"
      recipients = parsed["recipients"]

      if message

        broadcast(message, io, recipients)

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