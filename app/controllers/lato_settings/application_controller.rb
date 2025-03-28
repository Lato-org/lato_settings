module LatoSettings
  class ApplicationController < Lato::ApplicationController
    layout 'lato/application'
    before_action :authenticate_session
    before_action :authenticate_lato_settings_admin
    before_action { active_sidebar(:lato_settings); active_navbar(:lato_settings) }

    def index
      redirect_to lato_settings.settings_path
    end

    protected

    def authenticate_lato_settings_admin
      return true if @session.user.lato_settings_admin

      redirect_to lato.root_path, alert: 'You have not access to this section.'
    end
  end
end