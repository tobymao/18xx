# frozen_string_literal: true

require_relative '../buy_sell_par_shares'
require_relative 'par_and_buy_actions'

module Engine
  module Step
    module G1893
      class BuySellParSharesFollowingSR < BuySellParShares
        def can_buy?(_entity, bundle)
          super && @game.buyable?(bundle.corporation)
        end

        def can_sell?(_entity, bundle)
          return !bought? if bundle.corporation == @game.adsk

          super && @game.buyable?(bundle.corporation)
        end

        def can_gain?(_entity, bundle, exchange: false)
          return false if exchange

          super && @game.buyable?(bundle.corporation)
        end

        def can_exchange?(_entity)
          false
        end

        include ParAndBuy

        def process_sell_shares(action)
          if action.bundle.corporation == @game.adsk
            sell_adsk(action.bundle)
          else
            # In case president's share is reserved, do not change presidency
            allow_president_change = action.bundle.corporation.presidents_share.buyable
            sell_shares(action.entity, action.bundle, swap: action.swap, allow_president_change: allow_president_change)
          end

          @round.last_to_act = action.entity
          @current_actions << action
        end

        private

        def sell_adsk(bundle)
          entity = bundle.owner
          price = bundle.price
          @log << "#{entity.name} sell #{bundle.percent}% " \
            "of #{bundle.corporation.name} and receives #{@game.format_currency(price)}"
          @game.share_pool.transfer_shares(bundle,
                                           @game.share_pool,
                                           spender: @bank,
                                           receiver: entity,
                                           price: price,
                                           allow_president_change: false)
        end
      end
    end
  end
end
