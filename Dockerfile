FROM ruby:2.7.1-buster

ARG RACK_ENV
RUN mkdir /18xx
WORKDIR /18xx

COPY Gemfile Gemfile.lock ./
RUN if [ "$RACK_ENV" = "production" ]; \
    then bundle install --without test development; \
    else bundle install; \
    fi
COPY . .

CMD bundle exec rake dev_up && \
    bundle exec rerun --background -i 'build/*' -i 'public/*' 'puma'
