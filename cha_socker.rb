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

    # Mutex for safety - GServer uses threads
    @mutex.synchronize do

      @chatters.each do |chatter|

        id, sock = chatter[0], chatter[1]

        begin

          # Do not send to Server
          if sock != sender

            sock.print(message) if !recipients.include?(id)

          end

        rescue

          $stderr.puts("DELETING #{sock.inspect} by #{id}")
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

    # Inspect chatters
    $stderr.puts("#{Time.now} Chatters #{@chatters.inspect}")

    # Get and broadcast input until connection returns nil
    loop do

      incoming = io.gets

      parsed = JSON.parse(incoming)
      message = parsed["message"]
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

host, port = "localhost", 46969

# Show Help page if ARGV includes "-h" option
if ARGV.include?("-h")

  $stderr.puts "Usage: #{$0} host:port\n\tDefault settings: #{host}:#{port}"
  exit 1

else

  # Customized start
  if ARGV[0]

    args = ARGV[0].split(':')
    host, port = args[0], args[1]

  end
end

# Start up the server on port 46969
# Accept connections for any IP address
# Allow up to 100 connections
# Send information to stderr
# Turn on informational messages
ChaSocker.new(port, host, 100, $stderr, true).start.join