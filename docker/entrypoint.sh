#!/usr/bin/env sh
set -e

rm -f /rails/tmp/pids/server.pid

if [ "${RAILS_ENV}" = "development" ]; then
  bundle check || bundle install

  if [ ! -d node_modules ] || [ -z "$(ls -A node_modules 2>/dev/null)" ]; then
    yarn install --frozen-lockfile
  fi

  if [ ! -s app/assets/builds/application.js ] || [ ! -s app/assets/builds/application.css ]; then
    yarn build
    yarn build:css
  fi
fi

exec "$@"
