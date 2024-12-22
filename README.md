# Discord Chess Bot built with Ruby

Created at December 29th, 2020

Demo:

![Chess bot demo GIF](demo.gif)

# Usage

First install required gems (see Gemfile for dependencies):

```sh
bundle install
```

Define environment variables (all required):

```sh
# Discord token
CHESS_BOT_DISCORD_TOKEN = ""

# Channel ID, where players can interact with the bot
CHESS_BOT_GAME_CHANNEL_ID = ""

# Roles that can do administration with the bot
CHESS_BOT_ADMIN_ROLE_ID = ""

# Channel ID, where bot will write logs
CHESS_BOT_ADMIN_CHANNEL_ID = ""
```

Finally you can run the bot:

```sh
ruby src/main.rb
```

The bot is now online. Start the game with `!play` command and send moves with `!move e2e4`.

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
