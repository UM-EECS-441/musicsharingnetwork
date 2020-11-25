# Dockerfile

FROM ruby:2.6.3

WORKDIR /code
COPY . /code

RUN bundle install

EXPOSE 8080

CMD ["ruby", "spotify_token_swap.rb"]