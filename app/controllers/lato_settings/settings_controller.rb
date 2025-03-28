module LatoSettings
  class SettingsController < ApplicationController
    def index
      @settings = lato_index_collection(
        Setting.all,
        columns: %i[key label value updated_at actions],
        searchable_columns: %i[key label value],
        sortable_columns: %i[updated_at],
        pagination: true,
        default_sort_by: "key|asc"
      )
    end

    def new
      @setting = Setting.new
    end

    def create
      @setting = Setting.new(setting_params)
      if @setting.save
        redirect_to settings_path
      else
        render 'new'
      end
    end

    def edit
      @setting = Setting.find(params[:id])
    end

    def update
      @setting = Setting.find(params[:id])
      if @setting.update(setting_params)
        redirect_to settings_path
      else
        render 'edit'
      end
    end

    def destroy
      @setting = Setting.find(params[:id])
      @setting.destroy
      redirect_to settings_path
    end

    private

    def setting_params
      params.require(:setting).permit(:key, :value, :label, :description)
    end
  end
end