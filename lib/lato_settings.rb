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
  end
end
