require "./player_service.rb"

class Duration
  attr_reader :denominator, :extensions

  def initialize(denominator = 4, extensions = 0)
    @denominator = denominator
    @extensions = extensions
  end

  def add_extension
    @extensions += 1
  end

  def in_beats
    (Options.instance.whole_note_beats.to_f / denominator) * extension_factor
  end

  def in_seconds
    in_beats * 60.0 / Options.instance.bpm
  end

  private

  def extension_factor
    (2 - 1.0 / (2 ** extensions))
  end
end

class Pitch
  attr_reader :tone, :octave

  def initialize(tone, octave = 4)
    @tone = tone
    @octave = octave
  end

  def to_s
    "#{tone.upcase}#{octave}"
  end
end

class AudioComponent
  def first
    children.first
  end

  def last
    children.last
  end

  def children
    return []
  end

  def accept(visitor)
    visitor.visit(self)
  end

  def play
    raise NotImplementedError
  end
end

class SequenceComponent < AudioComponent
  attr_reader :children

  def initialize(components)
    @children = components
  end

  def play
    children.each do |child|
      child.play
    end
  end
end

class RepeatComponent < AudioComponent
  attr_reader :children, :count

  def initialize(component, count)
    @count = count
    @children = [component]
  end

  def play
    count.times do
      first.play
    end
  end
end

class NoteComponent < AudioComponent
  attr_reader :duration, :pitch

  def initialize(pitch, duration)
    @pitch = pitch
    @duration = duration
  end

  def play
    PlayerService.instance.play_note(self)
  end
end

# falta un sleep component

class ChordComponent < AudioComponent
  attr_reader :notes

  def initialize(notes)
    @notes = notes
  end

  # if you are passing notes, you need to tranform to s
  def play
    PlayerService.instance.play_chord(self)
  end
end
