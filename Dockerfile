FROM ruby:3.0

ARG RACK_ENV
RUN mkdir /18xx
WORKDIR /18xx

RUN if [ "$RACK_ENV" = "development" ]; \
    then \
      curl -s https://registry.npmjs.org/esbuild-linux-64/-/esbuild-linux-64-0.8.42.tgz | tar xz; \
      mv package/bin/esbuild /usr/local/bin && rm -rf package; \
    fi;

COPY Gemfile Gemfile.lock ./
RUN if [ "$RACK_ENV" = "production" ]; \
    then bundle config set without 'test development'; \
    fi; \
    bundle install;
COPY . .

CMD bundle exec rake dev_up && \
    bundle exec rerun --background -i 'build/*' -i 'public/*' 'unicorn -c config/unicorn.rb'
