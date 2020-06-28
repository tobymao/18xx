# frozen_string_literal: true

require_relative 'node'

module Engine
  module Part
    class Junction < Node
      def junction?
        true
      end
    end
  end
end
