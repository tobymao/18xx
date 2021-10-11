# frozen_string_literal: true

require_relative 'base'

module Engine
  module Action
    class Pass < Base
      def pass?
        true
      end
    end
  end
end
