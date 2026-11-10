require "test_helper"

module LatoSettings
  class SettingTest < ActiveSupport::TestCase
    setup { LatoSettings.reset_cache }

    # bypasses validations and readonly attributes to simulate rows written outside the UI
    def corrupt(setting, typology, value)
      LatoSettings::Setting.where(id: setting.id).update_all(typology: LatoSettings::Setting.typologies[typology], value: value)
      setting.reload
    end

    def build_setting(attributes = {})
      LatoSettings::Setting.new({ key: "test_key", label: "Test", typology: :string, value: "v" }.merge(attributes))
    end

    test "key should be normalized before save" do
      setting = LatoSettings::Setting.new(key: "TEST KEY", value: "TestValue")
      setting.save

      assert_equal "test_key", setting.key
    end

    test "required settings should not be destroyed" do
      setting = LatoSettings::Setting.create(key: "test_key", value: "TestValue", required: true)
      assert_not setting.destroy
    end

    # immutability

    test "key and typology are readonly after create" do
      setting = lato_settings_settings(:site_name)

      assert_includes LatoSettings::Setting.readonly_attributes, "key"
      assert_includes LatoSettings::Setting.readonly_attributes, "typology"

      begin
        setting.update(key: "renamed", typology: :integer)
      rescue ActiveRecord::ReadonlyAttributeError
        # raised on assignment when raise_on_assign_to_attr_readonly is enabled
      end

      setting.reload
      assert_equal "site_name", setting.key
      assert_equal "string", setting.typology
    end

    # validation

    test "blank value is invalid" do
      assert_not build_setting(value: "").valid?
    end

    test "unknown typology is invalid instead of raising" do
      assert_not build_setting(typology: "unknown").valid?
    end

    test "date must be parsable" do
      assert_not build_setting(typology: :date, value: "not a date").valid?
      assert_not build_setting(typology: :date, value: "2023-13-45").valid?
      assert build_setting(typology: :date, value: "2023-10-01").valid?
    end

    test "date honors min and max" do
      options = { min: "2023-01-01", max: "2023-12-31" }

      assert_not build_setting(typology: :date, value: "2022-12-31", options: options).valid?
      assert_not build_setting(typology: :date, value: "2024-01-01", options: options).valid?
      assert build_setting(typology: :date, value: "2023-06-01", options: options).valid?
    end

    test "integer must be numeric and within min max step" do
      options = { min: 0, max: 100, step: 5 }

      assert_not build_setting(typology: :integer, value: "abc").valid?
      assert_not build_setting(typology: :integer, value: "1.5").valid?
      assert_not build_setting(typology: :integer, value: "-5", options: options).valid?
      assert_not build_setting(typology: :integer, value: "105", options: options).valid?
      assert_not build_setting(typology: :integer, value: "7", options: options).valid?
      assert build_setting(typology: :integer, value: "10", options: options).valid?
    end

    test "number must be numeric and within min max step" do
      options = { min: 0, max: 100, step: 0.01 }

      assert_not build_setting(typology: :number, value: "abc").valid?
      assert_not build_setting(typology: :number, value: "100.01", options: options).valid?
      assert_not build_setting(typology: :number, value: "1.123", options: options).valid?
      assert build_setting(typology: :number, value: "1.12", options: options).valid?
      assert build_setting(typology: :number, value: "1.5").valid?
    end

    test "select value must be one of the allowed values" do
      options = { values: %w[a b] }

      assert_not build_setting(typology: :select, value: "c", options: options).valid?
      assert build_setting(typology: :select, value: "a", options: options).valid?
    end

    # value_formatted

    test "value_formatted never raises on corrupted rows" do
      setting = lato_settings_settings(:site_name)

      { date: "garbage", integer: "abc", number: "abc", select: "nope" }.each do |typology, raw|
        assert_nil corrupt(setting, typology, raw).value_formatted, typology
      end
    end

    test "a corrupted row does not break LatoSettings.get for other keys" do
      broken = lato_settings_settings(:site_description)
      corrupt(broken, :date, "garbage")
      LatoSettings.reset_cache

      assert_equal "Lato Settings Example", LatoSettings.get("site_name")
      assert_equal "fallback", LatoSettings.get("site_description", "fallback")
    end

    test "value_formatted returns typed values" do
      assert_equal 3, build_setting(typology: :integer, value: "3").value_formatted
      assert_equal 1.5, build_setting(typology: :number, value: "1.5").value_formatted
      assert_equal Date.new(2023, 10, 1), build_setting(typology: :date, value: "2023-10-01").value_formatted
    end

    # cache

    test "cache is invalidated after commit" do
      setting = lato_settings_settings(:site_name)
      assert_equal "Lato Settings Example", LatoSettings.get("site_name")

      setting.update!(value: "Changed")
      assert_equal "Changed", LatoSettings.get("site_name")
    end

    test "cache entry expires and picks up changes that skip callbacks" do
      setting = lato_settings_settings(:site_name)
      assert_equal "Lato Settings Example", LatoSettings.get("site_name")

      setting.update_columns(value: "Direct")
      assert_equal "Lato Settings Example", LatoSettings.get("site_name")

      travel(LatoSettings::CACHE_TTL + 1.second) do
        assert_equal "Direct", LatoSettings.get("site_name")
      end
    end

    test "shared cache store entry gets a ttl" do
      original = Rails.cache
      Rails.cache = ActiveSupport::Cache::MemoryStore.new
      LatoSettings.reset_cache

      LatoSettings.get("site_name")
      lato_settings_settings(:site_name).update_columns(value: "Direct")
      LatoSettings.instance_variable_set(:@cache, nil) # simulate another process with empty memo

      travel(LatoSettings::CACHE_TTL + 1.second) do
        assert_equal "Direct", LatoSettings.get("site_name")
      end
    ensure
      Rails.cache = original
      LatoSettings.reset_cache
    end

    test "get normalizes the key case" do
      assert_equal "Lato Settings Example", LatoSettings.get("Site_Name")
    end

    # logging

    test "setting value is filtered from logs" do
      filter = ActiveSupport::ParameterFilter.new(Rails.application.config.filter_parameters)
      filtered = filter.filter("setting" => { "key" => "k", "value" => "secret-value" })

      assert_equal "[FILTERED]", filtered["setting"]["value"]
      assert_equal "k", filtered["setting"]["key"]
    end
  end
end
