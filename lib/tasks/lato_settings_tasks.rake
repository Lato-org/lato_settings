require 'fileutils'

namespace :lato_settings do
  namespace :install do
    desc 'No-op kept for consistency with other Lato engines (nothing to install on the host application)'
    # Usage: rails lato_settings:install:application
    task :application do
      puts 'lato_settings: nothing to install on the application. Run `rails lato_settings:install:migrations` to copy migrations.'
    end
  end
end
