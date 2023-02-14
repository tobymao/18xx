# frozen_string_literal: true

require_relative '../../../step/track'
require_relative '../skip_coal_and_oil'
require_relative 'tracker'

module Engine
  module Game
    module G1868WY
      module Step
        class Track < Engine::Step::Track
          ACTIONS = %w[lay_tile credit_mobilier pass].freeze

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

          def actions(entity)
            return [] unless entity == current_entity
            return [] unless entity.corporation?
            return ACTIONS if can_lay_tile?(entity)

            %w[credit_mobilier pass]
          end

          def auto_actions(entity)
            credit_mobilier_resolve_pending!

            return [] unless entity == current_entity
            return [] unless entity.corporation?

            aa = @game.cm_connected.sort_by { |h, _| -h.column }.each_with_object([]) do |(hex, amount), actions|
              next unless amount.positive?
              next unless @game.omaha_connection?(hex)

              actions << Engine::Action::CreditMobilier.new(entity, hex: hex, amount: amount) if amount.positive?
            end

            aa << Engine::Action::Pass.new(entity) unless can_lay_tile?(entity)

            aa
          end

          def credit_mobilier_resolve_pending!
            @game.cm_connected, @game.cm_pending = @game.cm_pending.partition do |hex, _|
              @game.omaha_connection?(hex)
            end.map(&:to_h)
          end

          def process_credit_mobilier(action)
            hex = action.hex

            unless @game.loading
              unless hex.column < @game.cm_westernmost
                raise GameError, "Credit Mobilier cannot pay for column #{hex.column}, already paid for #{@game.cm_westernmost}"
              end
              unless @game.omaha_connection?(hex)
                raise GameError, "Credit Mobilier cannot pay for #{hex.name}, hex is not connected to Omaha"
              end
            end

            @game.cm_westernmost = hex.column
            @game.credit_mobilier_payout!(hex)

            @game.cm_connected.delete(hex)
            @game.cm_pending.delete(hex)
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
