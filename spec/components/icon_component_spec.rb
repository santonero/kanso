# frozen_string_literal: true

require "rails_helper"

RSpec.describe Kanso::IconComponent, type: :component do
  describe "Default Rendering" do
    let(:options) { {} }
    before { render_inline described_class.new(name: "x-mark", **options) }

    it "renders a <svg> tag" do
      expect(page).to have_css("svg")
    end

    context "with additional HTML attributes" do
      let(:options) { { id: "my-icon", class: "text-purple-600" } }

      it "applies them correctly on the element" do
        expect(page).to have_css("svg#my-icon.text-purple-600")
      end
    end
  end

  describe "SVG Content Loading and Attributes" do
    [ "x-mark", "check-circle" ].each do |icon_name|
      context "for the '#{icon_name}' icon" do
        it "renders the svg with the correct data-icon-name attribute" do
          render_inline(described_class.new(name: icon_name))
          expect(page).to have_css("svg[data-icon-name='#{icon_name}']")
        end
      end
    end

    context "when providing an invalid icon name" do
      it "renders nothing and does not raise an error" do
        expect {
          render_inline(described_class.new(name: "non-existent-icon"))
        }.not_to raise_error

        expect(page).to have_css('body > *', count: 0)
      end
    end
  end
end
