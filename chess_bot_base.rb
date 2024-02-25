require 'discordrb'

require_relative 'chess'
require_relative 'discord_config'

class GameBotBase
  attr_reader :bot

  def initialize(on_stop: nil,
    token: (DiscordConfig.const_defined?('DISCORD_BOT_TOKEN') ? DiscordConfig::DISCORD_BOT_TOKEN : ENV['DISCORD_BOT_TOKEN']),
    game_channel_id:, bot_admin_role_id: DiscordConfig::BOT_ADMIN_ROLE_ID,
    bot_admin_channel_id: DiscordConfig::BOT_ADMIN_CHANNEL_ID)

    @game_channel_id = game_channel_id
    @bot_admin_channel_id = bot_admin_channel_id
    @bot_admin_role_id = bot_admin_role_id
    @bot = Discordrb::Commands::CommandBot.new prefix: '!', token: token, channels: [game_channel_id, bot_admin_channel_id]

    @msg_accumulator = ''

    # Bot admin can stop the bot process
    @bot.command :shutdown, aliases: [:bot_stop, :stop_bot, :disconnect], allowed_roles: [@bot_admin_role_id], help_available: false do |event|
      puts "User #{event.user.distinct} stopped the bot."
      on_stop.call unless on_stop.nil?
      stop

      nil
    end

    # Bot admin can inspect object attributes (variables)
    @bot.command :read, aliases: [:variable, :var, :getvar], allowed_roles: [@bot_admin_role_id], help_available: false do |event, variable_name|
      puts "User #{event.user.distinct} asks to reveal variables value: #{variable_name}."
      if variable_name.nil? || variable_name.empty?
        say_admin "Usage: !variable <variable name>"
      else
        begin
          variable_value = instance_variable_get("@#{variable_name}")

          if variable_value.nil?
            say_admin "This variable is nil"
          elsif variable_value.is_a?(String) && variable_value.empty?
            say_admin 'This variable holds an emtpy string'
          else
            say_admin variable_value.to_s
          end
        rescue NameError
          say_admin "invalid variable name (don't include @)"
        end
      end

      nil
    end

    @bot.command :set, aliases: [:setvar], allowed_roles: [@bot_admin_role_id], help_available: false,
      arg_types: [String] do |event, variable_name, value|
      puts "User #{event.user.distinct} asks to change variable: #{variable_name}."
      if variable_name.nil? || variable_name.empty? || value.nil? || value.empty?
        say_admin "Usage: !variable <variable name> <value>"
      else
        begin
          instance_variable_set("@#{variable_name}", value)
          say_admin "changed variable ```#{variable_name}``` to ```#{value}```"
        rescue NameError
          say_admin "invalid variable name (don't include @)"
        end
      end

      nil
    end

    @bot.command :setint, aliases: [:setvarint, :setintvar], allowed_roles: [@bot_admin_role_id],
      help_available: false, arg_types: [String, Integer] do |event, variable_name, value|
      puts "User #{event.user.distinct} asks to change variable: #{variable_name}."
      if variable_name.nil? || variable_name.empty? || value.nil?
        say_admin "Usage: !variable <variable name> <value>"
      else
        begin
          instance_variable_set("@#{variable_name}", value)
          say_admin "changed variable ```#{variable_name}``` to ```#{value}```"
        rescue NameError
          say_admin "invalid variable name (don't include @)"
        end
      end

      nil
    end
  end

  def run
    say_admin p "Bot started at #{Time.now}"
    @bot.run
  end

  def stop
    say_admin p "Bot stopped at #{Time.now}"
    @bot.stop
  end

  def say(message)
    bot.send_message @game_channel_id, message unless message.nil? || message.empty?
  end

  def say!(message)
    raise ArgumentError('message cannot be empty') if message.nil? || message.empty?
    bot.send_message @game_channel_id, message
  end

  def say_admin(message)
    raise ValueError('message cannot be empty') if message.nil? || message.empty?
    bot.send_message @bot_admin_channel_id, message
  end

  def accumulate_msg(message)
    @msg_accumulator += message
  end

  def say_accumulated_msg(additional_msg = nil)
    accumulate_msg additional_msg unless additional_msg.nil?
    say @msg_accumulator
    @msg_accumulator = ''
  end

  def reset_msg_accumulator
    @msg_accumulator = ''
  end
end

class ChessBotBase < GameBotBase
  attr_reader :chess_game
  attr_reader :max_moves

  def initialize(max_moves: 50, **args)
    super **args

    # User sends a chess move
    @bot.message start_with: ChessMove.regex, in: @channel_id do |event|
      on_move_message(event.user, ChessMove.from_s(event.content))
      nil
    end

    # User can send move with '!move <move>', this command is defined mostly to
    # be seen from !help command
    @bot.command :move, aliases: [:go] do |move_text|
      if move_text.nil? || move_text.empty?
        say 'Usage: !move <move>, e.g.: !move e2e4'
      end

      on_move_message(event.user, ChessMove.from_s(move_text))
      nil
    end

    @chess_game = nil
    @max_moves = max_moves
  end

  def start_chess_game(white_player: nil, black_player: nil)
    @chess_game = ChessGame.new(white_player: white_player,
      black_player: black_player, max_moves: max_moves)
  end

  def end_chess_game
    @chess_game.uninitialize
    @chess_game = nil
  end

  def chess_game_state
    @chess_game.state
  end

  def send_chessboard(message)
    @chess_game.send_chessboard(@bot, @game_channel_id, message)
  end

  def send_chessboard_with_msg_accumulator(additional_msg = nil)
    accumulate_msg additional_msg unless additional_msg.nil?
    send_chessboard @msg_accumulator
    reset_msg_accumulator
  end

  # Game hasn't been started yet
  def game_going?
    !@chess_game.nil?
  end

  # Game was started and ended by now
  def game_end?
    @chess_game.end?
  end
end
