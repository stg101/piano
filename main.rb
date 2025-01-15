require_relative "input/reactor"
require_relative "input/handlers"

require "socket"

class Server
  attr_reader :reactor

  def initialize
    @reactor = Reactor.instance

    Signal.trap("INT") do |signo|
      close
    end
  end

  def run
    AcceptHandler.new(Addrinfo.tcp("127.0.0.1", 3000), reactor)

    while true
      reactor.handle_events
    end
  end

  # def run
  #   begin
  #     AcceptHandler.new(Addrinfo.tcp("127.0.0.1", 3000), reactor)

  #     while true
  #       reactor.handle_events
  #     end
  #   rescue Exception => e
  #     close
  #     raise e
  #   end
  # end

  def close
    reactor.close_handlers
    exit!
  end
end

server = Server.new
server.run
