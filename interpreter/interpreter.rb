require_relative "tokenizer"
require_relative "../component"
require_relative "../errors"

class Expr
  def build
    raise NotImplementedError
  end
end

class SoundModifierExpr < Expr
  def initialize()
  end
end

class SoundExpr < Expr
  def duration
    raise NotImplementedError
  end
end

class PitchExpr < SoundExpr
  attr_accessor :pitch

  def initialize(pitch)
    @pitch = pitch
  end

  def build(default_duration = Duration.new)
    NoteComponent.new(pitch, default_duration)
  end
end

class NoteExpr < SoundExpr
  attr_accessor :pitch, :duration

  def initialize(pitch, duration = nil)
    @pitch = pitch
    @duration = duration
  end

  def build(default_duration = Duration.new)
    NoteComponent.new(pitch, duration || default_duration || Duration.new)
  end
end

class ChordExpr < SoundExpr
  attr_accessor :children, :duration

  def initialize(children, duration = nil)
    @children = children
    @duration = duration
  end

  def build
    notes = children.map { |note_expr| note_expr.build(duration) }
    ChordComponent.new(notes)
  end
end

class SequenceExpr < Expr
  attr_accessor :children

  def initialize(children)
    @children = children
  end

  def build
    SequenceComponent.new(children.map(&:build))
  end
end

class RepetitionExpr < Expr
  attr_reader :expr, :count

  def initialize(expr, count)
    @expr = expr
    @count = count
  end

  def build
    RepeatComponent.new(expr.build, count.to_i)
  end
end

class Interpreter
  class InterpreterError < ApplicationError; end
  class SyntaxError < InterpreterError; end

  attr_reader :tokenizer

  def initialize
    @tokenizer = Tokenizer.new
  end

  def interpret(text)
    tokens = tokenizer.tokenize(text)
    build_expr_tree(tokens)
  end

  def build_expr_tree(tokens)
    stack = []
    tokens.each do |token|
      case token
      when OpenAngleBracketToken,
           CrossToken,
           OpenParenthesisToken
        stack << token
      when PitchToken
        stack << PitchExpr.new(Pitch.new(token.value))
      when QuoteGroupToken
        if stack.last.is_a?(PitchExpr)
          last_expr = stack.pop
          last_pitch = last_expr.pitch
          stack << PitchExpr.new(Pitch.new(
            last_pitch.tone,
            last_pitch.octave + token.value
          ))
        else
          raise SyntaxError, "QuoteGroup should be after a pitch"
        end
      when CloseParenthesisToken
        args = []

        while true
          arg = stack.pop

          if arg.instance_of?(OpenParenthesisToken)
            stack << SequenceExpr.new(args.reverse)
            break
          else
            args << arg
          end
        end
      when CloseAngleBracketToken
        args = []

        while true
          arg = stack.pop

          if arg.instance_of?(OpenAngleBracketToken)
            stack << ChordExpr.new(args.reverse)
            break
          else
            args << arg
          end
        end
      when NumberToken
        last_expr = stack.last
        if last_expr.is_a?(PitchExpr)
          stack.pop
          duration = Duration.new(token.value.to_f)
          stack << NoteExpr.new(last_expr.pitch, duration)
        elsif last_expr.is_a?(ChordExpr)
          stack.last.duration = Duration.new(token.value.to_f)
        elsif last_expr.is_a?(CrossToken) && stack[-2].is_a?(Expr)
          raise SyntaxError, "Not enough args for repetition" if stack.length <= 1
          stack.pop
          last_expr = stack.pop
          stack << RepetitionExpr.new(last_expr, token.value)
        end
      end
    end

    if stack.length > 1
      raise SyntaxError, "Bad expression"
    end

    stack.pop
  end
end

# interpreter = Interpreter.new
# # # parsed = interpreter.interpret("(<c d4>2 c'x20 c'')")
# # parsed = interpreter.interpret("(<c a4>2 c'20x4 c'')")
# parsed = interpreter.interpret("(<c a4>2 c'20x4 c''")


# # # parsed = interpreter.interpret("(<c2 d4>)")

# pp parsed
# composite = parsed.build
# pp(composite)

# # composite.play
# # # test irregular chord
