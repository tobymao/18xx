# frozen_string_literal: true

require_relative '../../../step/tracker'

module Engine
  module Game
    module G1894
      module Tracker
        include Engine::Step::Tracker

        def check_track_restrictions!(entity, old_tile, new_tile)
          return if @game.loading || !entity.operator?
          return if @game.class::GREEN_CITY_TILES.include?(old_tile.name)

          super
        end
      end
    end
  end
end
