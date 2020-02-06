# frozen_string_literal: true

require 'engine/action/base'

module Engine
  module Action
    class PlaceToken < Base
      attr_reader :entity, :city

      def initialize(entity, city)
        @entity = entity
        @city = city
      end

      def copy(game)
        self.class.new(
          game.corporation_by_name(@entity.name),
          game.city_by_id(@city.id),
        )
      end
    end
  end
end
