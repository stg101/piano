require "singleton"

class Options
  include Singleton

  attr_accessor :bpm, :time_signature

  def initialize
    @bpm = 60
    @time_signature = [4, 4]
  end

  def whole_note_beats
    @time_signature[1]
  end
end
