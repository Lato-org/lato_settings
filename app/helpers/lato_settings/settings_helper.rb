module LatoSettings
  module SettingsHelper
    def lato_settings_setting_key(setting)
      print_content(setting, setting.key, :key)
    end

    def lato_settings_setting_value(setting)
      if setting.typology == 'text'
        content_tag(:pre, setting.value_formatted.to_s, class: 'p-2 bg-light border rounded mb-0', style: 'max-height: 200px; overflow: auto;')
      else
        print_content(setting, setting.value_formatted, :value)
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
          concat link_to(I18n.t('lato_settings.cta_delete'), lato_settings.setting_path(setting), class: 'btn btn-danger', data: { turbo_confirm: I18n.t('lato_settings.cta_delete_confirm'), turbo_method: :delete })
        end
      end
    end

    def print_content(setting, content, type)
      label = setting.label || setting.key
      button_id = "#{type}_#{setting.id}"
      copy_label = I18n.t("lato_settings.cta_copy")

      content_tag(:div, class: "input-group input-group-sm", data: { controller: "lato-copyclip" }) do
        concat tag.input(type: "text", class: "form-control", placeholder: label,
          aria: { label: label, describedby: button_id }, value: content, readonly: true,
          data: { lato_copyclip_target: "input" })
        concat content_tag(:button, type: "button", id: button_id, class: "btn btn-primary",
          title: copy_label, aria: { label: copy_label },
          data: { lato_copyclip_target: "button", action: "lato-copyclip#onButtonClick",
            copy_text: "<i class='bi bi-clipboard-check'></i>" }) {
          content_tag(:i, "", class: "bi bi-clipboard")
        }
      end
    end
  end
end
