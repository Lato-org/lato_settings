module LatoSettings
  class Setting < ApplicationRecord
    attr_accessor :actions

    enum :typology, {
      string: 0,
      number: 1
    }, prefix: true

    validates :key, presence: true, uniqueness: true, format: { with: /\A[a-zA-Z0-9_]+\z/ }
    validates :typology, presence: true
    validates :value, presence: true
    validates :label, presence: true

    # Hooks
    ##

    # normalize key before validation
    before_validation do
      self.key = key&.to_s&.downcase&.parameterize&.underscore
    end

    # do not permit destroy if required is true
    before_destroy do
      throw(:abort) if required
    end

    after_save :reload_cache
    after_destroy :reload_cache
    def reload_cache
      Rails.cache.delete('LatoSettings::Setting/cache')
      @@cache = nil
    end

    # Helpers
    ##
    
    # ...

    # Class
    ##
    
    def self.get(key, default = nil)
      load_cache

      @@cache[key] || default
    end

    def self.load_cache
      return true if defined?(@@cache) && @@cache

      @@cache = Rails.cache.fetch('LatoSettings::Setting/cache') do
        cache = {}
        LatoSettings::Setting.all.select(:key, :value, :typology).each do |setting|
          cache[setting.key] = setting.value
        end

        cache
      end

      true
    end

  end
end
