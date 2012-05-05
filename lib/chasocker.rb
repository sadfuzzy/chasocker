require "chasocker/version"
require "json"
require "gserver"

module Chasocker
  class Server < GServer
    attr_accessor :chatters
    attr_accessor :mutex

    def initialize(*args)
      super(*args)

      # Keep a list for broadcasting messages
      @chatters = { }

      # We'll need this for thread safety
      @mutex = Mutex.new
    end

    # Handle each connection
    def serve(io)
      io.puts("LOGIN\n")
      # Listen for identifier
      user = io.gets.chomp

      # They might disconnect
      # TODO: Add clever authorisation
      io.puts(status(:error)) && return if user.nil?

      # Close if user_id is not an integer or "Server"
      # TODO: Check the server in a better way
      if user.to_i == 0
        if user != "Server"
          io.puts(status(:error))

          return
        end
      end

      user = user.to_i unless user == "Server"

      # Send status "ok" in json
      io.puts(status(:ok))

      # Add connection to the list
      @mutex.synchronize { @chatters[user] = io }

      # Inspect chatters
      $stdout.puts("#{Time.now} Chatters #{@chatters.inspect}")

      # Get and broadcast input until connection returns nil
      loop do

        incoming = io.gets
        parsed = JSON.parse(incoming)
        message = parsed["message"]
        recipients = parsed["recipients"]

        if message

          broadcast(message, io, recipients)
          $stdout.puts "#{parsed.inspect}"

        else

          $stdout.puts "Broken #{incoming}?!"
          break

        end

      end
    end

    #Send message out to everyone, but sender
    def broadcast(message="", sender, recipients)

      # Mutex for safety - GServer uses threads
      @mutex.synchronize do

        @chatters.each do |chatter|

          id, sock = chatter[0], chatter[1]

          begin

            # Do not send to Server
            if sock != sender

              sock.print(message) if recipients.include?(id)

            end

          rescue

            $stdout.puts("DELETING #{sock.inspect}")
            #@chatters.delete(id)

          end

        end

      end
    end

    def status(kind)
      status = case kind
               when :ok
                 { :status => "ok" }
               else
                 { :status => "error" }
               end

      JSON.generate(status)
    end
  end
end
