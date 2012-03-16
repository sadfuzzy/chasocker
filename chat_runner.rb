require File.expand_path("chat_server.rb", "lib")

if ARGV.include?("-h") || ARGV.size < 1
  $stderr.puts "Usage: #{$0} host:port\n\tDefault settings: localhost:46969"
  exit 1
end

ChatServer.new('localhost', 46969).run