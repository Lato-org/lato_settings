require "test_helper"

module LatoSettings
  class SettingsControllerTest < ActionDispatch::IntegrationTest
    setup do
      Rails.cache.clear
      LatoSettings.reset_cache
      @user = lato_users(:user)
    end

    # non admin
    ##

    test "authenticated non admin user cannot access any action" do
      @user.update_columns(lato_settings_admin: false)
      authenticate_user
      setting = lato_settings_settings(:site_description)

      get lato_settings.settings_url
      assert_redirected_to lato.root_url
      get lato_settings.new_setting_url
      assert_redirected_to lato.root_url
      post lato_settings.settings_url, params: { setting: { key: "hack", value: "x", label: "Hack", typology: :string } }
      assert_redirected_to lato.root_url
      get lato_settings.edit_setting_url(setting)
      assert_redirected_to lato.root_url
      patch lato_settings.setting_url(setting), params: { setting: { value: "hacked" } }
      assert_redirected_to lato.root_url
      delete lato_settings.setting_url(setting)
      assert_redirected_to lato.root_url

      assert_nil LatoSettings::Setting.find_by(key: "hack")
      assert_not_equal "hacked", setting.reload.value
      assert LatoSettings::Setting.exists?(setting.id)
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
      assert_select "a[aria-label=?]", "Edit Site name"
      form_id = ActionView::RecordIdentifier.dom_id(lato_settings_settings(:site_description), "delete_form")
      assert_select "form##{form_id}[method=post][action=?]", lato_settings.setting_path(lato_settings_settings(:site_description))
      assert_select "button[type=submit][form=?][aria-label=?]", form_id, "Delete Site description"
    end

    test "index renders even with a corrupted row" do
      authenticate_user
      LatoSettings::Setting.where(id: lato_settings_settings(:site_description).id).update_all(typology: LatoSettings::Setting.typologies[:date], value: "garbage")

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

    test "new renders the typology step and the typed form, ignoring unknown typologies" do
      authenticate_user

      get lato_settings.new_setting_url(typology: "unknown")
      assert_response :success
      assert_select "form[method=get] select[name=typology]"

      get lato_settings.new_setting_url(typology: "integer")
      assert_response :success
      assert_select "input[type=number][name='setting[value]']"
      assert_select "#setting_value_help"
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

      assert_not_nil flash[:notice]

      setting = LatoSettings::Setting.find_by(key: "test")
      assert_not_nil setting
    end

    test "create with invalid value responds unprocessable entity" do
      authenticate_user

      post lato_settings.settings_url, params: { setting: { key: "test", value: "abc", label: "Test", typology: :integer } }
      assert_response :unprocessable_entity
      assert_nil LatoSettings::Setting.find_by(key: "test")
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

      assert_not_nil flash[:notice]

      setting.reload
      assert_equal "Test", setting.value
    end

    test "update ignores key and typology params" do
      authenticate_user

      setting = lato_settings_settings(:site_name)

      patch lato_settings.setting_url(setting), params: { setting: { key: "renamed", typology: "integer", value: "Test" } }
      assert_response :redirect

      setting.reload
      assert_equal "site_name", setting.key
      assert_equal "string", setting.typology
      assert_equal "Test", setting.value
    end

    test "update with invalid value responds unprocessable entity" do
      authenticate_user

      setting = lato_settings_settings(:site_name)
      LatoSettings::Setting.where(id: setting.id).update_all(typology: LatoSettings::Setting.typologies[:date], value: "2023-10-01")

      patch lato_settings.setting_url(setting), params: { setting: { value: "garbage" } }
      assert_response :unprocessable_entity
      assert_equal "2023-10-01", setting.reload.value
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

      assert_not_nil flash[:alert]

      setting = LatoSettings::Setting.find_by(key: "site_name")
      assert_not_nil setting
    end

    test "destroy should response with success redirect with session on optional setting" do
      authenticate_user

      setting = lato_settings_settings(:site_description)
      assert_not setting.required

      delete lato_settings.setting_url(setting)
      assert_response :redirect

      setting = LatoSettings::Setting.find_by(key: "site_description")
      assert_nil setting
    end
  end
end