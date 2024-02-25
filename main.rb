require_relative 'discord_config'
require_relative 'team_vs_computer_bot'

require_relative 'players/uci_player/uci_player'
require_relative 'players/random_move_player'

chess_ai = RandomMovePlayer.new
# chess_ai = UCIPlayer.new DiscordConfig::UCI_ENGINE_PATH # , ['setoption name UCI_LimitStrength value 1']

cbot = ChessBotTeamVsComputer.new players_move_time: 10, computer_move_time: 5, chess_ai: chess_ai, max_moves: 50
at_exit { cbot.send(:bot).stop }
cbot.run

chess_ai.invoke_quit
