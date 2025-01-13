# class ForwardIterationStrategy
#   def next()
#   end
# end

# class ForwardIterator
#   attr_reader :index, :component

#   def initialize(audio_component)
#     @index = 0
#     @component = audio_component
#   end

#   def each
#     while (index < component.length)
#       yield component.children[i]
#       i += 1
#     end
#   end
# end

# class NestedIterator
#   def initialize(tree, iteration_strategy)
#   end

#   def each
#   end
# end

# NestedIterator.new(tree, ForwardIterationStrategy.new)

require "./component.rb"

class InOrderIterator
  attr_reader :composite

  def initialize(composite)
    @composite = composite
  end

  def each(&block)
    block.call(composite)

    composite.children.each do |child|
      InOrderIterator.new(child).each(&block)
    end
  end
end

class Visitor
  def visit(composite)
    puts composite.item
  end
end

composite = SequenceComponent.new([NoteComponent.new("a"), NoteComponent.new("b")])
iterator = InOrderIterator.new(composite)
visitor = Visitor.new

iterator.each do |item|
  item.accept(visitor)
end
