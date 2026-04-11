# frozen_string_literal: true

require_relative '../../../step/track'

module Engine
  module Game
    module G1835
      module Step
        class Track < Engine::Step::Track
          def check_track_restrictions!(entity, old_tile, new_tile)
            # Upgrading a double-town yellow to a single-town green merges two town nodes
            # into one, which would fail the normal "must preserve all exits" check.
            return if @game.class::YELLOW_DOUBLE_TOWN_UPGRADES.include?(new_tile.name)

            super
          end
        end
      end
    end
  end
end
