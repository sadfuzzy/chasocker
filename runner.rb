require "./lib/chasocker.rb"

@server = Chasocker::Server.new(46969, '127.0.0.1', 40, $stdout, true, false)
@server.start
@server.join