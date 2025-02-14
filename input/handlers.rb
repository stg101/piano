require_relative "../states/audio_tree"
require_relative "../commands/user_command_factory"
require_relative "../interpreter/interpreter"
require_relative "../interpreter/tokenizer"
require_relative "../errors"

module EventType
  READ_EVENT = 0x01
  ACCEPT_EVENT = 0x01
  WRITE_EVENT = 0x02
  CLOSE_EVENT = 0x04
  ERROR_EVENT = 0x08
end

class Handler
  def handle_event(handle, event_type)
    raise NotImplementedError
  end

  def get_handle()
    raise NotImplementedError
  end

  def close_handle()
    raise NotImplementedError
  end
end

class AcceptHandler < Handler
  def initialize(addr_info, reactor)
    @socket = Socket.new Socket::AF_INET, Socket::SOCK_STREAM
    socket.bind(addr_info)
    socket.listen(1000)

    puts "Listening on #{addr_info.ip_address}:#{addr_info.ip_port}"

    reactor.register_handler(self, EventType::ACCEPT_EVENT)
  end

  def handle_event(handle, event_type)
    client_socket_info = socket.accept

    PianoHandler.new(client_socket_info, Reactor.instance)
  end

  def get_handle
    socket.fileno
  end

  def close_handle
    addr_info = socket.local_address
    puts "Closing accept handler #{socket.fileno}"
    puts "Closing socket listening on: #{addr_info.ip_address}:#{addr_info.ip_port}"
    socket.close
  end

  private

  attr_accessor :socket
end

# reproductor remoto
# i will need  a queue of plays
# the original code uses a template pattern to abstract succind and verbose mode
class PianoHandler < Handler
  def initialize(socket_info, reactor)
    ## is this actually isolating the connection side from the application side ??
    @socket = socket_info[0]
    @peer_addr = socket_info[1]

    @audio_tree = AudioTree.new
    @command_factory = UserCommandFactory.new(@audio_tree)
    puts "Accepted connection to #{peer_addr.ip_address}:#{peer_addr.ip_port}"

    reactor.register_handler(self, EventType::READ_EVENT | EventType::CLOSE_EVENT)
  end

  def handle_event(handle, event_type)
    puts "event recv handle:#{handle} - event type:#{event_type}"
    payload = socket.recvfrom(256)

    if payload.nil?
      # send event or close ?
      Reactor.instance.remove_handler(handle)
      return
    end

    payload_body = payload[0]

    begin
      command = command_factory.make_command(payload_body)
      command.execute
    rescue Tokenizer::TokenizerError => e
      socket.write("TokenizerError: #{e.message}\n")
    rescue Interpreter::SyntaxError => e
      socket.write("SyntaxError: #{e.message}\n")
    rescue Interpreter::InterpreterError => e
      socket.write("InterpreterError: #{e.message}\n")
    rescue UserCommandFactory::UnexpectedCommandError => e
      socket.write("Unknown command: #{e.message}\n")
    rescue UserCommandFactory::BadArgumentError => e
      socket.write("Bad argument: #{e.message}\n")
    rescue StandardError => e
      socket.write(e.message)
    end
  end

  def get_handle
    socket.fileno
  end

  def close_handle
    puts "Closing read handler #{socket.fileno}"
    puts "Closing socket listening to: #{peer_addr.ip_address}:#{peer_addr.ip_port}"
    socket.close
  end

  private

  attr_accessor :socket, :peer_addr, :audio_tree, :command_factory
end
