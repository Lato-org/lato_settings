# Lato Settings
Manage application settings on Lato projects.

## Installation
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

