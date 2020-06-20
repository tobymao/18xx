# frozen_string_literal: true

require_relative 'base'

module Engine
  module Part
    class LayableBy < Base
      attr_reader :entities

      def initialize(entities)
        @entities = entities
      end

      def layable_by?
        true
      end
    end
  end
end
