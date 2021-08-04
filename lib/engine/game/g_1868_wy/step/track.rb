# frozen_string_literal: true

require_relative '../../../step/track'
require_relative '../skip_coal_and_oil'

module Engine
  module Game
    module G1868WY
      module Step
        class Track < Engine::Step::Track
          include G1868WY::SkipCoalAndOil

          def lay_tile_action(action)
            super
            @game.spend_tile_lay_points(action)
          end

          def can_lay_tile?(entity)
            return true if super

            # if 1 track point remains and P7 can be bought, block in the track step
            (corporation = entity).corporation? &&
              @game.phase.status.include?('can_buy_companies') &&
              @game.p7_company.owned_by_player? &&
              @game.buying_power(entity).positive? &&
              @game.track_points_available(corporation) == (@game.class::YELLOW_POINT_COST - 1)
          end

          def legal_tile_rotation?(entity, hex, tile)
            if (tile.name == @game.class::BROWN_DOUBLE_BOOMCITY_TILE) ||
               ((upgrades = @game.class::TILE_UPGRADES[hex.tile.name]) && upgrades.include?(tile.name))
              hex.tile.exits & tile.exits == hex.tile.exits
            else
              super
            end
          end
        end
      end
    end
  end
end
