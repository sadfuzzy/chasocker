require "spec_helper"

describe Chasocker do
  before(:all) do

    HOST, PORT, max = '127.0.0.1', 46969, 4

    @server = Chasocker::Server.new(PORT, HOST, max, $stderr, false, true)
    @server.start

  end

  it "should properly accept connections" do

    @server.connections.should == 0
    @server.chatters.size.should == 0

    socket = TCPSocket.new(HOST, PORT)

    socket.readline.chomp.should == "LOGIN"
    #@server.connections.should == 1
    @server.chatters.size.should == 1

    socket.close

    sleep 1

    @server.connections.should == 0
    @server.chatters.size.should == 1

  end

  after(:all) do

    @server.shutdown

  end

end