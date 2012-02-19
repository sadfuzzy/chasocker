require "socket"
include Socket::Constants

class ChatServer
  def initialize(port)
    # All sockets on the server
    @descriptors = Array::new
    @server_socket = TCPServer.new("", port)
    @server_socket.setsockopt(Socket::SOL_SOCKET, Socket::SO_REUSEADDR, 1)
    printf("Chatserver started on port %d\n", port)
    @descriptors.push(@server_socket)
  end # initialize

  def run

    loop {

      res = select(@descriptors, nil, nil, nil)

      unless res == nil

        # Iterate through the tagged read descriptors
        for sock in res[0]

          # Received a connect to the server (listening) socket
          if sock == @server_socket

            accept_new_connection

          else

            # Received something on a client socket
            if sock.eof?

              str = sprintf("Client left %s:%s\n",
                            sock.peeraddr[2], sock.peeraddr[1])
              broadcast_string(str, sock)
              sock.close
              @descriptors.delete(sock)

            else

              str = sprintf("[%s|%s]: %s",
                            sock.peeraddr[2], sock.peeraddr[1], sock.gets())
              broadcast_string(str, sock)

            end
          end
        end
      end

    }

  end #run

  private

  def broadcast_string(str, omit_sock)

    @descriptors.each do |client_socket|
      if client_socket != @server_socket && client_socket != omit_sock
        #puts client_socket.class
        client_socket.write(str)
      end
    end

    print(str)

  end # broadcast_string

  def accept_new_connection

    new_socket = @server_socket.accept
    @descriptors.push(new_socket)
    new_socket.write("You're connected to the Ruby chatserver\n")
    str = sprintf("Client joined %s:%s\n",
                  new_socket.peeraddr[2], new_socket.peeraddr[1])

    broadcast_string(str, new_socket)

  end # accept_new_connection
end #server

