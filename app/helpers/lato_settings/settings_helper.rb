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
      raw "
        <div class=\"input-group input-group-sm\" data-controller=\"lato-copyclip\">
          <input type=\"text\" class=\"form-control\" placeholder=\"#{setting.label || setting.key}\" aria-label=\"#{setting.label || setting.key}\" aria-describedby=\"#{type}_#{setting.id}\" value=\"#{content}\" data-lato-copyclip-target=\"input\" readonly>
          <button class=\"btn btn-primary\" type=\"button\" id=\"#{type}_#{setting.id}\" data-lato-copyclip-target=\"button\" data-action=\"lato-copyclip#onButtonClick\" title=\"#{I18n.t('lato_settings.cta_copy')}\" aria-label=\"#{I18n.t('lato_settings.cta_copy')}\" data-copy-text=\"<i class='bi bi-clipboard-check'></i>\">
            <i class=\"bi bi-clipboard\"></i>
          </button>
        </div>
      "
    end
  end
end
