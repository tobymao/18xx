FROM ruby:2.7.0-alpine

RUN mkdir /18xx
WORKDIR /18xx

# system dependencies for pg gem
RUN apk --update add --virtual build_deps build-base postgresql-dev

COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY . .

CMD bundle exec rake dev_up && \
    bundle exec rerun --background -i 'build/*' -i 'public/*' 'rackup -o 0.0.0.0 -I lib/'
