# frozen_string_literal: true

require_relative '../../../step/buy_sell_par_shares'

module Engine
  module Game
    module GSteamOverHolland
      module Step
        class BuySellParShares < Engine::Step::BuySellParShares
          def can_ipo_any?(entity)
            number = ((@game.percent_to_float * 0.1) - 1).to_i

            !bought? && @game.corporations.any? do |c|
              @game.can_par?(c, entity) && can_buy?(entity, c.shares[number]&.to_bundle)
            end
          end

          def can_buy?(entity, bundle)
            return unless bundle&.buyable
            return false if entity == bundle.owner

            corporation = bundle.corporation
            available_cash(entity) >= modify_purchase_price(bundle) &&
              !@round.players_sold[entity][corporation] &&
              (can_buy_multiple?(entity, corporation, bundle.owner) || !bought?) &&
              can_gain?(entity, bundle)
          end

          def get_par_prices(entity, _corp)
            @game
              .stock_market
              .par_prices
              .select { |p| p.price * @game.percent_to_float * 0.1 <= available_cash(entity) }
          end

          def process_par(action)
            raise GameError, 'Cannot par on behalf of other entities' if action.purchase_for

            share_price = action.share_price
            corporation = action.corporation
            entity = action.entity
            number = ((@game.percent_to_float * 0.1) - 1).to_i

            raise GameError, "#{corporation.name} cannot be parred" unless @game.can_par?(corporation, entity)

            @game.stock_market.set_par(corporation, share_price)
            shares = corporation.ipo_shares.first(number)
            shares.each do |share|
              @round.players_bought[entity][corporation] += share.percent
              buy_shares(entity, share.to_bundle)
            end
            @game.after_par(corporation)
            track_action(action, action.corporation)
          end
        end
      end
    end
  end
end
