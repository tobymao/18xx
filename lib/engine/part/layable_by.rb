# frozen_string_literal: true

require_relative 'base'

module Engine
  module Part
    class Unlayable < Base
      def unlayable?
        true
      end
    end
  end
end
