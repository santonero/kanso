// Kanso: Managed Tailwind Configuration
const path = require("path");
const { execSync } = require("child_process");

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
