require "lato_settings/version"
require "lato_settings/engine"
require "lato_settings/config"

module LatoSettings
  class << self
    def config
      @config ||= Config.new
    end

    def configure
      yield config
    end

    def get(key, default = nil)
      load_cache

      @cache[key] || default
    end

    def load_cache
      return true if defined?(@cache) && @cache

      @cache = Rails.cache.fetch('LatoSettings/cache') do
        cache = {}
        LatoSettings::Setting.all.each do |setting|
          cache[setting.key] = setting.value_formatted
        end

        cache
      end

      @cache
    end

    def reset_cache
      @cache = nil
      Rails.cache.delete('LatoSettings/cache')
    end
  end
end
