FROM ruby:3.2

ARG RACK_ENV
RUN mkdir /18xx
WORKDIR /18xx
RUN git config --global --add safe.directory /18xx

RUN if [ "$RACK_ENV" = "development" ]; \
    then \
      ARCH=$(uname -m); \
      if [ "$ARCH" = "aarch64" ]; then \
        ESBUILD_PKG="esbuild-linux-arm64"; \
      else \
        ESBUILD_PKG="esbuild-linux-64"; \
      fi; \
      curl -s https://registry.npmjs.org/${ESBUILD_PKG}/-/${ESBUILD_PKG}-0.14.36.tgz | tar xz; \
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
