require "rails_helper"
require "generators/kanso/install/install_generator"

RSpec.describe Kanso::InstallGenerator, type: :generator do
  destination Rails.root.join("tmp/generators")

  before do
    prepare_destination
    allow_any_instance_of(described_class).to receive(:application_root).and_return(destination_root)
  end

  context "in a clean, modern Rails app" do
    before do
      app_css_dir = File.join(destination_root, "app/assets/tailwind")
      FileUtils.mkdir_p(app_css_dir)
      File.write(File.join(app_css_dir, "application.css"), "@import \"tailwindcss\";\n")
      run_generator
    end

    describe "the generated tailwind.config.js" do
      subject { file("tailwind.config.js") }

      it { is_expected.to exist }
      it { is_expected.to contain "function findKansoGemPath()" }
      it { is_expected.to contain "module.exports" }
      it { is_expected.to contain "path.join(kansoGemPath, \"app/components/**/*.{rb,html.erb}\")" }
    end

    describe "the modified application.css" do
      subject { file("app/assets/tailwind/application.css") }

      it { is_expected.to exist }
      it { is_expected.to contain "@config \"../../../tailwind.config.js\";" }
      it { is_expected.to contain "@layer base" }
    end
  end

  context "when a CommonJS tailwind.config.js already exists at the root" do
    before do
      app_css_dir = File.join(destination_root, "app/assets/tailwind")
      FileUtils.mkdir_p(app_css_dir)
      File.write(File.join(app_css_dir, "application.css"), "@import \"tailwindcss\";\n")
      File.write(File.join(destination_root, "tailwind.config.js"), "module.exports = { content: ['./app/views/**/*.html.erb'] }")
      run_generator
    end

    describe "the modified tailwind.config.js" do
      subject { file("tailwind.config.js") }
      it { is_expected.to contain "./app/views/**/*.html.erb" } # Preserves user content
      it { is_expected.to contain "// --- Kanso Configuration" }   # Appends our scriptlet
    end
  end

  context "when an ESM tailwind.config.js exists at the root" do
    let(:output) { run_generator }

    before do
      app_css_dir = File.join(destination_root, "app/assets/tailwind")
      FileUtils.mkdir_p(app_css_dir)
      File.write(File.join(app_css_dir, "application.css"), "@import \"tailwindcss\";\n")
      File.write(File.join(destination_root, "tailwind.config.js"), "export default { content: [] }")
    end

    it "stops, displays instructions, and does not modify the file" do
      expect(output).to include("Your `tailwind.config.js` uses ESM syntax")
      expect(file("tailwind.config.js")).not_to contain("// --- Kanso Configuration")
    end
  end

  context "when a legacy config/tailwind.config.js exists" do
    let(:output) { run_generator }

    before do
      app_css_dir = File.join(destination_root, "app/assets/tailwind")
      FileUtils.mkdir_p(app_css_dir)
      File.write(File.join(app_css_dir, "application.css"), "@import \"tailwindcss\";\n")

      legacy_config_dir = File.join(destination_root, "config")
      FileUtils.mkdir_p(legacy_config_dir)
      File.write(File.join(legacy_config_dir, "tailwind.config.js"), "module.exports = {}")
    end

    it "stops and displays a clear, helpful error message" do
      expect(output).to include("Kanso Installation Blocked")
      expect(output).to include("A Tailwind configuration file was found at:")
      expect(output).to include("`config/tailwind.config.js`")
      expect(output).to include("Please migrate this file")
    end

    it "does not create a new config file at the root" do
      expect(file("tailwind.config.js")).not_to exist
    end
  end

  context "when the modern CSS entrypoint is missing" do
    let(:output) { run_generator }

    it "stops and displays a clear, helpful error message" do
      expect(output).to include("Kanso Installation Blocked")
      expect(output).to include("Could not find the required Tailwind CSS entrypoint at:")
      expect(output).to include("`app/assets/tailwind/application.css`")
      expect(output).to include("Please run `rails tailwindcss:install`")
    end

    it "does not create any files" do
      expect(file("tailwind.config.js")).not_to exist
    end
  end
end
