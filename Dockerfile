FROM ruby:3.1.2-slim

RUN apt-get update -qq && apt-get install -y build-essential libpq-dev postgresql-client-13

WORKDIR /work

COPY Gemfile Gemfile
RUN bundle install
COPY . /work/

EXPOSE 3000

CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]
