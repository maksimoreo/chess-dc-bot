# frozen_string_literal: true

# the very minimal bot to test if bot works and can connect to the internet
# Run:
# CHESS_BOT_DISCORD_TOKEN=12345 ruby test.rb

require 'discordrb'

bot = Discordrb::Bot.new token: ENV.fetch('CHESS_BOT_DISCORD_TOKEN')

at_exit { bot.stop }

puts 'Registering "Ping!" command'
bot.message(content: 'Ping!') do |event|
  puts 'received ping'
  event.respond 'Pong!'
end

puts 'Running the bot'
bot.run

puts 'The end'
