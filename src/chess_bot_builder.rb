# frozen_string_literal: true

require_relative 'chess_bot_team_vs_computer'
require_relative 'players/uci_player/uci_player'
require_relative 'players/random_move_player'

# Reads configuration and prepares chess bot
class ChessBotBuilder
  def initialize(logger:)
    @logger = logger
  end

  def build
    players_move_time = fetch_players_move_time_seconds
    chess_ai_player = build_chess_ai_player

    ChessBotTeamVsComputer.new(
      players_move_time:,
      computer_move_time: 5,
      chess_ai_player:,
      max_moves: 50,
      logger:
    )
  end

  private

  attr_reader :logger

  def build_chess_ai_player
    uci_engine_path = fetch_env('CHESS_BOT_UCI_ENGINE_PATH')

    if uci_engine_path.nil? || uci_engine_path.empty?
      logger.info('Initializing random move player')
      return RandomMovePlayer.new
    end

    logger.info("Initializing UCI player with executable: #{uci_engine_path}")

    options = fetch_uci_player_options
    UCIPlayer.new(uci_engine_path, options:)
  end

  def fetch_uci_player_options
    skill_level = ENV.fetch('CHESS_BOT_SKILL_LEVEL', nil)

    return if skill_level.nil? || skill_level.empty?

    skill_level = skill_level.to_i.clamp(0, 20)

    logger.info("CHESS_BOT_SKILL_LEVEL = #{skill_level}")

    [['Skill Level', skill_level]]
  end

  def fetch_players_move_time_seconds
    fetch_env('CHESS_BOT_PLAYERS_MOVE_TIME_SECONDS', default: 20)
  end

  def fetch_env(variable_name, default: nil)
    value = ENV.fetch(variable_name, default)
    logger.info("#{variable_name}=#{value}")
    value
  end
end
