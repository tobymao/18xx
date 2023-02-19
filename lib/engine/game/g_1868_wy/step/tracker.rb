# frozen_string_literal: true

require_relative '../../../step/tracker'

module Engine
  module Game
    module G1868WY
      module Step
        module Tracker
          ACTIONS = %w[lay_tile credit_mobilier].freeze
          ACTIONS_WITH_PASS = %w[lay_tile credit_mobilier pass].freeze

          def lay_tile_action(action, **kwargs)
            super
            @game.spend_tile_lay_points(action)
          end

          def tracker_available_hex(entity, hex, check_billings: true)
            if @game.billings_hex?(hex)
              super(entity, hex) ||
                (check_billings && tracker_available_hex(entity, @game.other_billings(hex), check_billings: false))
            else
              super(entity, hex)
            end
          end

          def auto_actions(entity)
            credit_mobilier_resolve_pending!

            aa = @game.cm_connected.sort_by { |h, _| -h.column }.each_with_object([]) do |(hex, amount), actions|
              next unless amount.positive?
              next unless @game.omaha_connection?(hex)

              actions << Engine::Action::CreditMobilier.new(entity, hex: hex, amount: amount) if amount.positive?
            end

            aa << Engine::Action::Pass.new(entity) if entity.corporation? && !can_lay_tile?(entity)

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
        end
      end
    end
  end
end
