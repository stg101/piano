class UserCommand
  def execute
    raise NotImplementedError
  end
end

class SetOptionCommand < UserCommand
  attr_reader :value

  def initialize(value)
    @value = value
  end
end

class SetBpmCommand < SetOptionCommand
  def execute
    Options.instance.bpm = value
    return true
  end
end

class SetTimeSignatureCommand < SetOptionCommand
  def execute
    Options.instance.time_signature = value
    return true
  end
end

class AudioTreeCommand < UserCommand
  attr_reader :audio_tree

  def initialize(audio_tree)
    @audio_tree = audio_tree
  end
end

class ExprCommand < AudioTreeCommand
  attr_reader :expression

  def initialize(audio_tree, expression)
    super(audio_tree)
    @expression = expression
  end

  def execute
    audio_tree.expr(expression)
    return true
  end
end

class PlayCommand < AudioTreeCommand
  def execute
    audio_tree.play
    return true
  end
end

class PrintCommand < AudioTreeCommand
  def execute
    audio_tree.print
    return true
  end
end

class SaveCommand < AudioTreeCommand
  def execute
    audio_tree.save
    return true
  end
end

class LoadCommand < AudioTreeCommand
  def execute
    audio_tree.load
    return true
  end
end

class RestartCommand < AudioTreeCommand
  def execute
    audio_tree.restart
    return true
  end
end

class NullCommand < UserCommand
  def execute
    return true
  end
end
