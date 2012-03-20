require "socket"
require "json"
include Socket::Constants

class ChatServer
  def initialize(host, port)
    # All sockets on the server
    @descriptors = Array::new
    @server_socket = TCPServer.new(host, port)
    @server_socket.setsockopt(Socket::SOL_SOCKET, Socket::SO_REUSEADDR, 1)
    printf("Chatserver started on port %d\n", port)
    @descriptors.push(@server_socket)
  end

  def run

    loop do

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

              sprintf("Client left %s:%s\n",
                      sock.peeraddr[2], sock.peeraddr[1])
              sock.close
              @descriptors.delete(sock)

            else

              client_host = sock.peeraddr[2]
              client_id = sock.peeraddr[1]
              message = sock.gets()

              sprintf("[%s|%s]: %s", client_host, client_id, message)
              broadcast_string(message, sock)

            end
          end
        end
      end

    end

  end

  private

  def broadcast_string(str, omit_sock)

    @descriptors.each do |client_socket|
      if client_socket != @server_socket && client_socket != omit_sock
        client_socket.write(str)
      end
    end

    print(str)

  end

  def accept_new_connection

    new_socket = @server_socket.accept
    client_host = new_socket.peeraddr[2]
    client_id = new_socket.peeraddr[1]

    @descriptors.push(new_socket)
    ok = {:status => "OK"}
    new_socket.puts(ok.to_json)
    sprintf("Client joined %s:%s\n", client_host, client_id)

  end
end