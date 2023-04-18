# frozen_string_literal: true

require_relative 'base'
require_relative 'tokener'

module Engine
  module Step
    class Token < Base
      include Tokener
      ACTIONS = %w[place_token pass].freeze

      def actions(entity)
        return [] unless entity == current_entity
        return [] unless can_place_token?(entity)

        ACTIONS
      end

      def description
        'Place a Token'
      end

      def pass_description
        'Skip (Token)'
      end

      def available_hex(entity, hex)
        tokener_available_hex(entity, hex)
      end

      def process_place_token(action)
        entity = action.entity

        place_token(entity, action.city, action.token)
        pass!
      end
    end
  end
end
