module LatoSettings
  class Engine < ::Rails::Engine
    isolate_namespace LatoSettings

    initializer 'lato_settings.importmap', before: 'importmap' do |app|
      app.config.importmap.paths << root.join('config/importmap.rb')
    end

    initializer "lato_settings.precompile" do |app|
      app.config.assets.precompile << "lato_settings_manifest.js"
    end
  end
end
