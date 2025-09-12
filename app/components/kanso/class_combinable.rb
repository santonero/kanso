module Kanso
  module ClassCombinable
    extend ActiveSupport::Concern

    def combine_classes(component_classes_string, user_classes_value)
      component_classes_array = component_classes_string.split(" ")

      user_classes_array = clean_and_split_classes(user_classes_value)

      (component_classes_array + user_classes_array).compact.uniq.join(" ")
    end

    private

    def clean_and_split_classes(value)
      if value.nil?
        []
      elsif value.kind_of?(Array)
        value
      else
        value.split(" ")
      end
    end
  end
end
