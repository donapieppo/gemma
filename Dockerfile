# syntax = docker/dockerfile:1

ARG RUBY_VERSION=3.4

LABEL org.opencontainers.image.authors="Pietro Donatini <pietro.donatini@unibo.it>"
LABEL org.opencontainers.image.description="Gemma"
LABEL org.opencontainers.image.source="https://github.com/donapieppo/gemma"

# BASE
FROM registry.docker.com/library/ruby:${RUBY_VERSION}-slim AS base

WORKDIR /rails

ENV LANG=C.UTF-8 \
    BUNDLE_PATH=/usr/local/bundle \
    BUNDLE_JOBS=4 \
    BUNDLE_RETRY=3

RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
      default-libmysqlclient-dev \
      fonts-jetbrains-mono \
      libjemalloc2 \
      libvips && \
    rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/*

# NODE-BASE
FROM base AS node-base

ARG NODE_VERSION=22.22.2
ARG YARN_VERSION=1.22.22
ENV PATH=/usr/local/node/bin:$PATH

RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
      build-essential \
      curl \
      git \
      libyaml-dev \
      node-gyp \
      pkg-config \
      python-is-python3 \
      xz-utils && \
    rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/*

RUN curl -sL https://github.com/nodenv/node-build/archive/master.tar.gz | tar xz -C /tmp/ && \
    /tmp/node-build-master/bin/node-build ${NODE_VERSION} /usr/local/node && \
    npm install -g yarn@"${YARN_VERSION}" && \
    rm -rf /tmp/node-build-master

# GEMS-DEV
FROM node-base AS gems-dev

ENV RAILS_ENV=development

COPY Gemfile Gemfile.lock ./
RUN bundle install

# ASSETS-DEV
FROM node-base AS assets-dev

COPY package.json yarn.lock ./
RUN yarn install --frozen-lockfile

# DEVELOPMENT
FROM node-base AS development

ENV RAILS_ENV=development \
    NODE_ENV=development

COPY Gemfile Gemfile.lock package.json yarn.lock ./
COPY --from=gems-dev /usr/local/bundle /usr/local/bundle
COPY --from=assets-dev /rails/node_modules /rails/node_modules
RUN gem install foreman --no-document

COPY . .
RUN yarn build && yarn build:css

RUN useradd --create-home --shell /bin/bash rails && \
    chown -R rails:rails /rails /usr/local/bundle
USER rails

ENTRYPOINT ["./docker/entrypoint.sh"]
CMD ["./bin/dev"]

# BUILD
FROM node-base AS build

ENV RAILS_ENV=production \
    NODE_ENV=production \
    BUNDLE_WITHOUT=development:test \
    BUNDLE_DEPLOYMENT=1

COPY Gemfile Gemfile.lock ./
RUN bundle config set without "development test" && \
    bundle install && \
    rm -rf ~/.bundle "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git

COPY package.json yarn.lock ./
RUN yarn install --frozen-lockfile

COPY . .

RUN bundle exec bootsnap precompile --gemfile
RUN bundle exec bootsnap precompile app/ lib/
RUN SECRET_KEY_BASE_DUMMY=1 ./bin/rails assets:precompile
RUN rm -rf node_modules tmp/cache

# PRODUCTION
FROM base AS production

ENV RAILS_ENV=production \
    BUNDLE_WITHOUT=development:test

COPY --from=build /usr/local/bundle /usr/local/bundle
COPY --from=build /rails /rails

RUN useradd --create-home --shell /bin/bash rails && \
    chown -R rails:rails /rails /usr/local/bundle
USER rails

EXPOSE 3000

ENTRYPOINT ["./docker/entrypoint.sh"]
CMD ["./bin/rails", "server", "-b", "0.0.0.0"]
