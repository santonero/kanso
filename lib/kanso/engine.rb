require "view_component"

module Kanso
  class Engine < ::Rails::Engine
    isolate_namespace Kanso

    initializer "kanso.importmap", before: "importmap" do |app|
      app.config.importmap.paths << Engine.root.join("config/importmap.rb")
    end
  end
end
