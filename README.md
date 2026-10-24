# Lato Settings
Manage application settings on Lato projects.

Setting values, keys, and labels are displayed as plain text in the administration interface, including values saved before upgrading. HTML in these fields is escaped.

## Installation

Requires Rails 8.1.3.1 or newer in the 8.1 series and Lato 3.25.0 or newer. Existing applications must install the new Lato session migration before deployment; previous sessions are invalidated.
Add required dependencies to your application's Gemfile:

```ruby
# Use lato as application panel
gem "lato"
gem "lato_settings"
```

Install gem and run required tasks:

```bash
$ bundle
$ rails lato_settings:install:application
$ rails lato_settings:install:migrations
$ rails db:migrate
```

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

## Development

Clone repository, install dependencies, run migrations and start:

```shell
$ git clone https://github.com/Lato-GAM/lato_settings
$ cd lato_settings
$ bundle
$ rails db:migrate
$ rails db:seed
$ foreman start -f Procfile.dev
```

## Publish

```shell
$ ruby ./bin/publish.rb
```

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

