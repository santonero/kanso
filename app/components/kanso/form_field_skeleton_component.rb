# frozen_string_literal: true

module Kanso
  class FormFieldSkeletonComponent < ViewComponent::Base
    attr_reader :fields

    def initialize(fields: 1)
      @fields = fields
    end
  end
end
