# frozen_string_literal: true

require_relative 'base'
require_relative 'node'

module Engine
  module Part
    class Junction < Base
      include Node

      def junction?
        true
      end
    end
  end
end
