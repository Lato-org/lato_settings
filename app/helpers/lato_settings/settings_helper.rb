module LatoSettings
  module SettingsHelper
    def lato_settings_setting_key(setting)
      print_content(setting, setting.key, :key)
    end

    def lato_settings_setting_value(setting)
      if setting.typology == 'text'
        content_tag(:pre, lato_settings_display_value(setting), tabindex: 0, role: 'region', aria: { label: setting.label || setting.key },
          class: 'p-2 bg-light border rounded mb-0', style: 'max-height: 200px; overflow: auto;')
      else
        print_content(setting, lato_settings_display_value(setting), :value)
      end
    end

    def lato_settings_setting_label(setting)
      content_tag(:div, class: 'd-flex flex-column') do
        concat content_tag(:strong, setting.label)
        if setting.description.present?
          concat content_tag(:small, setting.description, class: 'text-muted')
        end
      end
    end

    def lato_settings_setting_typology(setting)
      content_tag(:div, class: 'd-flex flex-column align-items-start gap-1') do
        concat content_tag(:span, lato_settings_typology_label(setting.typology))
        concat lato_data_badge(I18n.t('lato_settings.required'), 'secondary') if setting.required
      end
    end

    def lato_settings_setting_updated_at(setting)
      I18n.l(setting.updated_at, format: :long)
    end

    def lato_settings_setting_actions(setting)
      name = setting.label || setting.key

      content_tag(:div, class: 'btn-group btn-group-sm') do
        concat link_to(I18n.t('lato_settings.cta_edit'), lato_settings.edit_setting_path(setting), class: 'btn btn-primary',
          aria: { label: I18n.t('lato_settings.cta_edit_setting', label: name) },
          data: { lato_action_target: 'trigger', turbo_frame: dom_id(setting, 'form'), action_title: I18n.t('lato_settings.edit_setting') })

        if setting.required
          reason = I18n.t('lato_settings.setting_required_not_deletable')
          concat content_tag(:button, I18n.t('lato_settings.cta_delete'), type: 'button', class: 'btn btn-danger', disabled: true,
            title: reason, aria: { label: "#{I18n.t('lato_settings.cta_delete_setting', label: name)}: #{reason}" })
        else
          # submit button (not a link) so deletion works without JavaScript. It targets the form rendered by
          # `lato_settings_delete_forms` through the `form` attribute: the index table lives inside a GET form
          # and HTML forbids nested forms, so button_to can't be used here.
          concat content_tag(:button, I18n.t('lato_settings.cta_delete'), type: 'submit', class: 'btn btn-danger',
            form: dom_id(setting, 'delete_form'), aria: { label: I18n.t('lato_settings.cta_delete_setting', label: name) })
        end
      end
    end

    # One DELETE form per deletable setting, to be rendered outside of the index form
    def lato_settings_delete_forms(settings)
      safe_join(settings.reject(&:required).map do |setting|
        form_with(url: lato_settings.setting_path(setting), method: :delete, id: dom_id(setting, 'delete_form'),
          data: { turbo_confirm: I18n.t('lato_settings.cta_delete_confirm') }) { '' }
      end)
    end

    def lato_settings_typology_label(typology)
      I18n.t("lato_settings.typologies.#{typology}", default: typology.to_s.humanize)
    end

    def lato_settings_typology_options
      LatoSettings::Setting.typologies.keys.map { |typology| [lato_settings_typology_label(typology), typology] }
    end

    # Help text for the value input: expected format plus min/max/step from options
    def lato_settings_value_help(setting)
      parts = [I18n.t("lato_settings.help.#{setting.typology}", default: '')]

      if %w[number integer date].include?(setting.typology)
        parts << I18n.t('lato_settings.help.min', value: setting.option_min) unless setting.option_min.nil?
        parts << I18n.t('lato_settings.help.max', value: setting.option_max) unless setting.option_max.nil?
      end
      if %w[number integer].include?(setting.typology) && setting.option_step_configured
        parts << I18n.t('lato_settings.help.step', value: setting.option_step_configured)
      end

      parts.reject(&:blank?).join(' ')
    end

    # Formatted value for display; falls back to the raw stored value when it can't be converted
    def lato_settings_display_value(setting)
      formatted = setting.value_formatted
      return setting.value.to_s if formatted.nil?

      formatted.is_a?(Date) ? I18n.l(formatted) : formatted.to_s
    end

    def print_content(setting, content, type)
      label = setting.label || setting.key
      button_id = "#{type}_#{setting.id}"
      copy_label = I18n.t("lato_settings.cta_copy_value", label: label)

      content_tag(:div, class: "input-group input-group-sm", data: { controller: "lato-copyclip" }) do
        concat tag.input(type: "text", class: "form-control", placeholder: label, title: content,
          aria: { label: label }, value: content, readonly: true,
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
