# frozen_string_literal: true

require_relative 'label'

module Engine
  module Part
    class OptionalLabel < Label
      def optional_label?
        true
      end
    end
  end
end
