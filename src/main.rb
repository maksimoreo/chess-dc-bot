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

uci_engine_path = ENV.fetch('CHESS_BOT_UCI_ENGINE_PATH', nil)
chess_ai_player = nil

if uci_engine_path.nil? || uci_engine_path.empty?
  logger.info('Initializing random move player')
  chess_ai_player = RandomMovePlayer.new
else
  logger.info("Initializing UCI player with executable: #{uci_engine_path}")
  chess_ai_player = UCIPlayer.new(uci_engine_path)
end

chess_bot = ChessBotTeamVsComputer.new(
  players_move_time: 10,
  computer_move_time: 5,
  chess_ai_player:,
  max_moves: 50,
  logger:
)

at_exit do
  logger.info('Closing chess player')

  chess_ai_player.invoke_quit

  logger.info('Closing Discord bot')

  chess_bot.send(:bot).stop

  logger.info('All done, bye!')
end

logger.info('Running bot')

chess_bot.run
