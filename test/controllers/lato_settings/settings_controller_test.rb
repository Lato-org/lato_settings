require "test_helper"

module Lato
  class SettingsControllerTest < ActionDispatch::IntegrationTest
    setup do
      Rails.cache.clear
      @user = lato_users(:user)
    end

    # index
    ##

    test "index should response with redirect without session" do
      get lato_settings.settings_url
      assert_response :redirect
    end

    test "index should response with success with session" do
      authenticate_user

      get lato_settings.settings_url
      assert_response :success
    end

    # new
    ##

    test "new should response with redirect without session" do
      get lato_settings.new_setting_url
      assert_response :redirect
    end

    test "new should response with success with session" do
      authenticate_user

      get lato_settings.new_setting_url
      assert_response :success
    end

    # create
    
    test "create should response with redirect without session" do
      post lato_settings.settings_url, params: { setting: { key: "test", value: "test", label: "Test", typology: :string } }
      assert_response :redirect
    end

    test "create should response with success redirect with session" do
      authenticate_user

      post lato_settings.settings_url, params: { setting: { key: "test", value: "test", label: "Test", typology: :string } }
      assert_response :redirect

      setting = LatoSettings::Setting.find_by(key: "test")
      assert_not_nil setting
    end

    # edit
    
    test "edit should response with redirect without session" do
      setting = lato_settings_settings(:site_name)

      get lato_settings.edit_setting_url(setting)
      assert_response :redirect
    end

    test "edit should response with success with session" do
      authenticate_user

      setting = lato_settings_settings(:site_name)

      get lato_settings.edit_setting_url(setting)
      assert_response :success
    end

    # update
    
    test "update should response with redirect without session" do
      setting = lato_settings_settings(:site_name)

      patch lato_settings.setting_url(setting), params: { setting: { key: "test", value: "test", label: "Test", typology: :string } }
      assert_response :redirect
    end

    test "update should response with success redirect with session" do
      authenticate_user

      setting = lato_settings_settings(:site_name)

      patch lato_settings.setting_url(setting), params: { setting: { value: "Test" } }
      assert_response :redirect

      setting.reload
      assert_equal "Test", setting.value
    end

    # destroy
    
    test "destroy should response with redirect without session" do
      setting = lato_settings_settings(:site_name)

      delete lato_settings.setting_url(setting)
      assert_response :redirect

      setting = LatoSettings::Setting.find_by(key: "site_name")
      assert_not_nil setting
    end

    test "destroy should response with redirect with session on required setting" do
      authenticate_user

      setting = lato_settings_settings(:site_name)
      assert setting.required

      delete lato_settings.setting_url(setting)
      assert_response :redirect

      setting = LatoSettings::Setting.find_by(key: "site_name")
      assert_not_nil setting
    end

    test "destroy should response with success redirect with session on optional setting" do
      authenticate_user

      setting = lato_settings_settings(:site_description)
      assert_not setting.required

      delete lato_settings.setting_url(setting)
      assert_response :redirect

      setting = LatoSettings::Setting.find_by(key: "site_description)")
      assert_nil setting
    end
  end
end