# Lato Settings
Manage application settings on Lato projects.

Setting values, keys, and labels are displayed as plain text in the administration interface. HTML in these fields is escaped.

## Installation

Requires Rails 8.1.3.1 or newer in the 8.1 series and Lato 3.25.0 or newer.
Add required dependencies to your application's Gemfile:

```ruby
# Use lato as application panel
gem "lato"
gem "lato_settings"
```

Install gem and run required tasks:

```bash
$ bundle
$ rails lato:install:migrations
$ rails lato_settings:install:migrations
$ rails db:migrate
```

`rails lato_settings:install:application` exists for consistency with other Lato engines but does nothing: it is not required.

Mount lato settings routes on the **config/routes.rb** file:

```ruby
Rails.application.routes.draw do
  mount LatoSettings::Engine => "/lato-settings"

  # ....
end
```

Import Lato Scss on **app/assets/stylesheets/application.scss** file:
```scss
@import 'lato_settings/application';

// ....
```

Import Lato Settings Js on **app/javascript/application.js** file:
```js
import "lato_settings/application";

// ....
```

## Permissions

Users need the `lato_settings_admin` flag (column added by the engine migrations on `lato_users`):

```ruby
Lato::User.find_by(email: "admin@example.com").update!(lato_settings_admin: true)
```

## Usage

Read values with `LatoSettings.get(key, default = nil)`. The key is case-insensitive. The default is returned when the setting does not exist or its stored value can't be converted to its type.

| Typology | Returned type |
|----------|---------------|
| `string`, `text` | `String` |
| `integer` | `Integer` |
| `number` | `Float` |
| `date` | `Date` |
| `select` | `String` (one of the allowed values) |

Create settings in seeds (idempotent) and let admins edit the values from the panel:

```ruby
LatoSettings::Setting.find_or_create_by!(key: "items_per_page") do |setting|
  setting.label = "Items per page"
  setting.description = "Rows shown in lists"
  setting.typology = :integer
  setting.value = 25
  setting.required = true
  setting.options = { min: 1, max: 100, step: 1 }
end
```

Keys are normalized (`Site Name` becomes `site_name`; accents are transliterated, other characters become `_`) and, like `typology`, **cannot be changed after creation**. A value is required and is validated against its typology on save.

### Options

`options` is a JSON hash, set from seeds or console only (the admin UI can't edit it):

| Option | Used by | Meaning |
|--------|---------|---------|
| `min`, `max` | `integer`, `number`, `date` | Inclusive bounds (dates as `YYYY-MM-DD`) |
| `step` | `integer`, `number` | Value must be `min + n * step` (`min` defaults to 0) |
| `values` | `select` | Array of allowed values, compared as strings: `options: { values: %w[draft published] }` |

`required: true` settings can be edited but not deleted.

### Caching

`LatoSettings.get` reads from a snapshot of all settings kept in `Rails.cache` (key `LatoSettings/v2/cache`, 1 minute TTL) and in a per-process memo that honors the same TTL. Saving or destroying a setting through the model clears it after the transaction commits; call `LatoSettings.reset_cache` after changes that skip callbacks (`update_all`, SQL, other apps). In production with more than one process or host, configure a **shared** cache store (Redis, Memcached, Solid Cache): with a per-process store (`:memory_store`, `:file_store` on separate hosts) changes are visible in other processes only after the TTL.

### Security notes

Values are stored as **plain text** in the database and in the cache: do not store secrets (API keys, passwords) here. The engine appends `setting.value` to `config.filter_parameters` so values don't appear in request logs.

## Upgrading

```bash
bundle update lato_settings
rails lato_settings:install:migrations
rails db:migrate
```

Read [UPGRADING.md](UPGRADING.md) for the changes and extra steps required by each version.

## Development

Clone repository, install dependencies, run migrations and start:

```shell
$ git clone https://github.com/Lato-GAM/lato_settings
$ cd lato_settings
$ bundle
$ bin/rails db:migrate
$ bin/rails db:seed
$ bin/rails server
$ bin/rails test
```

The dummy app mounts the engine at `/lato-settings`; seed login is `admin@mail.com` / `Password1!`.

## Publish

```shell
$ ruby ./bin/publish.rb
```

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

