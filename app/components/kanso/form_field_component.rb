# frozen_string_literal: true

module Kanso
  class FormFieldComponent < ViewComponent::Base
    renders_one :help_text

    attr_reader :form, :attribute, :type, :options

    def initialize(form:, attribute:, type: :text_field, **options)
      @form = form
      @attribute = attribute
      @type = type
      @options = options
    end

    private

    def has_errors?
      form.object.errors.include?(attribute)
    end

    def field_id
      helpers.dom_id(form.object, attribute)
    end

    def description_id
      "#{field_id}_description"
    end

    def field_classes
      base_classes = "block w-full rounded-md border-0 py-1.5 px-3 shadow-sm ring-1 ring-inset focus:ring-2 focus:ring-inset sm:text-sm sm:leading-6"

      if has_errors?
        error_classes = "text-red-900 ring-red-300 placeholder:text-red-300 focus:ring-red-500"
        "#{base_classes} #{error_classes}"
      else
        normal_classes = "text-slate-900 ring-slate-300 placeholder:text-slate-400 focus:ring-blue-600"
        "#{base_classes} #{normal_classes}"
      end
    end

    def field_options
      options.deep_merge(
        id: field_id,
        class: field_classes,
        aria: { describedby: description_id },
        data: { kanso__form_target: ("errorField" if has_errors?) }
      )
    end
  end
end
