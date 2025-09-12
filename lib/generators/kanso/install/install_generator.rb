class Kanso::InstallGenerator < Rails::Generators::Base
  def install
    say "Kanso: Starting installation...", :cyan
    configure_tailwind_config
    configure_application_css
  end

  private

  def configure_tailwind_config
    host_config_path = Rails.root.join("tailwind.config.js")

    unless File.exist?(host_config_path)
      say "Kanso: `tailwind.config.js` not found. Creating a new one with Kanso support.", :cyan
      create_file host_config_path, <<~JS
        // Kanso: Managed Tailwind Configuration

        const path = require('path');
        const { execSync } = require('child_process');

        function findKansoGemPath() {
          try {
            return execSync(
              'bundle exec ruby -e "puts Bundler.rubygems.find_name(%q{kanso}).first.full_gem_path"'
            ).toString().trim();
          } catch (e) {
            console.error("Could not find the 'kanso' gem via Bundler. Please ensure it's in your Gemfile.");
            console.error(e.stderr.toString());
            process.exit(1);
          }
        }

        const kansoGemPath = findKansoGemPath();

        module.exports = {
          content: [
            './app/helpers/**/*.rb',
            './app/javascript/**/*.js',
            './app/views/**/*.{html,html.erb,erb}',
            path.join(kansoGemPath, 'app/components/**/*.{rb,html.erb}')
          ],
          theme: {
            extend: {},
          },
          plugins: [],
        }
      JS
      return
    end

    file_content = File.read(host_config_path)

    if file_content.include?("// Kanso: Managed Tailwind Configuration")
      say "Kanso: Tailwind configuration is already managed by Kanso. Skipping.", :yellow
    else
      say "Kanso: `tailwind.config.js` found. Safely appending Kanso configuration.", :cyan

      kanso_scriptlet = <<~JS

        // Kanso: Managed Tailwind Configuration
        // --- Kanso Configuration (appended by `rails g kanso:install`) ---
        try {
          const kansoGemPath = require('child_process').execSync('bundle exec ruby -e "puts Bundler.rubygems.find_name(%q{kanso}).first.full_gem_path"').toString().trim();
          if (kansoGemPath) {
            const kansoContentPath = require('path').join(kansoGemPath, 'app/components/**/*.{rb,html.erb}');
            if (module.exports.content) {
              if (!module.exports.content.includes(kansoContentPath)) {
                module.exports.content.push(kansoContentPath);
              }
            } else {
              module.exports.content = [kansoContentPath];
            }
          }
        } catch (e) {
          console.error("Kanso post-install configuration failed.");
          console.error(e);
        }
        // --- End Kanso Configuration ---
      JS

      append_to_file host_config_path, kanso_scriptlet
    end
  end

  def configure_application_css
    say "Kanso: Configuring `application.css` for Tailwind v4+...", :cyan
    css_path = Rails.root.join("app/assets/tailwind/application.css")

    return say("`application.css` not found. Skipping.", :yellow) unless File.exist?(css_path)

    file_content = File.read(css_path)

    if file_content.include?("@config")
      say "Kanso: `@config` bridge already present. Skipping.", :yellow
    else
      config_block = "/* Kanso: Config Bridge for portable content detection */\n@config \"../../../tailwind.config.js\";\n\n"
      prepend_to_file css_path, config_block
      say "Kanso: Injected `@config` bridge at the top of the file.", :green
    end

    if file_content.include?("/* Kanso: Base Styles ")
      say "Kanso: Base styles already present. Skipping.", :yellow
    else
      styles_in_layer_block = <<~CSS

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

      anchor = /@import\s+['"]tailwindcss['"];\n?/

      if file_content.match?(anchor)
        insert_into_file css_path, styles_in_layer_block, after: anchor
        say "Kanso: Injected base styles into the `@layer base`.", :green
      else
        say "Kanso: Could not find the `@import \"tailwindcss\";` directive.", :red
        say "         Please ensure it is present in your `application.css`.", :red
        say "         You will need to add the following styles manually:", :yellow
        puts styles_in_layer_block
      end
    end
  end
end
