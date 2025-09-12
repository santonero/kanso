# frozen_string_literal: true

require "rails_helper"

RSpec.describe Kanso::ModalComponent, type: :component do
  let(:title) { "Modal Title" }
  let(:trigger_content) { "<button>Open Modal</button>".html_safe }
  let(:main_content) { "<p>Main content.</p>".html_safe }
  let(:footer_content) { "<button>Close</button>".html_safe }

  let(:component) do
    described_class.new.tap do |c|
      c.with_trigger { trigger_content }
      c.with_header(title: title)
      c.with_footer { footer_content }
    end
  end

  before { render_inline(component) { main_content } }

  let(:wrapper) { page.find("div[data-controller='kanso--modal']") }
  let(:trigger_section) { wrapper.find("div[data-action*='kanso--modal#open']") }
  let(:container) { wrapper.find("div[data-kanso--modal-target='container']") }
  let(:panel) { container.find("div[role='dialog']") }
  let(:backdrop) { container.find("div[data-kanso--modal-target='backdrop']") }

  describe "Rendering" do
    it "renders the trigger outside the modal container" do
      expect(wrapper).to have_css("button", text: "Open Modal")
      expect(container).not_to have_css("button", text: "Open Modal")
    end

    it "renders the main content within the body" do
      expect(panel).to have_css("[data-test-id='kanso--modal-body'] p", text: "Main content.")
    end

    it "renders the header and footer slots" do
      expect(panel).to have_css("[data-test-id='kanso--modal-header'] h2", text: title)
      expect(panel).to have_css("[data-test-id='kanso--modal-footer'] button", text: "Close")
    end
  end

  describe "Stimulus & Accessibility Contracts" do
    it "sets up the controller and trigger action" do
      expect(page).to have_css("div[data-controller='kanso--modal']")
      expect(trigger_section['data-action']).to include("kanso--modal#open")
    end

    it "sets up all targets and actions" do
      expect(container['data-kanso--modal-target']).to eq("container")
      expect(backdrop['data-kanso--modal-target']).to eq("backdrop")
      expect(panel['data-kanso--modal-target']).to eq("panel")

      expect(container['data-action']).to include("keydown.esc@window->kanso--modal#close")
      expect(backdrop['data-action']).to include(
        "mousedown->kanso--modal#backdropMousedown",
        "mouseup->kanso--modal#backdropMouseup")
    end

    it "renders accessibility attributes" do
      title_element_id = panel.find('h2')['id']
      expect(panel['aria-modal']).to eq("true")
      expect(panel['aria-labelledby']).to eq(title_element_id)
    end
  end

  describe "Conditional Rendering" do
    it "does not render header or footer if slots are not provided" do
      render_inline(described_class.new) do |c|
        c.with_trigger { trigger_content }
        main_content
      end

      expect(page).not_to have_css("[data-test-id='kanso--modal-header'], [data-test-id='kanso--modal-footer']")
    end
  end
end
