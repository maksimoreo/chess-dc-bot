# frozen_string_literal: true

require 'logger'

logger = Logger.new($stdout)

require 'dotenv'
Dotenv.load

puts 'Environment:'
puts
puts "CHESS_BOT_DISCORD_TOKEN: #{ENV.fetch('CHESS_BOT_DISCORD_TOKEN')}"
puts "CHESS_BOT_GAME_CHANNEL_ID: #{ENV.fetch('CHESS_BOT_GAME_CHANNEL_ID')}"
puts "CHESS_BOT_ADMIN_ROLE_ID: #{ENV.fetch('CHESS_BOT_ADMIN_ROLE_ID')}"
puts "CHESS_BOT_ADMIN_CHANNEL_ID: #{ENV.fetch('CHESS_BOT_ADMIN_CHANNEL_ID')}"
puts

logger.info('Loading code')

require_relative 'chess_bot_team_vs_computer'
require_relative 'players/uci_player/uci_player'
require_relative 'players/random_move_player'

logger.info('Initializing code')

chess_ai = RandomMovePlayer.new
# # chess_ai = UCIPlayer.new DiscordConfig::UCI_ENGINE_PATH # , ['setoption name UCI_LimitStrength value 1']

cbot = ChessBotTeamVsComputer.new(
  players_move_time: 10,
  computer_move_time: 5,
  chess_ai:,
  max_moves: 50,
  logger:
)
at_exit { cbot.send(:bot).stop }

logger.info('Running bot')

cbot.run

logger.info('Closing')

chess_ai.invoke_quit
