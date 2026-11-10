module LatoSettings
  class Engine < ::Rails::Engine
    isolate_namespace LatoSettings

    initializer 'lato_settings.importmap', before: 'importmap' do |app|
      app.config.importmap.paths << root.join('config/importmap.rb')
    end

    # Setting values may contain secrets typed by admins: keep them out of request logs.
    # after_initialize + append so host filter_parameters assignments are never overridden.
    config.after_initialize do |app|
      app.config.filter_parameters << /\Asetting\.value\z/
    end

    initializer "lato_settings.precompile" do |app|
      app.config.assets.precompile << "lato_settings_manifest.js"
    end
  end
end
