# frozen_string_literal: true

require_relative 'base'

module Engine
  module Action
    class PlaceToken < Base
      attr_reader :city, :slot, :token

      def initialize(entity, city:, slot:, token_type: nil)
        @entity = entity
        @city = city
        @slot = slot
        # token may be nil because when you upgrade someone's 00
        # and place their token, you pretend to be them and you may not have a token
        @token = @entity.find_token_by_type(token_type&.to_sym)
      end

      def self.h_to_args(h, game)
        {
          city: game.city_by_id(h['city']),
          slot: h['slot'],
          token_type: h['token_type'],
        }
      end

      def args_to_h
        {
          'city' => @city.id,
          'slot' => @slot,
          'token_type' => @token&.type == :normal ? nil : @token&.type,
        }
      end
    end
  end
end
