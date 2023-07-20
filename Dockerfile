FROM ruby:3.2 AS donapieppo_ruby
MAINTAINER Donapieppo <donapieppo@yahoo.it>

ENV DEBIAN_FRONTEND noninteractive

WORKDIR /app

ARG UID=1000
ARG GID=1000

RUN apt-get update \
    && apt-get install -yq --no-install-recommends build-essential gnupg2 curl git vim locales libvips libmariadb-dev

RUN curl -sL https://deb.nodesource.com/setup_20.x | bash -

RUN apt-get update \
    && apt-get install -yq --no-install-recommends nodejs \
    && npm install -g yarn \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /usr/share/doc /usr/share/man \
    && groupadd -g ${GID} ruby \
    && useradd --create-home --no-log-init -u ${UID} -g ${GID} ruby \
    && chown ruby:ruby -R /app
 
FROM donapieppo_ruby AS donapieppo_gemma_bundle

USER ruby

COPY --chown=ruby:ruby Gemfile* ./
RUN bundle install

COPY --chown=ruby:ruby package.json *yarn* ./
RUN yarn install

FROM donapieppo_gemma_bundle AS donapieppo_gemma

COPY --chown=ruby:ruby . .

RUN ./bin/rails assets:precompile

# configuration
RUN ["/bin/cp", "doc/docker_database.yml", "config/database.yml"]
RUN ["/bin/cp", "doc/docker_omniauth.rb", "config/initializers/omniauth.rb"]
RUN ["/bin/cp", "doc/dm_unibo_common_docker.yml", "config/dm_unibo_common.yml"]
RUN ["/bin/cp", "doc/gemma_example.rb", "config/initializers/gemma.rb"]

EXPOSE 3000

CMD ["rails", "server", "-b", "0.0.0.0"]
