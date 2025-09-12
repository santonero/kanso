# frozen_string_literal: true

module Kanso
  class ButtonComponent < ViewComponent::Base
    include Kanso::ClassCombinable

    THEME_CLASSES = {
      primary: "bg-indigo-500 text-white hover:bg-indigo-600 active:bg-indigo-700",
      danger:  "bg-red-600 text-white hover:bg-red-700 active:bg-red-800",
      default: "bg-white text-indigo-600 border border-indigo-600 focus:ring-indigo-500/50 hover:bg-indigo-50 hover:border-indigo-700 active:bg-indigo-700 active:text-white"
    }.freeze

    def initialize(theme: :default, tag: :button, url: nil, method: nil, **options)
      @theme = theme
      @tag = tag
      @url = url
      @method = method
      @options = options
    end

    def call
      if @url
        button_to(@url, method: @method, **html_options) do
          content
        end
      else
        content_tag(@tag, content, html_options)
      end
    end

    private

    def html_options
      final_options = @options.dup
      user_provided_class_value = final_options.delete(:class)
      combined_class_string = combine_classes(classes, user_provided_class_value)
      final_options.deep_merge(class: combined_class_string)
    end

    def classes
      [ base_classes, theme_classes ].join(" ")
    end

    def base_classes
      "inline-flex items-center justify-center gap-x-2 " +
      "w-full sm:w-auto rounded-full font-semibold whitespace-nowrap select-none no-underline text-center px-5 py-2 " +
      "shadow-md " +
      "transform transition duration-200 " +
      "hover:cursor-pointer " +
      "active:translate-y-px active:shadow-none " +
      "disabled:cursor-not-allowed disabled:opacity-50"
    end

    def theme_classes
      THEME_CLASSES.fetch(@theme, THEME_CLASSES[:default])
    end
  end
end
