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

          def help
            return unless @game.tokenless_dpr?(current_entity)

            'DPR may lay/upgrade a city tile to make room for its new home token.'
          end

          def setup
            super

            @game.cm_connected = {}
            @game.cm_pending = {}
          end

          def can_lay_tile?(entity)
            return false if @game.tokenless_dpr?(entity) && @round.num_laid_track.positive?
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
            return actions_for_tokenless_dpr(entity) if @game.tokenless_dpr?(entity)
            return self.class::ACTIONS_WITH_PASS if can_lay_tile?(entity)

            %w[credit_mobilier pass]
          end

          def process_pass(action)
            log_pass(action.entity) if can_lay_tile?(action.entity)
            pass!
          end

          def hex_neighbors(entity, _hex)
            @game.tokenless_dpr?(entity) ? (0..5).to_a : super
          end

          def actions_for_tokenless_dpr(dpr)
            return %w[credit_mobilier pass] if @round.num_laid_track.positive?
            return ACTIONS_WITH_PASS if @game.home_token_locations(dpr).empty?

            []
          end
        end
      end
    end
  end
end
