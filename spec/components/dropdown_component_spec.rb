# frozen_string_literal: true

require "rails_helper"

RSpec.describe Kanso::DropdownComponent, type: :component do
  let(:trigger_content) { "<button>Menu</button>".html_safe }
  let(:panel_content) { "<a href='/products/new'> New Product </a>".html_safe }

  let(:component) do
    described_class.new.tap do |c|
      c.with_trigger { trigger_content }
    end
  end

  before { render_inline(component) { panel_content } }

  let(:trigger_section) { page.find("div[data-action*='kanso--dropdown#toggle']") }
  let(:panel) { page.find("div[data-kanso--dropdown-target='panel']") }

  describe "Rendering" do
    it "renders the trigger element in its section" do
      expect(trigger_section).to have_css("button", text: "Menu")
    end

    it "renders the content in the panel" do
      expect(panel).to have_css("a[href='/products/new']", text: "New Product")
    end
  end

  describe "Accessibility & Stimulus contracts" do
    it "renders the correct accessibility attributes" do
      expect(panel['role']).to eq("menu")
      expect(panel['aria-orientation']).to eq("vertical")
    end

    it "renders the correct Stimulus targets and actions" do
      expect(trigger_section['data-action']).to include("click->kanso--dropdown#toggle")
      expect(panel['data-action']).to include("keydown.esc@window->kanso--dropdown#close", "click@window->kanso--dropdown#closeOutside")
      expect(panel).to match_css("[data-kanso--dropdown-target='panel']")
    end
  end
end
