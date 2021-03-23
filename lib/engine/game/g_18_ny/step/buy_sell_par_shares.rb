# frozen_string_literal: true

require_relative '../../../step/buy_sell_par_shares'

module Engine
  module Game
    module G18NY
      module Step
        class BuySellParShares < Engine::Step::BuySellParShares
          def actions(entity)
            return corporate_actions(entity) if !entity.player? && entity.owned_by?(current_entity)

            super
          end

          def corporate_actions(entity)
            actions = []
            if @round.current_actions.none?
              actions << 'sell_shares' unless @game.issuable_shares(entity).empty?
              actions << 'buy_shares' unless @game.redeemable_shares(entity).empty?
            end
            actions
          end

          def issuable_shares(entity)
            return [] if @corporate_action && entity != @corporate_action.entity

            # Done via Sell Shares
            @game.issuable_shares(entity)
          end

          def redeemable_shares(entity)
            return [] if @corporate_action && entity != @corporate_action.entity

            # Done via Buy Shares
            @game.redeemable_shares(entity)
          end

          def process_buy_shares(action)
            super
            pass!
          end

          def process_sell_shares(action)
            super
            pass!
          end

          def get_all_par_prices(corp)
            types = corp.type == :major ? %i[par] : %i[par_1]
            @game.stock_market.share_prices_with_types(types)
          end

          def get_par_prices(entity, corp)
            get_all_par_prices(corp).select { |sp| sp.price * 2 <= entity.cash }
          end

          def ipo_type(entity)
            # Major's are par, minors are bid
            entity.type == :major ? :par : :bid
          end
        end
      end
    end
  end
end
