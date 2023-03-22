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

          def setup
            super

            @game.cm_connected = {}
            @game.cm_pending = {}
          end

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
            case tile.name
            when 'YL', 'YG', 'GL', 'GG'
              tile.rotation.zero?
            else
              super
            end
          end

          def process_lay_tile(action)
            lay_tile_action(action)
          end

          def actions(entity)
            return [] unless entity == current_entity
            return [] unless entity.corporation?
            return self.class::ACTIONS_WITH_PASS if can_lay_tile?(entity)

            %w[credit_mobilier pass]
          end

          def process_pass(action)
            log_pass(action.entity) if can_lay_tile?(action.entity)
            pass!
          end
        end
      end
    end
  end
end
