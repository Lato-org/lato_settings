module LatoSettings
  module SettingsHelper
    def lato_settings_setting_key(setting)
      content_tag(:span, class: 'font-monospace') do
        setting.key
      end
    end

    def lato_settings_setting_label(setting)
      content_tag(:div, class: 'd-flex flex-column') do
        concat content_tag(:strong, setting.label)
        if setting.description
          concat content_tag(:small, setting.description, class: 'text-muted')
        end
      end
    end
    
    def lato_settings_setting_updated_at(setting)
      setting.updated_at.strftime('%d/%m/%Y %H:%M')
    end

    def lato_settings_setting_actions(setting)
      content_tag(:div, class: 'btn-group btn-group-sm') do
        concat link_to(I18n.t('lato_settings.cta_edit'), lato_settings.edit_setting_path(setting), class: 'btn btn-primary', data: { lato_action_target: 'trigger', turbo_frame: dom_id(setting, 'form'), action_title: I18n.t('lato_settings.edit_setting') })

        unless setting.required
          concat link_to(I18n.t('lato_settings.cta_delete'), lato_settings.setting_path(setting), class: 'btn btn-danger', data: { turbo_confirm: 'Are you sure?', turbo_method: :delete })
        end
      end
    end
  end
end
