# frozen_string_literal: true

require_relative 'base'

module Engine
  module Part
    class Junction < Base
      def junction?
        true
      end
    end
  end
end
