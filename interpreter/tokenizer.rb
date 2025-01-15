class Token
  def value
    raise NotImplementedError
  end

  def to_s
    value.to_s
  end
end

class OpenAngleBracketToken < Token
  def value
    "<"
  end
end

class CloseAngleBracketToken < Token
  def value
    ">"
  end
end

class OpenParenthesisToken < Token
  def value
    "("
  end
end

class CloseParenthesisToken < Token
  def value
    ")"
  end
end

class NumberToken < Token
  attr_reader :value

  def initialize(number)
    @value = number
  end
end

class PitchToken < Token
  attr_reader :value

  def initialize(char)
    @value = char
  end
end

class CrossToken < Token
  def value
    "x"
  end
end

class SpaceToken < Token
  def value
    " "
  end
end

class QuoteGroupToken < Token
  attr_reader :value

  def initialize(value = 1)
    @value = value
  end
end

class DotGroupToken < Token
  attr_reader :value

  def initialize(value = 1)
    @value = value
  end
end

class Tokenizer
  def tokenize(text)
    stack = []

    text.each_char do |char|
      case char
      when /[cdefgab]/
        stack << PitchToken.new(char)
      when /[0-9]/
        if stack.last.is_a?(NumberToken)
          last_token = stack.pop
          stack << NumberToken.new(last_token.value.to_s + char)
        else
          stack << NumberToken.new(char)
        end
      when "'"
        if stack.last.is_a?(QuoteGroupToken)
          last_token = stack.pop
          stack << QuoteGroupToken.new(last_token.value + 1)
        else
          stack << QuoteGroupToken.new
        end
      when "."
        if stack.last.is_a?(DotGroupToken)
          last_token = stack.pop
          stack << DotGroupToken.new(last_token.value + 1)
        else
          stack << DotGroupToken.new
        end
      when "x"
        stack << CrossToken.new
      when "<"
        stack << OpenAngleBracketToken.new
      when ">"
        stack << CloseAngleBracketToken.new
      when "("
        stack << OpenParenthesisToken.new
      when ")"
        stack << CloseParenthesisToken.new
      when /\s/
        stack << SpaceToken.new
      else
        raise "Unknown character: #{char}"
      end
    end

    stack
  end

  def tokens
    stack
  end
end

# tokenizer = Tokenizer.new()
# puts tokenizer.tokenize("(<c d>2 c'x20 c'')")
