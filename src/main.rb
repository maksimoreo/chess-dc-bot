# frozen_string_literal: true

require 'logger'

logger = Logger.new($stdout)

logger.info('CHESS BOT')
logger.info('Loading')

require 'dotenv'
Dotenv.load

require_relative 'chess_bot_builder'

chess_bot = ChessBotBuilder.new(logger:).build

at_exit do
  logger.info('Closing')

  logger.info("running: #{chess_bot.running?}")

  chess_bot.stop if chess_bot.running?

  logger.info('All done, bye!')
end

logger.info('Running bot')

chess_bot.run
