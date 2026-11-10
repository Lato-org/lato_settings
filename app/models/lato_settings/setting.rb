module LatoSettings
  class Setting < ApplicationRecord
    attr_accessor :actions

    enum :typology, {
      string: 0,
      number: 1,
      date: 2,
      select: 3,
      integer: 4,
      text: 5
    }, prefix: true, validate: true

    # key and typology identify a setting for the host application: changing them
    # after creation would silently break `LatoSettings.get` callers
    attr_readonly :key, :typology

    validates :key, presence: true, uniqueness: true, format: { with: /\A[a-zA-Z0-9_]+\z/ }
    validates :typology, presence: true
    validates :value, presence: true
    validates :label, presence: true
    validate :value_matches_typology

    # Hooks
    ##

    # normalize key before validation
    before_validation(on: :create) do
      self.key = key&.to_s&.downcase&.parameterize&.underscore
    end

    # do not permit destroy if required is true
    before_destroy do
      throw(:abort) if required
    end

    # after_commit (not after_save) so other processes can't rebuild the cache from pre-commit data
    after_commit :reload_cache
    def reload_cache
      LatoSettings.reset_cache
    end

    # Helpers
    ##

    # Never raises: a corrupted row must not break `LatoSettings.get` or the index page.
    # Returns nil when the stored value can't be converted to the typology.
    def value_formatted
      return nil if value.nil?

      case typology
      when 'number'
        Float(value.to_s, exception: false)
      when 'date'
        parse_date(value)
      when 'select'
        option_values.include?(value) ? value : nil
      when 'integer'
        Integer(value.to_s, 10, exception: false)
      else
        value.to_s
      end
    end

    def option_min
      safe_options['min']
    end

    def option_max
      safe_options['max']
    end

    def option_step
      option_step_configured || 1
    end

    # nil when no step is set in options (no step constraint)
    def option_step_configured
      safe_options['step']
    end

    def option_values
      Array(safe_options['values']).map(&:to_s)
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

    private

    # options may hold symbol keys before reload or a non-hash value if written by hand
    def safe_options
      options.is_a?(Hash) ? options.with_indifferent_access : {}
    end

    def parse_date(raw)
      Date.parse(raw.to_s)
    rescue Date::Error
      nil
    end

    def value_matches_typology
      return if value.blank?

      case typology
      when 'integer'
        number = Integer(value.to_s, 10, exception: false)
        number ? validate_number_options(decimal(number)) : add_value_error(:not_integer)
      when 'number'
        number = Float(value.to_s, exception: false)
        number ? validate_number_options(decimal(number)) : add_value_error(:not_number)
      when 'date'
        validate_date_options
      when 'select'
        add_value_error(:not_in_values) unless option_values.include?(value)
      end
    end

    def validate_number_options(number)
      min = decimal(option_min)
      max = decimal(option_max)
      step = decimal(option_step_configured)

      return add_value_error(:too_small, min: option_min) if min && number < min
      return add_value_error(:too_big, max: option_max) if max && number > max

      add_value_error(:not_on_step, step: option_step) if step&.positive? && ((number - (min || 0)) % step) != 0
    end

    def validate_date_options
      date = Date.iso8601(value.to_s)
      min = iso_date(option_min)
      max = iso_date(option_max)

      return add_value_error(:too_small, min: option_min) if min && date < min

      add_value_error(:too_big, max: option_max) if max && date > max
    rescue Date::Error
      add_value_error(:not_date)
    end

    def add_value_error(code, **interpolations)
      errors.add(:value, I18n.t("lato_settings.validation.#{code}", **interpolations))
    end

    def decimal(raw)
      BigDecimal(raw.to_s) unless raw.nil?
    rescue ArgumentError
      nil
    end

    def iso_date(raw)
      Date.iso8601(raw.to_s) unless raw.nil?
    rescue Date::Error
      nil
    end
  end
end
