require "spec_helper"

describe Chasocker do
  before(:all) do
    HOST, PORT, max = '127.0.0.1', 46969, 40

    @server = Chasocker::Server.new(PORT, HOST, max, $stdout, false, false)
    @server.start
    puts "Server started"
  end

  after(:all) do
    @server.stop

    sleep(0.0002)
    puts "Server stopped"
  end

  it "generates status messages" do
    @server.status(:ok).should eq(JSON.generate({ :status => "ok" }))
    @server.status(:smth).should eq(JSON.generate({ :status => "error" }))
  end

  it "responds with 'LOGIN' on connection" do
    socket = TCPSocket.new(HOST, PORT)
    socket.readline.chomp.should eq("LOGIN")
    socket.close
  end

  context "user to chatters" do
    it "accepts with correct id" do
      sleep(0.005)
      chatters_size = @server.chatters.size

      socket = TCPSocket.new(HOST, PORT)
      id = rand(100) + 1

      socket.readline.chomp.should eq("LOGIN")
      socket.puts(id)

      chomp = socket.readline.chomp
      chomp.should eq(JSON.generate({ :status => "ok" }))
      @server.chatters.size.should eq(chatters_size+1)

      socket.close

      sleep(0.005)
      @server.chatters[id].closed?.should be_true
    end

    it "accepts with 'Server'" do
          sleep(0.005)
          chatters_size = @server.chatters.size

          socket = TCPSocket.new(HOST, PORT)
          id = "Server"

          socket.readline.chomp.should eq("LOGIN")
          socket.puts(id)

          chomp = socket.readline.chomp
          chomp.should eq(JSON.generate({ :status => "ok" }))
          @server.chatters.size.should eq(chatters_size+1)

          socket.close

          sleep(0.005)
          @server.chatters[id].closed?.should be_true
        end

    it "decline with incorrect id" do
      sleep(0.005)
      chatters_size = @server.chatters.size

      socket = TCPSocket.new(HOST, PORT)
      id = rand(100)

      socket.readline.chomp.should eq("LOGIN")
      socket.puts("name#{id}")

      chomp = socket.readline.chomp
      chomp.should eq(JSON.generate({ :status => "error" }))
      @server.chatters.size.should eq(chatters_size)

      socket.close

      sleep(0.025)
      @server.chatters[id].should be_nil
    end
  end

  #context "bradcast messages" do
  #  it "does" do
  #    sleep(0.005)
  #    chatters_size = @server.chatters.size
  #
  #    # sender
  #    socket1 = TCPSocket.new(HOST, PORT)
  #    socket1.gets
  #    id1 = rand(100) + 1
  #    socket1.puts(id1)
  #    chomp1 = socket1.gets.chomp
  #    chomp1.should eq(JSON.generate({ :status => "ok" }))
  #    @server.chatters.size.should eq(chatters_size+1)
  #
  #    puts "Socket1 readlines: #{socket1.gets.inspect}"
  #
  #    # receivers
  #    chatters_size = @server.chatters.size
  #    socket2 = TCPSocket.new(HOST, PORT)
  #    socket2.gets
  #    id2 = rand(100) + 1
  #    socket2.puts(id2)
  #    chomp2 = socket2.gets.chomp
  #    chomp2.should eq(JSON.generate({ :status => "ok" }))
  #
  #    puts "Socket2 readlines: #{socket2.gets.inspect}"
  #
  #    @server.chatters.size.should eq(chatters_size+1)
  #
  #    socket1.puts(JSON.generate({ :message => "hello, there!" }))
  #
  #    #puts "Socket2 gets: #{socket2.gets}"
  #    #chomp3.should eq(JSON.generate({ :message => "hello, there!" }))
  #
  #    socket1.close
  #    socket2.close
  #
  #    sleep(0.005)
  #    @server.chatters[id1].closed?.should be_true
  #    @server.chatters[id2].closed?.should be_true
  #  end
  #
  #end
end