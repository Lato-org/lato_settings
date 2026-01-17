module LatoSettings
  class Setting < ApplicationRecord
    attr_accessor :actions

    enum :typology, {
      string: 0,
      number: 1,
      date: 2,
      select: 3,
      integer: 4,
    }, prefix: true

    validates :key, presence: true, uniqueness: true, format: { with: /\A[a-zA-Z0-9_]+\z/ }
    validates :typology, presence: true
    validates :value, presence: true, allow_blank: true
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
      LatoSettings.reset_cache
    end

    # Helpers
    ##
    
    def value_formatted
      return nil if value.nil?

      case typology
      when 'string'
        value.to_s
      when 'number'
        value.to_f
      when 'date'
        Date.parse(value)
      when 'select'
        option_values.include?(value) ? value : nil
      when 'integer'
        value.to_i
      else
        value.to_s
      end
    end
    
    def option_min
      options&.dig('min') || nil
    end

    def option_max
      options&.dig('max') || nil
    end

    def option_step
      options&.dig('step') || 1
    end

    def option_values
      options&.dig('values') || []
    end

    # Class
    ##
    
    # DEPRECATED METHOD: TO BE REMOVED IN FUTURE VERSIONS
    def self.get(key, default = nil)
      Rails.logger.warn "LatoSettings::Setting.get is deprecated. Use LatoSettings.get instead."
      LatoSettings.get(key, default)
    end

    # DEPRECATED METHOD: TO BE REMOVED IN FUTURE VERSIONS
    def self.load_cache
      Rails.logger.warn "LatoSettings::Setting.load_cache is deprecated. Use LatoSettings.reset_cache instead."
      LatoSettings.reset_cache
    end
  end
end
