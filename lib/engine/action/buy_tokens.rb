# frozen_string_literal: true

require_relative 'base'

module Engine
  module Action
    class BuyTokens < Base
      attr_reader :entity

      def initialize(entity)
        @entity = entity
      end
    end
  end
end
