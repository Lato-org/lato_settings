# AGENTS

## Project overview

Lato is ecosystem of Rails engines for building admin panels with authentication, user management, Bootstrap UI, reusable components, operations, settings, storage, spaces, and CMS features.

`lato_settings` is extension gem for the base `lato` engine.

## Gem purpose

`lato_settings` adds application settings management to a Lato admin panel.

Admins can create, edit, and delete configurable values. Application code can read those values with `LatoSettings.get`.

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

- User-facing documentation lives in `test/dummy/app/views/application/documentation.html.erb`
- Keep that file updated whenever install steps, permissions, configuration, supported typologies, or usage changes
- Documentation should explain what the gem does, how to install it, and how to use it
- Avoid internal implementation details such as controller internals, route lists, private models, cache mechanics, or database mechanics unless required for usage
