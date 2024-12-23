# Discord Chess Bot built with Ruby

Discord bot to play chess with.

![Video demonstration of chess bot](demo.gif)

Features:

- ✋ Vote system where players vote for their next move
- 🤖 Integration with a chess engine (like [Stockfish](https://stockfishchess.org/)) using [UCI protocol](https://en.wikipedia.org/wiki/Universal_Chess_Interface)
- 🖼️ Chessboard image generation using [ImageMagick](https://imagemagick.org/index.php)

Created at December 29th, 2020

# Usage

First install required gems (see Gemfile for dependencies):

```sh
bundle install
```

Define environment variables (all required):

```sh
# Discord token
CHESS_BOT_DISCORD_TOKEN=""

# Channel ID, where players can interact with the bot
CHESS_BOT_GAME_CHANNEL_ID=""

# Roles that can do administration with the bot
CHESS_BOT_ADMIN_ROLE_ID=""

# Channel ID, where bot will write logs
CHESS_BOT_ADMIN_CHANNEL_ID=""
```

See `.env.example` for complete list of available environment variables.

Finally you can run the bot:

```sh
ruby src/main.rb
```

The bot is now online. In Discord, start the game with `!play` command and send moves with `!move e2e4`.

## Stockfish

To use with Stockfish define these environment variables:

```sh
# Path to UCI engine executable, like Stockfish. If not specified, bot will move randomly.
CHESS_BOT_UCI_ENGINE_PATH="stockfish"

# Set skill level for Stockfish in range [0, 20]
# See: https://official-stockfish.github.io/docs/stockfish-wiki/UCI-&-Commands.html#setoption
CHESS_BOT_SKILL_LEVEL=5
```

Bot will spawn separate process (specified by `CHESS_BOT_UCI_ENGINE_PATH` environment variable) and communicate with it using UCI protocol through stdin / stdout. Engine process will be kept for the duration of main process lifetime.

## Docker

```sh
# Build
docker build --tag chess_bot:v1 .

# Run
docker run -it --rm \
    --name chess_bot \
    --env CHESS_BOT_DISCORD_TOKEN="" \
    --env CHESS_BOT_GAME_CHANNEL_ID="" \
    --env CHESS_BOT_ADMIN_ROLE_ID="" \
    --env CHESS_BOT_ADMIN_CHANNEL_ID="" \
    chess_bot:v1
```

### With Stockfish

Script will download Stockfish source code and compile it. Skill level can be controlled with `CHESS_BOT_SKILL_LEVEL` environment variable. No need to specify `CHESS_BOT_UCI_ENGINE_PATH` environment variable.

```sh
# Build
docker build --tag chess_bot:stockfish-v1 --file Dockerfile.Stockfish .

# Run
docker run -it --rm \
    --name chess_bot \
    --env CHESS_BOT_DISCORD_TOKEN="" \
    --env CHESS_BOT_GAME_CHANNEL_ID="" \
    --env CHESS_BOT_ADMIN_ROLE_ID="" \
    --env CHESS_BOT_ADMIN_CHANNEL_ID="" \
    chess_bot:stockfish-v1
```
