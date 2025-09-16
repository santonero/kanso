require_relative "lib/kanso/version"

Gem::Specification.new do |spec|
  spec.name        = "kanso"
  spec.version     = Kanso::VERSION
  spec.authors     = [ "santonero" ]
  spec.email       = [ "rbsanto@proton.me" ]
  spec.homepage    = "https://github.com/santonero/kanso"
  spec.license     = "MIT"

  spec.summary     = "An elemental UI component library for Rails, guided by the principle of simplicity."
  spec.description = spec.summary
  spec.metadata["source_code_uri"] = spec.homepage

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["{app,config,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  end

  spec.add_dependency "rails", ">= 6.1"
  spec.add_dependency "view_component", ">= 3.0"

  spec.add_development_dependency "rspec-rails"
  spec.add_development_dependency "capybara"
  spec.add_development_dependency "ammeter"
  spec.add_development_dependency "sqlite3"
  spec.add_development_dependency "importmap-rails"
  spec.add_development_dependency "tailwindcss-rails"
end
