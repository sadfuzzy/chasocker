require "socket"
require "json"    #gives access to 'to_json' method
include Socket::Constants

class ChatServer
  def initialize(host, port)
    # All sockets on the server
    @descriptors = Array::new
    @server_socket = TCPServer.new(host, port)
    @server_socket.setsockopt(Socket::SOL_SOCKET, Socket::SO_REUSEADDR, 1)
    printf("Chatserver started on port %d\n", port)
    puts "#{@server_socket.addr.join('|')}"
    @descriptors.push(@server_socket)
    @descriptors.uniq!
    puts @descriptors.join(" ; ")
  end # initialize

  def run

    loop {

      tmp = select(@descriptors, nil, nil, nil)

      unless tmp == nil
        descriptors = tmp[0]

        # Iterate through the tagged read descriptors
        descriptors.each do |socket|

          # Received a connect to the server (listening) socket
          if socket == @server_socket

            puts "Accepting new connection!\n"
            accept_new_connection

          else

            puts "Socket: #{socket}\n"

            # Received something on a client socket
            if socket.respond_to?('eof') && socket.readlines()

              socket.close
              @descriptors.delete(socket)

            else

              client_host = socket.peeraddr[2]
              client_id = socket.peeraddr[1]
              message = socket.gets()

              puts "[#{[client_host, client_id].join('|')}: #{message}"
              broadcast_string(message, socket)

            end
          end
        end
      end

    }

  end #run

  private

  def broadcast_string(str)

    @descriptors.each do |client_socket|
      client_socket.puts(str)
    end

    print(str)

  end # broadcast_string

  def accept_new_connection

    new_socket = @server_socket.accept

    # sock.peeraddr(:hostname) #=> ["AF_INET", 80, "carbon.ruby-lang.org", "221.186.184.68"]
    # sock.peeraddr(:numeric)  #=> ["AF_INET", 80, "221.186.184.68", "221.186.184.68"]
    if new_socket.methods.include?(:peeraddr)

      client_host = new_socket.peeraddr(:numeric)[2]
      client_id = new_socket.peeraddr(:numeric)[1]

      puts "Client joined #{client_host}:#{client_id}"

    end

    @descriptors.push(new_socket)

    success = {:status => "OK"}
    new_socket.puts(success.to_json)

  end # accept_new_connection
end #server

