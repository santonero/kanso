# frozen_string_literal: true

require "rails_helper"

RSpec.describe Kanso::ButtonComponent, type: :component do
  let(:options) { {} }
  let(:content) { "Action!" }

  before { render_inline(described_class.new(**options)) { content } }

  describe "Default Rendering" do
    it "renders as a <button> element" do
      expect(page).to have_css("button", text: content)
    end

    it "applies the essential styling contracts" do
      expect(page.find("button")[:class]).to include("rounded-full", "bg-white", "text-indigo-600")
    end
  end

  describe "Theming" do
    context "when :primary theme is specified" do
      let(:options) { { theme: :primary } }

      it "applies the primary theme contract" do
        button_classes = page.find("button")[:class]
        expect(button_classes).to include("bg-indigo-500", "text-white")
        expect(button_classes).not_to include("bg-white")
      end
    end
  end

  describe "Tag Polymorphism" do
    context "when rendered as a link" do
      let(:options) { { tag: :a, href: "/path" } }

      it "renders as an <a> tag with default styling" do
        expect(page).to have_css("a[href='/path']")
        expect(page.find("a")[:class]).to include("rounded-full", "bg-white")
      end
    end
  end

  describe "Attribute Passthrough" do
    context "with custom classes and other HTML attributes" do
      let(:options) { { class: "mt-4", id: "my-btn", disabled: true } }

      it "merges classes and renders other attributes" do
        expect(page).to have_css("button#my-btn.mt-4[disabled]")
        expect(page.find("button")[:class]).to include("mt-4")
      end
    end
  end

  describe "Form Action Rendering (`button_to`)" do
    context "when `url` is provided" do
      let(:options) do
        {
          url: "/items/1",
          method: :delete,
          class: "user-button-class",
          form: {
            class: "user-form-class",
            data: { turbo_confirm: "Are you sure?" }
          }
        }
      end
      let(:content) { "Delete Item" }

      it "renders a <form> with the correct attributes" do
        form = page.find("form")
        expect(form[:action]).to eq("/items/1")
        expect(form.find("input[name='_method'][type='hidden']", visible: false)[:value]).to eq("delete")
        expect(form[:class]).to include("user-form-class")
        expect(form["data-turbo-confirm"]).to eq("Are you sure?")
      end

      it "renders a <button> with the correct styles and attributes" do
        button = page.find("form button")
        expect(button.text).to eq(content)

        button_classes = button[:class]
        expect(button_classes).to include("user-button-class")
        expect(button_classes).to include("bg-white", "text-indigo-600")
      end
    end
  end
end
