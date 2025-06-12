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

      @cache[:data][key.to_s] || default
    end

    def load_cache
      return true if defined?(@cache) && @cache && @cache[:expires_at] && @cache[:expires_at] > Time.now

      @cache = Rails.cache.fetch('LatoSettings/cache') do
        data = {}
        LatoSettings::Setting.all.each do |setting|
          data[setting.key] = setting.value_formatted
        end

        {
          data: data,
          expires_at: Time.now + 1.minute
        }
      end

      @cache
    end

    def reset_cache
      @cache = nil
      Rails.cache.delete('LatoSettings/cache')
    end
  end
end
