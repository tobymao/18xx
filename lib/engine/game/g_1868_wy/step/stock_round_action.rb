# frozen_string_literal: true

require_relative '../../../step/buy_sell_par_shares'
require_relative '../../../step/tokener'

module Engine
  module Game
    module G1868WY
      module Step
        # a Stock Round action is one of the following:
        # - sell then buy
        # - choose new home for DPR after all its tokens BUST
        # - exchange Ames Bros private for UP double share, then may sell 1-2 of those shares
        class StockRoundAction < Engine::Step::BuySellParShares
          def description
            'Stock Round Action'
          end

          def actions(entity)
            return [] if tokened?
            return [] unless entity == current_entity
            return ['sell_shares'] if must_sell?(entity)

            actions = []
            actions << 'sell_shares' if can_sell_any?(entity)
            actions << 'buy_shares' if can_buy_any?(entity)
            actions << 'par' if can_ipo_any?(entity)
            actions << 'pass' unless actions.empty?

            actions
          end

          def get_par_prices(entity, _corp)
            @game.par_prices.select { |p| p.price * 2 <= entity.cash }
          end

          def process_buy_shares(action)
            entity = action.entity
            player = entity.player
            bundle = action.bundle

            buy_shares(player, bundle)

            track_action(action, bundle.corporation)
          end

          def process_sell_shares(action)
            player = action.entity
            bundle = action.bundle
            corporation = bundle.corporation

            sell_shares(player, bundle)
            track_action(action, corporation)
          end
        end
      end
    end
  end
end
