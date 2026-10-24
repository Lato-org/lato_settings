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
  end
end
