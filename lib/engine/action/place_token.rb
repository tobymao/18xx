# frozen_string_literal: true

require_relative 'base'

module Engine
  module Action
    class PlaceToken < Base
      attr_reader :city, :slot, :token

      def initialize(entity, city, slot, token_id = nil)
        @entity = entity
        @city = city
        @slot = slot
        # After processing the action the token may no longer be in the entity
        @token_id = token_id
        @token = @entity.tokens[token_id] unless token_id.nil?
      end

      def self.h_to_args(h, game)
        [game.city_by_id(h['city']), h['slot'], h['token_id']]
      end

      def args_to_h
        {
          'city' => @city.id,
          'slot' => @slot,
          'token_id' => @token_id,
        }
      end
    end
  end
end
