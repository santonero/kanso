# frozen_string_literal: true

module Kanso
  class ModalComponent < ViewComponent::Base
    renders_one :trigger
    renders_one :header, ->(title:) do
      HeaderComponent.new(title: title)
    end
    renders_one :footer

    attr_reader :size

    def initialize(size: :lg)
      @size = size
    end

    private

    def size_classes
      case size
      when :sm
        "max-w-sm"
      when :md
        "max-w-md"
      when :lg
        "max-w-lg"
      when :xl
        "max-w-xl"
      when :xxl
        "max-w-2xl"
      else
        "max-w-lg"
      end
    end

    class HeaderComponent < ViewComponent::Base
      attr_reader :title, :title_id

      def initialize(title:)
        @title = title
        @title_id = "modal-title-#{SecureRandom.hex(4)}"
      end

      def call
        content
      end
    end
  end
end
