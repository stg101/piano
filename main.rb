require "./reactor.rb"
require "./handlers.rb"

require "socket"

reactor = Reactor.instance

AcceptHandler.new(Addrinfo.tcp("127.0.0.1", 3000), reactor)

Signal.trap("INT") do |signo|
  reactor.close_handlers
  exit!
end

while true
  reactor.handle_events
end
