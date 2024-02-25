# the very minimal bot to test if bot works and can connect to the internet
# Run:
# DISCORD_BOT_TOKEN=12345 ruby test.rb

require 'discordrb'

bot = Discordrb::Bot.new token: ENV['DISCORD_BOT_TOKEN']

at_exit { bot.stop }

puts 'Registering "Ping!" command'
bot.message(content: 'Ping!') do |event|
  puts 'received ping'
  event.respond 'Pong!'
end

puts 'Running the bot'
bot.run

puts 'The end'
