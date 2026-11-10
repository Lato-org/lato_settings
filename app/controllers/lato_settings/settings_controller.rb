module LatoSettings
  class SettingsController < ApplicationController
    def index
      @settings = lato_index_collection(
        Setting.all,
        columns: %i[label typology value key updated_at actions],
        searchable_columns: %i[key label value],
        sortable_columns: %i[key label updated_at],
        pagination: true,
        default_sort_by: "key|asc"
      )
    end

    def new
      @setting = Setting.new(typology: (params[:typology] if Setting.typologies.key?(params[:typology])))
    end

    def create
      @setting = Setting.new(create_params)
      if @setting.save
        redirect_to settings_path, notice: I18n.t('lato_settings.setting_created')
      else
        render 'new', status: :unprocessable_entity
      end
    end

    def edit
      @setting = Setting.find(params[:id])
    end

    def update
      @setting = Setting.find(params[:id])
      if @setting.update(update_params)
        redirect_to settings_path, notice: I18n.t('lato_settings.setting_updated')
      else
        render 'edit', status: :unprocessable_entity
      end
    end

    def destroy
      @setting = Setting.find(params[:id])
      if @setting.destroy
        redirect_to settings_path, notice: I18n.t('lato_settings.setting_deleted')
      else
        redirect_to settings_path, alert: I18n.t('lato_settings.setting_required_not_deletable')
      end
    end

    private

    def create_params
      params.require(:setting).permit(:key, :value, :label, :description, :typology)
    end

    # key and typology are immutable after creation
    def update_params
      params.require(:setting).permit(:value, :label, :description)
    end
  end
end