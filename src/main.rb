# frozen_string_literal: true

require 'logger'

logger = Logger.new($stdout)

require 'dotenv'
Dotenv.load

logger.info('Loading code')

require_relative 'chess_bot_team_vs_computer'
require_relative 'players/uci_player/uci_player'
require_relative 'players/random_move_player'

logger.info('Initializing code')

chess_ai_player = RandomMovePlayer.new
# # chess_ai = UCIPlayer.new DiscordConfig::UCI_ENGINE_PATH # , ['setoption name UCI_LimitStrength value 1']

chess_bot = ChessBotTeamVsComputer.new(
  players_move_time: 10,
  computer_move_time: 5,
  chess_ai_player:,
  max_moves: 50,
  logger:
)
at_exit { chess_bot.send(:bot).stop }

logger.info('Running bot')

chess_bot.run

logger.info('Closing')

chess_ai_player.invoke_quit
