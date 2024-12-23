FROM ruby:3.2.1

WORKDIR /chess_bot

COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY . .

CMD ["ruby", "./src/main.rb"]
