# frozen_string_literal: true

require_relative 'base'

module Engine
  module Action
    class RemoveToken < Base
      attr_reader :city, :slot, :token

      def initialize(entity, city:, slot:)
        @entity = entity
        @city = city
        @slot = slot
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
