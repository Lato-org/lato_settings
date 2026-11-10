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
- Start dummy app: `bin/rails server` (no `Procfile.dev` in this repo; engine mounted at `/lato-settings`)

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
- Data model: table `lato_settings_settings` (`key`, `typology` enum, `value` text, `label`, `description` text, `required`, `options` JSON). `LatoSettings.configure` exists but has no options yet
- Use typed settings; `options` accepts `min`/`max`/`step` (integer, number, date) and `values` (select); the UI can't edit them
- Values are validated per typology on save; `value_formatted` never raises (returns nil on bad data)
- `key` and `typology` are immutable after create (`attr_readonly`, stripped from update params)
- Use `find_or_create_by!` in seeds to avoid duplicates
- `required: true` means non-deletable, not non-editable
- Keys are normalized to lowercase underscore format on create; `LatoSettings.get` downcases its argument
- Cache: `Rails.cache.fetch` with 1 minute TTL plus per-process memo; cleared `after_commit`. `update_all`/SQL do not invalidate: call `LatoSettings.reset_cache`
- Values are plaintext (no secrets); `setting.value` is added to `filter_parameters`
- Index table is inside a GET form: no nested forms, delete uses a `button` with `form=` pointing to forms from `lato_settings_delete_forms`

## Notes for agents

- User-facing documentation lives in `test/dummy/app/views/application/documentation.html.erb`
- Keep that file updated whenever install steps, permissions, configuration, supported typologies, or usage changes
- Documentation should explain what the gem does, how to install it, and how to use it
- Avoid internal implementation details such as controller internals, route lists, or private models. Behavior that affects usage (cache TTL and `reset_cache`, shared cache store requirement, options, return types, plaintext storage) must be documented

## Security release baseline

- Rails 8.1.3.1 or newer in the 8.1 series is required.
- Run `ruby bin/publish.rb` from a named release branch after tests pass. It builds the exact version, commits changes, tags that commit, publishes to RubyGems, and pushes the branch and tag.
- Applications using Active Storage with vips require libvips 8.13 or newer.
