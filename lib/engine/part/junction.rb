# frozen_string_literal: true

require 'engine/part/base'

module Engine
  module Part
    class Junction < Base
      def ==(other)
        other.class == Junction
      end

      def junction?
        true
      end
    end
  end
end
