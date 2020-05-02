# frozen_string_literal: true

require_relative 'base'

module Engine
  module Part
    class Junction < Base
      def matches(other)
        other.junction?
      end

      def junction?
        true
      end
    end
  end
end
