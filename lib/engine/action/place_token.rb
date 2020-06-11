# frozen_string_literal: true

require_relative 'base'

module Engine
  module Action
    class PlaceToken < Base
      attr_reader :city, :slot, :tokenidx

      def initialize(entity, city, slot, tokenidx = nil)
        @entity = entity
        @city = city
        @slot = slot
        @tokenidx = tokenidx
      end

      def self.h_to_args(h, game)
        [game.city_by_id(h['city']), h['slot'], h['tokenidx']]
      end

      def args_to_h
        h = {
          'city' => @city.id,
          'slot' => @slot,
        }
        h['tokenidx'] = @tokenidx if @tokenidx
        h
      end
    end
  end
end
