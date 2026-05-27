# Repository Guidelines

## Project Structure & Dependencies
- This is a Rails application for GE.M.MA.
- Main application code lives in `app/`.
- Configuration lives in `config/`.
- Database migrations, schema, and seeds live in `db/`.
- JavaScript entry points live in `app/javascript/`.
- Stylesheets live in `app/assets/stylesheets/`.
- Tests live primarily in `test/`, with additional RSpec support in `spec/`.
- The app depends on `dm_unibo_common` and `dm_unibo_user_search`.
- A local checkout of `dm_unibo_common` may exist at `/home/rails/gems/dm_unibo_common/`; if a fix belongs there, coordinate changes instead of forcing it into this app.
- A local checkout of `dm_unibo_user_search` may exist at `/home/rails/gems/dm_unibo_user_search/`; if a fix belongs there, coordinate changes instead of forcing it into this app.

## Common Commands
- `bin/setup` installs gems/packages and prepares the app.
- `bin/dev` starts the Rails server plus JS/CSS watchers from `Procfile.dev`.
- `bin/rails test` runs the Rails test suite.
- `bin/rails test:system` runs system tests.
- `bundle exec rspec` runs RSpec tests when touching code covered there.
- `yarn build` builds JavaScript bundles into `app/assets/builds`.
- `yarn build:css` compiles and prefixes CSS.
- `bin/ci` runs the local CI sequence defined in `config/ci.rb`.

## CI Expectations
- `bin/ci` currently runs:
- `bin/setup --skip-server`
- `bin/rubocop`
- `bin/importmap audit`
- `bin/rails test`
- `bin/rails test:system`
- `env RAILS_ENV=test bin/rails db:seed:replant`

## Local Development Notes
- `README.md` documents a Docker Compose demo flow for local setup.
- `compose_develop.yaml` starts MariaDB plus the Rails app for development.
- `Procfile.dev` runs three processes: Rails server, JS build watcher, and CSS build watcher.

## Working Rules
- Prefer small, focused changes that fit existing Rails patterns.
- Do not revert unrelated local changes; this repository may already have a dirty worktree.
- Keep controllers thin and extract reusable logic into POROs/services/components when justified by existing structure.
- Match existing naming and style conventions in nearby files.
- Update or add tests when behavior changes.
- If a change appears to belong in `dm_unibo_common`, note that explicitly instead of duplicating shared logic here.
- `app/controllers/reports_controller.rb` is long but correct. It provides many reports as view of mysql queries using `app/services/gemma_report.rb` 

# Note
- On production `config/initializers/omniauth.rb` has `provider :entra_id, {client_id: ENV["AAD_CLIENT_ID"], client_secret: ENV["AAD_CLIENT_SECRET"], tenant_id: ENV["AAD_TENANT_ID"]}`


