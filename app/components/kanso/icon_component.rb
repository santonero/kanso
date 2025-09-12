# frozen_string_literal: true

module Kanso
  class IconComponent < ViewComponent::Base
    attr_reader :name, :options

    def initialize(name:, **options)
      @name = name
      @options = options
    end

    def call
      attributes = tag.attributes(
        options.deep_merge(data: { icon_name: name })
      )

      raw_svg = cached_svg_content
      raw_svg.sub("<svg", "<svg #{attributes}").html_safe
    end

    private

    def cached_svg_content
      Rails.cache.fetch("kanso:icon:#{name}", expires_in: 1.day) do
        file_path = Kanso::Engine.root.join("app/assets/images/kanso/icons/#{name}.svg")
        File.read(file_path) if File.exist?(file_path)
      end.to_s
    end
  end
end
