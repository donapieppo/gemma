# syntax = docker/dockerfile:1

ARG RUBY_VERSION=3.4

# BASE
FROM registry.docker.com/library/ruby:${RUBY_VERSION}-slim AS base

LABEL org.opencontainers.image.authors="Pietro Donatini <pietro.donatini@unibo.it>"
LABEL org.opencontainers.image.description="Gemma"
LABEL org.opencontainers.image.source="https://github.com/donapieppo/gemma"

WORKDIR /rails


ENV LANG=C.UTF-8 \
    BUNDLE_PATH=/usr/local/bundle \
    BUNDLE_JOBS=4 \
    BUNDLE_RETRY=3

RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
      fonts-jetbrains-mono \
      libjemalloc2 \
      libmariadb3 \
      libvips && \
    rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/*

RUN useradd --create-home --shell /bin/bash rails

# BUILD-BASE
FROM base AS build-base

RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
      build-essential \
      ca-certificates \
      curl \
      default-libmysqlclient-dev \
      git \
      libyaml-dev \
      node-gyp \
      pkg-config \
      python-is-python3 \
      xz-utils && \
    rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/*

# NODE-BASE
FROM build-base AS node-base

ARG NODE_VERSION=22.22.2
ARG NODE_BUILD_REF=v5.4.37
ARG YARN_VERSION=1.22.22
ENV PATH=/usr/local/node/bin:$PATH

RUN mkdir -p /tmp/node-build && \
    curl -fsSL "https://github.com/nodenv/node-build/archive/${NODE_BUILD_REF}.tar.gz" | tar xz -C /tmp/node-build --strip-components=1 && \
    /tmp/node-build/bin/node-build ${NODE_VERSION} /usr/local/node && \
    npm install -g yarn@"${YARN_VERSION}" && \
    rm -rf /tmp/node-build

# GEMS-DEV
FROM node-base AS gems-dev

ENV RAILS_ENV=development

COPY Gemfile Gemfile.lock ./
RUN bundle install && \
    gem install foreman --no-document

# ASSETS-DEV
FROM node-base AS assets-dev

COPY package.json yarn.lock ./
RUN yarn install --frozen-lockfile

# DEVELOPMENT
FROM node-base AS development

ENV RAILS_ENV=development \
    NODE_ENV=development

COPY Gemfile Gemfile.lock package.json yarn.lock ./
COPY --from=gems-dev --chown=rails:rails /usr/local/bundle /usr/local/bundle
COPY --from=assets-dev --chown=rails:rails /rails/node_modules /rails/node_modules

COPY --chown=rails:rails . .

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
RUN yarn install --frozen-lockfile --production=false

COPY . .

RUN bundle exec bootsnap precompile --gemfile
RUN bundle exec bootsnap precompile app/ lib/
RUN SECRET_KEY_BASE_DUMMY=1 ./bin/rails assets:precompile
RUN rm -rf node_modules tmp/cache

# PRODUCTION
FROM base AS production

ENV RAILS_ENV=production \
    NODE_ENV=production \
    BUNDLE_WITHOUT=development:test \
    BUNDLE_DEPLOYMENT=1

COPY --from=build /usr/local/bundle /usr/local/bundle
COPY --from=build --chown=rails:rails /rails /rails

RUN mkdir -p tmp/pids tmp/cache tmp/sockets log storage && \
    chown -R rails:rails tmp log storage

USER rails

ENTRYPOINT ["./docker/entrypoint.sh"]
EXPOSE 3000
CMD ["./bin/rails", "server", "-b", "0.0.0.0"]
