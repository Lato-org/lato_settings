require "test_helper"

module LatoSettings
  class SettingTest < ActiveSupport::TestCase
    test "key should be normalized before save" do
      setting = LatoSettings::Setting.new(key: "TEST KEY", value: "TestValue")
      setting.save

      assert_equal "test_key", setting.key
    end

    test "required settings should not be destroyed" do
      setting = LatoSettings::Setting.create(key: "test_key", value: "TestValue", required: true)
      assert_not setting.destroy
    end
  end
end
