require "./player_service.rb"

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

class LeafComponent < AudioComponent
end

class NaryComponent < AudioComponent
end

class UnaryComponent < AudioComponent
end

class SequenceComponent < NaryComponent
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

class RepeatComponent < UnaryComponent
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

class NoteComponent < LeafComponent
  attr_reader :ratio, :note

  def initialize(note, ratio)
    @note = note
    @ratio = ratio
  end

  def play
    PlayerService.instance.play(note, ratio)
  end

  def clone
    NoteComponent.new(note, ratio)
  end
end

class ChordComponent < LeafComponent
  attr_reader :notes, :ratio

  def initialize(notes, ratio)
    @notes = notes
    @ratio = ratio
  end

  # if you are passing notes, you need to tranform to s
  def play

    _notes = notes.map do |note|
      _note = note.dup


    end

    PlayerService.instance.play_chord(_notes, ratio)
  end
end

# composite = SequenceComponent.new([
#   RepeatComponent.new(
#     SequenceComponent.new([
#       NoteComponent.new("C4", 1),
#       NoteComponent.new("D4", 0.5),
#     ]), 3
#   ),
# ])
# composite.play

# composite = SequenceComponent.new([
#   NoteComponent.new("C1", 2),
#   NoteComponent.new("C2", 2),
#   NoteComponent.new("C3", 2),
#   NoteComponent.new("C4", 2),
#   NoteComponent.new("C5", 2),
#   NoteComponent.new("C6", 2),
#   NoteComponent.new("C7", 2),
#   NoteComponent.new("C8", 2),
# ])

# composite = SequenceComponent.new([
#   NoteComponent.new("F1", 2),
#   NoteComponent.new("F2", 2),
#   NoteComponent.new("F3", 2),
#   NoteComponent.new("F4", 2),
#   NoteComponent.new("F5", 2),
#   NoteComponent.new("F6", 2),
#   NoteComponent.new("F7", 2),
#   NoteComponent.new("F8", 2),
# ])

# composite = SequenceComponent.new([
#   NoteComponent.new("A1", 2),
#   NoteComponent.new("A2", 2),
#   NoteComponent.new("A3", 2),
#   NoteComponent.new("A4", 2),
#   NoteComponent.new("A5", 2),
#   NoteComponent.new("A6", 2),
#   NoteComponent.new("A7", 2),
#   NoteComponent.new("A8", 2),
# # ])

# composite = SequenceComponent.new([
#   NoteComponent.new("C4", 2),


#   # NoteComponent.new("C4", 2),
#   # NoteComponent.new("D4", 2),
#   # NoteComponent.new("E4", 2),
#   # NoteComponent.new("F4", 2),
#   # NoteComponent.new("G4", 2),
#   # NoteComponent.new("A4", 2),
#   # NoteComponent.new("B4", 2),

#   # NoteComponent.new("pause", 1),

#   # NoteComponent.new("C5", 2),
#   # NoteComponent.new("D5", 2),
#   # NoteComponent.new("E5", 2),
#   # NoteComponent.new("F5", 2),
#   # NoteComponent.new("G5", 2),
#   # NoteComponent.new("A5", 2),
#   # NoteComponent.new("B5", 2),

#   # NoteComponent.new("pause", 1),


#   # NoteComponent.new("C6", 2),
#   # NoteComponent.new("D6", 2),
#   # NoteComponent.new("E6", 2),
#   # NoteComponent.new("F6", 2),
#   # NoteComponent.new("G6", 2),
#   # NoteComponent.new("A6", 2),
#   # NoteComponent.new("B6", 2),

#   # NoteComponent.new("pause", 1),

#   # NoteComponent.new("C7", 2),
#   # NoteComponent.new("D7", 2),
#   # NoteComponent.new("E7", 2),
#   # NoteComponent.new("F7", 2),
#   # NoteComponent.new("G7", 2),
#   # NoteComponent.new("A7", 2),
#   # NoteComponent.new("B7", 2),

#   # NoteComponent.new("pause", 1),

#   # NoteComponent.new("C8", 2),
#   # NoteComponent.new("D8", 2),
#   # NoteComponent.new("E8", 2),
#   # NoteComponent.new("F8", 2),
#   # NoteComponent.new("G8", 2),
#   # NoteComponent.new("A8", 2),
#   # NoteComponent.new("B8", 2),


# ])

# # composite = SequenceComponent.new([
# #   NoteComponent.new("C7", 2),
# #   NoteComponent.new("D7", 2),
# #   NoteComponent.new("E7", 2),
# #   NoteComponent.new("F7", 2),
# #   NoteComponent.new("G7", 2),
# #   NoteComponent.new("A7", 2),
# #   NoteComponent.new("B7", 2),
# # ])

# # composite = SequenceComponent.new([
# #   NoteComponent.new("C8", 2),

# #   NoteComponent.new("D8", 2),

# #   NoteComponent.new("E8", 2),

# #   NoteComponent.new("F8", 2),

# #   NoteComponent.new("G8", 2),

# #   NoteComponent.new("A8", 2),

# #   NoteComponent.new("B8", 2),
# # ])

# # composite = SequenceComponent.new([
# #   NoteComponent.new("C6", 0.5),
# #   NoteComponent.new("C4", 0.5),
# #   NoteComponent.new("C3", 0.5),
# #   NoteComponent.new("pause", 0.5),

# #   NoteComponent.new("D6", 0.5),
# #   NoteComponent.new("D4", 0.5),
# #   NoteComponent.new("D3", 0.5),
# #   NoteComponent.new("pause", 0.5),

# #   NoteComponent.new("E6", 0.5),
# #   NoteComponent.new("E4", 0.5),
# #   NoteComponent.new("E3", 0.5),
# #   NoteComponent.new("pause", 0.5),

# # ])

# composite.play

# # composite = SequenceComponent.new([
# #   NoteComponent.new("C8", 2),
# #   NoteComponent.new("D8", 2),
# #   NoteComponent.new("E8", 2),
# #   NoteComponent.new("F8", 2),
# #   NoteComponent.new("G8", 2),
# #   NoteComponent.new("A8", 2),
# #   NoteComponent.new("B8", 2),

# # ])

# #maybe we can add another note component, wich is a composite because it can be play
# # a a cord maybe instead of note a playable composite
