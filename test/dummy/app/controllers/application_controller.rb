class ApplicationController < LatoSettings::ApplicationController
  layout 'lato/application'
  before_action :authenticate_session, except: [:index]

  def index
    redirect_to lato.root_path
  end

  def documentation
    active_sidebar(:documentation)
  end
end
