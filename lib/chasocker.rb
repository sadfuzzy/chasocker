require "chasocker/version"
require "gserver"

module Chasocker
  class Server < GServer

    def initialize(*args)

      super(*args)

      #Keep a list for broadcasting messages
      @chatters = { }

      # We'll need this for thread safety
      @mutex = Mutex.new

    end

    def chatters

      @chatters

    end

    def serve(io)

      io.puts("LOGIN")

      self.chatters[1] = "some"

    end
  end
end
