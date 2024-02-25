# Discord Chess Bot built with Ruby

Created at December 29th, 2020

Demo:

![Chess bot demo GIF](demo.gif)

# Usage

First install required gems (see Gemfile for dependencies):

```sh
bundle install
```

Create discord_config.rb file and fill your values:

```ruby
module DiscordConfig
  DISCORD_BOT_TOKEN =           1111
  CHANNEL_ID_TEAM_VS_COMPUTER = 1111
  BOT_ADMIN_ROLE_ID =           1111
  BOT_ADMIN_CHANNEL_ID =        1111
end
```

Finally you can run the bot:

```sh
ruby main.rb
```
