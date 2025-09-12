require_relative "lib/kanso/version"

Gem::Specification.new do |spec|
  spec.name        = "kanso"
  spec.version     = Kanso::VERSION
  spec.authors     = [ "santonero" ]
  spec.email       = [ "rbsanto@proton.me" ]
  spec.homepage    = "https://github.com/santonero/kanso"
  spec.summary     = "An elemental UI component library for Rails, guided by the principle of simplicity."
  spec.description = "An elemental UI component library for Rails, guided by the principle of simplicity."
  spec.license     = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the "allowed_push_host"
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "TODO: Put your gem's public repo URL here."
  spec.metadata["changelog_uri"] = "TODO: Put your gem's CHANGELOG.md URL here."

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  end

  spec.add_dependency "rails", ">= 6.1"
  spec.add_dependency "view_component", ">= 3.0"

  spec.add_development_dependency "rspec-rails"
  spec.add_development_dependency "capybara"
  spec.add_development_dependency "sqlite3"
  spec.add_development_dependency "importmap-rails"
  spec.add_development_dependency "tailwindcss-rails"
end
