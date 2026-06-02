# AGENTS

## Project overview

`lato_settings` is Rails engine for managing application settings in Lato projects.
It provides admin UI, typed value formatting, and cached read access via `LatoSettings.get`.

## Local setup

- Ruby via `rbenv`
- Install gems: `bundle`
- Install/migrate dummy app DB: `rails db:migrate`
- Seed dummy app: `rails db:seed`
- Start dev stack: `foreman start -f Procfile.dev`

## Main commands

- Run tests: `bin/rails test`
- Run single test file: `bin/rails test test/models/lato_settings/setting_test.rb`
- Lint JS/CSS if changed: follow repo conventions manually unless linter added
- Publish gem: `ruby ./bin/publish.rb`

## Architecture

- `lib/lato_settings.rb`: public API, config, cache handling
- `app/models/lato_settings/setting.rb`: setting model, typologies, formatting, validation
- `app/controllers/lato_settings/`: engine controllers and admin auth gate
- `app/views/lato_settings/settings/`: CRUD UI for settings
- `test/dummy/`: host app used for manual testing and documentation examples

## Conventions

- Prefer `LatoSettings.get("key", default)` over deprecated `LatoSettings::Setting.get`
- Use typed settings with `typology` and `options` when possible
- Use `find_or_create_by!` in seeds to avoid duplicates
- `required: true` means non-deletable, not non-editable
- Keys are normalized to lowercase underscore format before validation
- Cache resets through model callbacks after save/destroy

## Notes for agents

- Update dummy documentation when public behavior changes
- Keep examples aligned with actual engine routes and supported typologies
- Do not duplicate README install text beyond agent-focused summary here
