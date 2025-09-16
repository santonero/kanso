# lib/generators/kanso/install/install_generator.rb

class Kanso::InstallGenerator < Rails::Generators::Base
  source_root File.expand_path("templates", __dir__)

  # Kanso Philosophy: Public methods are generator tasks.
  # Helper methods must be explicitly declared to avoid being run by Thor.
  no_commands do
    # This method exists to make the generator testable.
    # In a test environment, we can stub this to point to a temporary directory.
    def application_root
      Rails.root
    end
  end

  def install
    say "Kanso: Starting installation...", :cyan

    # --- Prerequisite Checks based on observable facts ---
    css_path = application_root.join("app/assets/tailwind/application.css")
    root_config_path = application_root.join("tailwind.config.js")
    legacy_config_path = application_root.join("config/tailwind.config.js")

    unless File.exist?(css_path)
      say "\nKanso Installation Blocked", :red
      say "--------------------------", :red
      say "Could not find the required Tailwind CSS entrypoint at:", :yellow
      say "`app/assets/tailwind/application.css`", :bold
      say "\nThis file is required for Kanso to be installed correctly.", :yellow
      say "Please run `rails tailwindcss:install` to generate it, then re-run this generator.", :cyan
      return
    end

    if File.exist?(legacy_config_path)
      say "\nKanso Installation Blocked", :red
      say "--------------------------", :red
      say "A Tailwind configuration file was found at:", :yellow
      say "`config/tailwind.config.js`", :bold
      say "\nTo ensure a single source of truth, Kanso requires the configuration to be at the project root.", :yellow
      say "Please migrate this file to `tailwind.config.js` at the root of your project, then re-run this generator.", :cyan
      return
    end

    # --- Core Logic ---
    configure_tailwind_config(root_config_path)
    configure_application_css(css_path, root_config_path)

    say "Kanso: Installation complete! ✨", :green
  end

  private

  # --- Tailwind Configuration Logic ---

  def configure_tailwind_config(path)
    if File.exist?(path)
      inject_into_tailwind_config(path)
    else
      create_tailwind_config(path)
    end
  end

  def inject_into_tailwind_config(path)
    file_content = File.read(path)

    if file_content.include?("// Kanso: Managed")
      say "Kanso: Tailwind configuration is already Kanso-aware. Skipping.", :yellow
      return
    end

    if file_content.match?(/export\s+default/m)
      say "Kanso: Your `tailwind.config.js` uses ESM syntax (`export default`).", :yellow
      say "       To prevent conflicts, Kanso will not modify this file.", :yellow
      say "       Please manually add the Kanso content path to your config:", :cyan
      say "       You'll need `path.join` and this helper function:", :bold
      puts find_kanso_gem_path_function.indent(7)
      puts "       And add this to your `content` array:".indent(7)
      puts "       `path.join(kansoGemPath, \"app/components/**/*.{rb,html.erb}\")`".indent(7)
      return
    end

    say "Kanso: Found existing `tailwind.config.js`. Safely appending Kanso configuration.", :cyan
    append_to_file path, kanso_scriptlet
  end

  def create_tailwind_config(path)
    say "Kanso: No `tailwind.config.js` found. Creating a new, Kanso-aware configuration.", :cyan
    create_file path, <<~JS
      // Kanso: Managed Tailwind Configuration
      const path = require("path");
      const { execSync } = require("child_process");

      #{find_kanso_gem_path_function.strip.indent(2)}

      const kansoGemPath = findKansoGemPath();

      module.exports = {
        content: [
          "./app/helpers/**/*.rb",
          "./app/javascript/**/*.js",
          "./app/views/**/*.{html,html.erb,erb}",
          path.join(kansoGemPath, "app/components/**/*.{rb,html.erb}")
        ],
        theme: {
          extend: {},
        },
        plugins: [],
      }
    JS
  end

  # --- CSS Configuration Logic ---

  def configure_application_css(css_path, config_path)
    file_content = File.read(css_path)
    inject_config_bridge(css_path, file_content, config_path)
    inject_base_styles(css_path, file_content)
  end

  def inject_config_bridge(css_path, file_content, config_path)
    if file_content.include?("@config")
      say "Kanso: `@config` directive already present in CSS. Skipping.", :yellow
    else
      relative_config_path = config_path.relative_path_from(css_path.dirname).to_s
      config_block = "/* Kanso: Tells Tailwind to use our smart JS config */\n@config \"#{relative_config_path}\";\n\n"
      prepend_to_file css_path, config_block
      say "Kanso: Injected `@config` bridge into `#{relative_path(css_path)}`.", :green
    end
  end

  def inject_base_styles(css_path, file_content)
    if file_content.include?("/* Kanso: Base Styles")
      say "Kanso: Base styles already present. Skipping.", :yellow
    else
      anchor = /@import\s+["']tailwindcss["'];\s*(\r\n|\n)/
      if file_content.match?(anchor)
        insert_into_file css_path, "\n#{base_styles_block.strip}\n", after: anchor
        say "Kanso: Injected base styles.", :green
      else
        say "Kanso: Could not find the `@import \"tailwindcss\";` directive.", :red
        say "         Please add the Kanso base styles block manually:", :yellow
        puts base_styles_block
      end
    end
  end

  # --- Helper Methods & Content Blocks ---

  def kanso_scriptlet
    <<~JS

      // --- Kanso Configuration (appended by `rails g kanso:install`) ---
      // Kanso: Managed
      try {
        const kansoGemPath = require("child_process").execSync(`bundle exec ruby -e "puts Bundler.rubygems.find_name(%q{kanso}).first.full_gem_path"`).toString().trim();
        if (kansoGemPath) {
          const kansoContentPath = require("path").join(kansoGemPath, "app/components/**/*.{rb,html.erb}");
          if (module.exports.content) {
            if (!module.exports.content.includes(kansoContentPath)) {
              module.exports.content.push(kansoContentPath);
            }
          } else {
            module.exports.content = [kansoContentPath];
          }
        }
      } catch (e) {
        console.error("Kanso post-install configuration failed. Please add the Kanso content path to your tailwind.config.js manually.");
        console.error(e);
      }
      // --- End Kanso Configuration ---
    JS
  end

  def find_kanso_gem_path_function
    <<~JS
      function findKansoGemPath() {
        try {
          return execSync(
            `bundle exec ruby -e "puts Bundler.rubygems.find_name(%q{kanso}).first.full_gem_path"`
          ).toString().trim();
        } catch (e) {
          console.error("Could not find the 'kanso' gem via Bundler. Please ensure it's in your Gemfile.");
          console.error(e.stderr.toString());
          process.exit(1);
        }
      }
    JS
  end

  def base_styles_block
    <<~CSS
      /* Kanso: Base Styles injected into the native 'base' cascade layer */
      @layer base {
        input:focus, textarea:focus, select:focus {
          outline: none;
        }
        turbo-frame[busy] {
          opacity: 0.5;
          transition: opacity 0.3s ease-in-out;
        }
      }
      /* End Kanso Base Styles */
    CSS
  end

  def relative_path(path)
    path.relative_path_from(Rails.root).to_s
  end
end
