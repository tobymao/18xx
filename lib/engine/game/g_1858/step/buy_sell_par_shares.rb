# frozen_string_literal: true

require_relative '../../../step/buy_sell_par_shares'

module Engine
  module Game
    module G1858
      module Step
        class BuySellParShares < Engine::Step::BuySellParShares
          # include Engine::Step::PassableAuction

          def actions(entity)
            return [] unless entity == current_entity
            return ['sell_shares'] if must_sell?(entity)

            actions = []

            # Sell actions
            actions << 'sell_shares' if can_sell_any?(entity)
            actions << 'exchange_private' if can_exchange_any?(entity)
            actions << 'convert' if can_convert_any?(entity)

            # Buy actions
            actions << 'buy_shares' if can_buy_any?(entity)
            actions << 'par' if can_ipo_any?(entity)
            actions << 'bid' if can_start_auction?(entity)

            actions << 'pass' unless actions.empty?

            actions
          end

          def process_par(action)
            super
            pass!
          end

          def convert_button_text
            'Convert to 10-share company'
          end

          def can_convert?(corporation)
            (corporation.owner == current_entity) && (corporation.type == :medium) && corporation.floated?
          end

          def can_convert_any?
            @game.corporations.any? { |corporation| can_convert?(corporation) }
          end

          def process_convert(action)
            @game.convert!(action.corporation)
          end

          def can_exchange_any?
            false # TODO: implement this
          end

          def can_start_auction?
            false # TODO: implement this
          end
        end
      end
    end
  end
end
