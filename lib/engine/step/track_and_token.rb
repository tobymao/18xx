# frozen_string_literal: true

require_relative 'track'

module Engine
  module Step
    class TrackAndToken < Track
      include Tokener
      ACTIONS = %w[lay_tile place_token pass].freeze
      # Very much a WIP

      def actions(entity)
        #return [] if current_entity != entity ||
        #  !(token = entity.next_token) ||
        #  min_token_price(token) > entity.cash ||
        #    !@game.graph.can_token?(entity)

        ACTIONS
      end

      def description
        'Place a Token or Lay Track'
      end

      def pass_description
        'Skip (Token/Track)'
      end

      def sequential?
        true
      end

      def process_place_token(action)
        entity = action.entity

        place_token(entity, action.city, action.token)
        pass! if @last_action
        @last_action = action
      end

      def process_lay_tile(action)
        lay_tile(action)
        pass! if @last_action
        @last_action = action
      end
    end
  end
end
