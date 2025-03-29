pin "lato_settings/application", to: "lato_settings/application.js"
pin_all_from LatoSettings::Engine.root.join("app/assets/javascripts/lato_settings/controllers"), under: "controllers", to: "lato_settings/controllers"
