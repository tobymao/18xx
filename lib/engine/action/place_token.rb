# frozen_string_literal: true

require_relative 'base'

module Engine
  module Action
    class PlaceToken < Base
      attr_reader :city, :slot, :token

      def initialize(entity, city:, slot:, token_type: :normal)
        @entity = entity
        @city = city
        @slot = slot
        @token = @entity.next_token_by_type(token_type)
      end

      def self.h_to_args(h, game)
        {
          city: game.city_by_id(h['city']),
          slot: h['slot'],
          token_type: h['token_type'],
        }
      end

      def args_to_h
        token_type = @token.type if @token.type != :normal
        {
          'city' => @city.id,
          'slot' => @slot,
          'token_type' => token_type,
        }
      end
    end
  end
end
