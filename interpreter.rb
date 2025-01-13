require "./tokenizer.rb"
require "./component.rb"

# pitch: 'c'| 'd' | ... | 'b' + (' '' ''' , ,, ,,,)?
# duration: 1 | 2 | 4 | 8 | 16
# note: pitch + duration
# duration_altered_chord: '<' + note* + '>'
# standard_chord: '<' + pitch* + '>' + duration
# chord: standard_chord | duration_altered_chord
# sequence: '(' + playable* + ')'
# repetition: playable + 'x' + number
# playable: note | chord | sequence | repetition

class Expr
  def build
    raise NotImplementedError
  end
end

class PitchExpr < Expr
  attr_reader :tone, :octave

  def initialize(tone, octave = 4)
    @tone = tone
    @octave = octave
  end

  def build
    NoteComponent.new(to_s, 1.0)
  end

  def to_s
    "#{tone.upcase}#{octave}"
  end
end

class NoteExpr < Expr
  attr_reader :pitch, :duration

  def initialize(pitch, duration)
    @pitch = pitch
    @duration = duration
  end

  def build
    NoteComponent.new(pitch, 4.0 / duration.to_i)
  end
end

class ChordExpr < Expr
  attr_accessor :children, :duration

  def initialize(children, duration = 4)
    @children = children
    @duration = duration
  end

  def build
    ChordComponent.new(children.map(&:build), 4.0 / duration.to_i)
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
        stack << PitchExpr.new(token.value)
      when QuoteGroupToken
        if stack.last.is_a?(PitchExpr)
          last_expr = stack.pop
          stack << PitchExpr.new(
            last_expr.tone,
            last_expr.octave + token.value
          )
        else
          raise "QuoteGroup should be after a pitch"
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
          stack << NoteExpr.new(last_expr.to_s, token.value.to_i)
        elsif last_expr.is_a?(ChordExpr)
          stack.pop
          stack << ChordExpr.new(last_expr.children, token.value)
        elsif last_expr.is_a?(CrossToken) && stack[-2].is_a?(Expr)
          raise "Not enough args for repetition" if stack.length <= 1
          stack.pop
          last_expr = stack.pop
          stack << RepetitionExpr.new(last_expr, token.value)
        end
      end
    end

    stack.pop
  end
end

interpreter = Interpreter.new
# parsed = interpreter.interpret("(<c d>2 c'x20 c'')")
parsed = interpreter.interpret("(<c2 d4>)")

pp parsed
composite = parsed.build
pp(composite)

composite.play
# test irregular chord