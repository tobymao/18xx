# frozen_string_literal: true

require_relative 'base'
require_relative 'tokener'

module Engine
  module Step
    class HomeToken < Base
      include Tokener
      ACTIONS = %w[place_token].freeze

      def actions(entity)
        return [] unless current_entity == entity

        ACTIONS
      end

      def round_state
        {
          place_home_token: [],
        }
      end

      def active?
        place_home_token
      end

      def active_entities
        [place_home_token&.first].compact
      end

      def place_home_token
        @round.place_home_token&.first
      end

      def description
        if current_entity != place_home_token[2].corporation
          "Place #{place_home_token[2].corporation.name} Home Token"
        else
          'Place Home Token'
        end
      end

      def available_hex(hex)
        hex == place_home_token[1]
      end

      def available_tokens
        [place_home_token[2]]
      end

      def process_place_token(action)
        # Ignore the token and the corporation doing the laying
        place_token(place_home_token[2].corporation, action.city, place_home_token[2], teleport: true)
        @round.place_home_token.shift
      end
    end
  end
end
