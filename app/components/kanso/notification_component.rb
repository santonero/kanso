# frozen_string_literal: true

module Kanso
  class NotificationComponent < ViewComponent::Base
    Theme = Struct.new(
      :icon_name,
      :icon_bg_classes,
      :icon_color_classes,
      :title_text_classes,
      :body_text_classes,
      keyword_init: true
    )

    THEMES = {
      success: Theme.new(
        icon_name: "check-circle",
        icon_bg_classes: "bg-green-100",
        icon_color_classes: "text-green-600",
        title_text_classes: "text-green-800",
        body_text_classes: "text-green-700"
      ),
      error: Theme.new(
        icon_name: "x-circle",
        icon_bg_classes: "bg-red-100",
        icon_color_classes: "text-red-600",
        title_text_classes: "text-red-800",
        body_text_classes: "text-red-700"
      ),
      warning: Theme.new(
        icon_name: "exclamation-triangle",
        icon_bg_classes: "bg-yellow-100",
        icon_color_classes: "text-yellow-600",
        title_text_classes: "text-yellow-800",
        body_text_classes: "text-yellow-700"
      ),
      info: Theme.new(
        icon_name: "information-circle",
        icon_bg_classes: "bg-blue-100",
        icon_color_classes: "text-blue-600",
        title_text_classes: "text-blue-800",
        body_text_classes: "text-blue-700"
      )
    }.freeze

    attr_reader :title, :message, :theme_data

    def initialize(message:, title: nil, theme: :info)
      @title = title
      @message = message
      @theme_data = THEMES[theme.to_sym] || THEMES[:info]
    end
  end
end
