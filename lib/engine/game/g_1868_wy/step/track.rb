# frozen_string_literal: true

require_relative '../../../step/track'
require_relative '../skip_coal_and_oil'
require_relative 'tracker'

module Engine
  module Game
    module G1868WY
      module Step
        class Track < Engine::Step::Track
          include G1868WY::SkipCoalAndOil
          include G1868WY::Step::Tracker

          def can_lay_tile?(entity)
            return false if @game.skip_homeless_dpr?(entity)
            return true if super

            # if 1 track point remains and a track laying private can be bought,
            # block in the track step
            (corporation = entity).corporation? &&
              @game.phase.status.include?('can_buy_companies') &&
              (@game.dodge.owned_by_player? || @game.casement.owned_by_player?) &&
              @game.buying_power(entity).positive? &&
              @game.track_points_available(corporation) == (@game.class::YELLOW_POINT_COST - 1)
          end

          def legal_tile_rotation?(entity, hex, tile)
            if (upgrades = @game.class::TILE_UPGRADES[hex.tile.name]) && upgrades.include?(tile.name)
              (hex.tile.exits & tile.exits == hex.tile.exits) &&
                tile.exits.all? { |edge| hex.neighbors[edge] } &&
                !(tile.exits & hex_neighbors(entity, hex)).empty?
            else
              super
            end
          end

          def process_lay_tile(action)
            lay_tile_action(action)
          end
        end
      end
    end
  end
end
