# frozen_string_literal: true

require 'discordrb'

require_relative 'chess_game'

class GameBotBase
  attr_reader :bot

  def initialize(
    logger:,
    game_channel_id:,
    token: ENV.fetch('CHESS_BOT_DISCORD_TOKEN'),
    bot_admin_role_id: ENV.fetch('CHESS_BOT_ADMIN_ROLE_ID'),
    bot_admin_channel_id: ENV.fetch('CHESS_BOT_ADMIN_CHANNEL_ID')
  )
    @logger = logger

    @game_channel_id = game_channel_id
    @bot_admin_channel_id = bot_admin_channel_id
    @bot_admin_role_id = bot_admin_role_id
    @bot = Discordrb::Commands::CommandBot.new prefix: '!', token: token,
                                               channels: [game_channel_id, bot_admin_channel_id]

    @msg_accumulator = ''

    # Bot admin can stop the bot process
    @bot.command :shutdown, aliases: %i[bot_stop stop_bot disconnect], allowed_roles: [@bot_admin_role_id],
                            help_available: false do |event|
      puts "#{Time.now.utc} User #{event.user.distinct} stopped the bot."
      stop

      nil
    end

    # Bot admin can inspect object attributes (variables)
    @bot.command :read, aliases: %i[variable var getvar], allowed_roles: [@bot_admin_role_id],
                        help_available: false do |event, variable_name|
      puts "User #{event.user.distinct} asks to reveal variables value: #{variable_name}."
      if variable_name.nil? || variable_name.empty?
        say_admin 'Usage: !variable <variable name>'
      else
        begin
          variable_value = instance_variable_get("@#{variable_name}")

          if variable_value.nil?
            say_admin 'This variable is nil'
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
        say_admin 'Usage: !variable <variable name> <value>'
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

    @bot.command :setint, aliases: %i[setvarint setintvar], allowed_roles: [@bot_admin_role_id],
                          help_available: false, arg_types: [String, Integer] do |event, variable_name, value|
      puts "User #{event.user.distinct} asks to change variable: #{variable_name}."
      if variable_name.nil? || variable_name.empty? || value.nil?
        say_admin 'Usage: !variable <variable name> <value>'
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
