require "lato_settings/version"
require "lato_settings/engine"
require "lato_settings/config"

module LatoSettings
  CACHE_KEY = "LatoSettings/v2/cache".freeze
  CACHE_TTL = 1.minute

  class << self
    def config
      @config ||= Config.new
    end

    def configure
      yield config
    end

    # Returns the typed value of the setting or `default` when missing/unconvertible.
    def get(key, default = nil)
      value = load_cache[:data][key.to_s.downcase]

      value.nil? ? default : value
    end

    def load_cache
      # the per-process memo must honor expiry, otherwise it would never refresh
      @cache = nil if @cache && @cache[:expires_at] <= Time.now

      @cache ||= Rails.cache.fetch(CACHE_KEY, expires_in: CACHE_TTL) do
        {
          data: LatoSettings::Setting.all.each_with_object({}) { |setting, data| data[setting.key] = setting.value_formatted },
          expires_at: Time.now + CACHE_TTL
        }
      end
    end

    def reset_cache
      @cache = nil
      Rails.cache.delete(CACHE_KEY)
    end
  end
end
