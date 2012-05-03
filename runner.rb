require "./lib/chasocker.rb"

@server = Chasocker::Server.new(46969, '127.0.0.1', 40, $stdout, true, false)
#begin
  @server.start
@server.join
#rescue Interrupt => e
#  @server.stop
#  exit
#end