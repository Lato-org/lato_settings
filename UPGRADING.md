# Upgrading Lato Settings

Version-specific notes. For the generic upgrade steps see the [README](README.md#upgrading).

## 3.1.0

- Run `rails lato_settings:install:migrations && rails db:migrate`: `value` and `description` become `text` columns.
- Values are validated per typology and `value` is required: existing settings with an empty value must be filled before saving them again.
- `key` and `typology` are read-only after creation.
- An invalid stored value (e.g. a non numeric integer) is returned as `nil`, so `LatoSettings.get` falls back to the default instead of `0` or raising.
- The cache key is now `LatoSettings/v2/cache` with a real TTL and is cleared after commit: old cache entries are ignored.
- `setting[value]` is filtered from logs.
- Values, keys and labels saved before the upgrade are escaped like new ones.

## Lato 3.25 compatibility

Requires Lato 3.25.0 or newer. Install the Lato session migration before deployment (`rails lato:install:migrations && rails db:migrate`): sessions become revocable database records and existing sessions are invalidated, so every user signs in again.
