require "singleton"

class Options
  include Singleton

  attr_accessor :bpm, :time_signature

  def initialize
    @bpm = 60
    @time_signature = [4, 4]
  end

  def set_bpm(bpm)
    @bpm = bpm
  end

  def set_time_signature(time_signature)
    @time_signature = time_signature
  end

  def whole_note_beats
    @time_signature[1]
  end
end
