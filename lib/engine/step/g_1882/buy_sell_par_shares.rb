# frozen_string_literal: true

require_relative '../buy_sell_par_shares'

module Engine
  module Step
    module G1882
      class BuySellParShares < BuySellParShares
        def can_buy?(entity, bundle)
          return unless bundle

          if bundle.corporation.id == 'SC' && !bundle.corporation.ipoed
            # SC is ipoed for half price.

            corporation = bundle.corporation
            entity.cash >= bundle.price_per_share && can_gain?(entity, bundle) &&
              !@players_sold[entity][corporation] &&
              (can_buy_multiple?(corporation) || !bought?)
          else
            super
          end
        end

        def process_par(action)
          if action.corporation.id == 'SC'
            share_price = action.share_price
            corporation = action.corporation
            raise GameError, "#{corporation} cannot be parred" unless corporation.can_par?(action.entity)

            @game.stock_market.set_par(corporation, share_price)
            share = corporation.shares.first
            bundle = share.to_bundle
            @game.share_pool.buy_shares(action.entity,
                                        bundle,
                                        exchange: corporation.par_via_exchange,
                                        exchange_price: bundle.price_per_share)

            @game.add_extra_train_when_sc_pars(corporation)

            # SC chooses home token now.
            @game.place_home_token(corporation)
            corporation.par_via_exchange.close!

            @current_actions << action
          else
            super
          end
        end
      end
    end
  end
end
