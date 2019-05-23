# frozen_string_literal: true

module Engine
  module Action
    class Pass < Base
      attr_reader :entity

      def initialize(entity)
        @entity = entity
      end

      def pass?
        true
      end
    end
  end
end
