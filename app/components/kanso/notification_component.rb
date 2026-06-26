# frozen_string_literal: true

module Kanso
  class NotificationComponent < ViewComponent::Base
    Theme = Struct.new(
      :icon_name,
      :icon_bg_classes,
      :icon_color_classes,
      :title_text_classes,
      :body_text_classes,
      :aria_role,
      keyword_init: true
    )

    THEMES = {
      success: Theme.new(
        icon_name: "check-circle",
        icon_bg_classes: "bg-green-100",
        icon_color_classes: "text-green-600",
        title_text_classes: "text-green-800",
        body_text_classes: "text-green-700",
        aria_role: "status"
      ),
      error: Theme.new(
        icon_name: "x-circle",
        icon_bg_classes: "bg-red-100",
        icon_color_classes: "text-red-600",
        title_text_classes: "text-red-800",
        body_text_classes: "text-red-700",
        aria_role: "alert"
      ),
      warning: Theme.new(
        icon_name: "exclamation-triangle",
        icon_bg_classes: "bg-yellow-100",
        icon_color_classes: "text-yellow-600",
        title_text_classes: "text-yellow-800",
        body_text_classes: "text-yellow-700",
        aria_role: "alert"
      ),
      info: Theme.new(
        icon_name: "information-circle",
        icon_bg_classes: "bg-blue-100",
        icon_color_classes: "text-blue-600",
        title_text_classes: "text-blue-800",
        body_text_classes: "text-blue-700",
        aria_role: "status"
      )
    }.freeze

    RAILS_FLASH_ALIASES = {
      notice: :success,
      alert: :error
    }.freeze

    attr_reader :title, :message, :theme_data

    def initialize(message:, title: nil, theme: :info)
      @title = title
      @message = message

      theme_sym = theme.to_sym
      mapped_theme = RAILS_FLASH_ALIASES[theme_sym] || theme_sym
      @theme_data = THEMES[mapped_theme] || THEMES[:info]
    end
  end
end
