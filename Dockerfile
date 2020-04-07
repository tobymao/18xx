FROM ruby:2.7.1-buster

RUN mkdir /18xx
WORKDIR /18xx

# system dependencies for pg gem
RUN apt-get update && \
    apt-get install -y libpq-dev

COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY . .

# sleep to give the database time
# TODO: see https://docs.docker.com/compose/startup-order/ for other links on
# properly waiting for the db to be ready
CMD sleep 10 && \
    bundle exec rake dev_up && \
    bundle exec rerun --background -i 'build/*' -i 'public/*' 'puma -t 0:128 --bind tcp://0.0.0.0:9292'
