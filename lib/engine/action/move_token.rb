# frozen_string_literal: true

require_relative 'base'

module Engine
  module Action
    class MoveToken < Base
      attr_reader :city, :slot, :token

      def initialize(entity, city:, slot:, token:)
        @entity = entity
        @city = city
        @slot = slot
        @token = token
      end

      def self.h_to_args(h, game)
        {
          city: game.city_by_id(h['city']),
          slot: h['slot'],
          token: game.corporation_by_id(h['corporation']).tokens[h['token']],
        }
      end

      def args_to_h
        {
          'city' => @city.id,
          'slot' => @slot,
          'corporation' => @token.corporation.id,
          'token' => @token.corporation.tokens.find_index(@token),
        }
      end
    end
  end
end
