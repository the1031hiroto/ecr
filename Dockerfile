FROM ruby:3.1.2-slim

RUN apt-get update -qq && apt-get install -y build-essential libpq-dev postgresql-client-13

WORKDIR /work

COPY Gemfile Gemfile
# COPY Gemfile.lock Gemfile.lock
RUN bundle install

EXPOSE 3000

CMD ["bundle", "exec", "rails", "s", -"p", "3000", "-b", "0.0.0.0"]
