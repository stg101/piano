require_relative "input/reactor"
require_relative "input/handlers"
require_relative "errors"

require "socket"
# todo errors
class Server
  attr_reader :reactor

  def initialize
    @reactor = Reactor.instance

    Signal.trap("INT") do |signo|
      close
      exit!
    end
  end

  def run
    begin
      AcceptHandler.new(Addrinfo.tcp("127.0.0.1", 3000), reactor)

      while true
        reactor.handle_events
      end
    rescue ApplicationError => e
      puts e
      close
      retry
    end
  end

  def close
    reactor.close_handlers
  end
end

server = Server.new
server.run
