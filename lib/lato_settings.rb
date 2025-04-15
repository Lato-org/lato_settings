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
        LatoSettings::Setting.all.select(:key, :value, :typology).each do |setting|
          cache[setting.key] = setting.value
          cache[setting.key] = setting.value.to_f if setting.typology_number?
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
