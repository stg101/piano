require_relative "../interpreter/interpreter"

class AudioTree
  attr_reader :state, :component_tree

  def initialize
    @state = UninitializedState.new(self)
    @component_tree = nil
  end

  def set_state(state)
    @state = state
  end

  def expr(expression)
    state.expr(expression)
  end

  def play
    state.play
  end

  def print
    state.print
  end

  def save(name)
    state.save(name)
  end

  def load(name)
    state.load(name)
  end

  def restart
    state.restart
  end
end

class State
  attr_reader :context

  def initialize(context)
    @context = context
  end

  def expr(expression)
    interpreter = Interpreter.new
    expr_tree = interpreter.interpret(expression)
    context.component_tree = expr_tree.build
    context.set_state(InitializedState.new(context))
  end

  def play
    raise NotImplementedError
  end

  def print
    raise NotImplementedError
  end

  def save(name)
    raise NotImplementedError
  end

  #TODO: implement
  def load(name)
    "not implemented yet"
  end

  def restart
    context.set_state(UninitializedState.new(context))
  end
end

class UninitializedState < State
  def play
    raise "Audio tree is not initialized"
  end

  def print
    raise "Audio tree is not initialized"
  end

  def save(name)
    raise "Audio tree is not initialized"
  end
end

class InitializedState < State
  def play
    context.component_tree.play
  end

  #TODO: implement
  def print
    "not implemented yet"
  end

  def save
    "not implemented yet"
  end
end
