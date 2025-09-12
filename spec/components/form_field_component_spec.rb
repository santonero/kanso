# frozen_string_literal: true

require "rails_helper"

RSpec.describe Kanso::FormFieldComponent, type: :component do
  # --- ARRANGE (1): The Test Double ---
  # This is a high-fidelity fake model that behaves just like ActiveRecord
  # for the purposes of our component. It's the foundation of our robust test.
  let(:form_model_class) do
    Struct.new(:id, :name, :errors, :persisted, keyword_init: true) do
      def self.model_name
        ActiveModel::Name.new(self, nil, "TestModel")
      end

      def self.human_attribute_name(attribute, options = {})
        attribute.to_s.humanize
      end

      def model_name
        self.class.model_name
      end

      def persisted?
        !!persisted
      end

      def to_key
        persisted? ? [ id ] : nil
      end

      def initialize(*)
        super
        self.errors ||= ActiveModel::Errors.new(self)
      end
    end
  end

  # --- ARRANGE (2): The Component's Context ---
  let(:model_instance) { form_model_class.new(id: 1, name: "Initial Value", persisted: true) }
  let(:component_options) { {} }

  # --- ACT (3): The Rendering Helper ---
  # We render the component within a real `form_with` context to ensure
  # our component behaves correctly with Rails' form builders.
  def render_form_fragment(model, options: {})
    render_in_view_context do
      form_with(model: model, url: "/path") do |f|
        render(Kanso::FormFieldComponent.new(form: f, attribute: :name, **options))
      end
    end
  end

  # --- ASSERT ---
  describe "Rendering" do
    context "with default options" do
      before { render_form_fragment(model_instance, options: component_options) }

      it "renders the basic structure (label and input)" do
        input_element = page.find("input[name='test_model[name]']")
        rendered_field_id = input_element['id']

        expect(rendered_field_id).not_to be_blank
        expect(page).to have_css("label[for='#{rendered_field_id}']", text: "Name")
        expect(page).to have_css("input[id='#{rendered_field_id}']")
      end
    end

    context "with passthrough options" do
      let(:component_options) { { placeholder: "Enter name", data: { foo: "bar" } } }
      before { render_form_fragment(model_instance, options: component_options) }

      it "passes them through to the input" do
        expect(page).to have_css("input[placeholder='Enter name']")
        expect(page).to have_css("input[data-foo='bar']")
      end
    end
  end

  describe "State Handling" do
    let(:rendered_classes) { page.find("input")[:class] }
    context "when the form object is valid" do
      before { render_form_fragment(model_instance) }

      it "applies the standard styling" do
        expect(rendered_classes).to include("ring-slate-300")
        expect(rendered_classes).not_to include("ring-red-300")
      end

      it "does not display any error messages" do
        expect(page).not_to have_css("p[data-kanso--form-target='errorMessage']")
      end
    end

    context "when the form object is invalid" do
      before do
        model_instance.errors.add(:name, "is too short")
        render_form_fragment(model_instance)
      end

      it "applies error styling to the input" do
        expect(rendered_classes).to include("ring-red-300")
        expect(rendered_classes).not_to include("ring-slate-300")
      end

      it "displays the validation error message" do
        error_message = model_instance.errors.full_messages_for(:name).first
        expect(page).to have_css("p[data-kanso--form-target='errorMessage']", text: error_message)
      end
    end
  end
end
