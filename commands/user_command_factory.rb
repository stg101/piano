require_relative "user_command"

# This looks kind of useless because is a small project.
class UserCommandFactory
  attr_reader :audio_tree

  def initialize(audio_tree)
    @audio_tree = audio_tree
  end

  def make_command(input)
    command, args_str = input.split(" ", 2)

    case command
    when "expr"
      make_expr_command(args_str)
    when "play"
      make_play_command
    when "print"
      make_print_command
    when "save"
      make_set_command
    when "load"
      make_load_command
    when "restart"
      make_restart_command
    when "set_option"
      make_set_option_command(args_str)
    when "null"
      make_null_command
    else
      NullCommand.new
    end
  end

  def make_expr_command(args_str)
    ExprCommand.new(audio_tree, args_str)
  end

  def make_play_command
    PlayCommand.new(audio_tree)
  end

  def make_print_command
    PrintCommand.new(audio_tree)
  end

  def make_save_command
    SaveCommand.new(audio_tree)
  end

  def make_load_command
    LoadCommand.new(audio_tree)
  end

  def make_set_option_command(args_str)
    setting, value = args_str.split(" ", 2)

    case setting
    when "bpm"
      SetBpmCommand.new(value)
    when "time_signature"
      SetTimeSignatureCommand.new(value.split("/"))
    else
      NullCommand.new
    end
  end

  def make_restart_command
    RestartCommand.new(audio_tree)
  end

  def make_null_command
    NullCommand.new(audio_tree)
  end
end
