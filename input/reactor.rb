require "ostruct"
require "singleton"
require "ostruct"

# Not thread safe singleton
class Reactor
  include Singleton

  def initialize
    @demux_table = []
  end

  def convert_to_fd_sets()
    ios = demux_table.compact.map { |record| IO.for_fd(record.handler.get_handle) }
    return OpenStruct.new(
             read_ios: ios,
             write_ios: [],
             error_ios: ios,
           )
  end

  def handle_events()
    fd_sets = convert_to_fd_sets
    results = IO.select(fd_sets.read_ios, fd_sets.write_ios, fd_sets.error_ios)
    read_ios = results[0]
    read_ios.each do |io|
      demux_record = demux_table[io.fileno]
      if !demux_record.nil?
        demux_record.handler.handle_event(io.fileno, EventType::READ_EVENT)
      end
    end

    error_ios = results[1]
    error_ios.each do |io|
      demux_record = demux_table[io.fileno]
      if !demux_record.nil?
        demux_record.handler.handle_event(io.fileno, EventType::ERROR_EVENT)
      end
    end
  end

  def register_handler(handler, event_type)
    demux_table[handler.get_handle] = OpenStruct.new(handler: handler, event_type: event_type)
  end

  def remove_handler(handle)
    close_handler(handle)
    demux_table[handle] = nil
  end

  def close_handlers()
    #here an iterator is better
    demux_table.compact.each do |handler_tuple|
      # puts "Closing handler #{handler_tuple.handler.get_handle}"
      handler_tuple.handler.close_handle
    end
  end

  def close_handler(handle)
    puts "Closing handler #{handle}"
    demux_table[handle].handler.close_handle
  end

  private

  attr_accessor :demux_table
end
