require File.expand_path("chat_server.rb", "lib")

host = ""
host = ARGV[0] unless ARGV[0].nil?
port = 3001
port = ARGV[1] unless ARGV[1].nil?

ChatServer.new(host, port).run