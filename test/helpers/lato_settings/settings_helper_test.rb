require "test_helper"

module LatoSettings
  class SettingsHelperTest < ActionView::TestCase
    include SettingsHelper

    test "copy fields escape stored values and labels without changing their contents" do
      payload = "\"><img src=x onerror=alert(document.domain)>"
      setting = lato_settings_settings(:site_name)
      setting.label = payload
      setting.value = payload

      fragment = Nokogiri::HTML.fragment(lato_settings_setting_value(setting))
      assert_empty fragment.css("img, script, [onerror]")
      input = fragment.at_css("input")
      assert_equal payload, input["value"]
      assert_equal payload, input["placeholder"]
      assert_equal payload, input["aria-label"]
      assert_equal "lato-copyclip#onButtonClick", fragment.at_css("button")["data-action"]
    end

    test "copy button has a row specific accessible name and input is not described by it" do
      setting = lato_settings_settings(:site_name)

      fragment = Nokogiri::HTML.fragment(lato_settings_setting_value(setting))
      assert_includes fragment.at_css("button")["aria-label"], "Site name"
      assert_nil fragment.at_css("input")["aria-describedby"]
    end

    test "display value falls back to raw value when conversion fails" do
      setting = LatoSettings::Setting.new(key: "d", label: "D", typology: :date, value: "garbage")

      assert_equal "garbage", lato_settings_display_value(setting)
    end
  end
end
