FROM ruby:2.7.1-buster

ARG RACK_ENV
RUN mkdir /18xx
WORKDIR /18xx

COPY Gemfile Gemfile.lock ./
RUN if [ "$RACK_ENV" = "production" ]; \
    then bundle config set without 'test development'; \
    fi; \
    bundle install
COPY . .

CMD bundle exec rake db_up && \
    bundle exec puma
