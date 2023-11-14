# frozen_string_literal: true

require_relative '../../../step/buy_sell_par_shares'

module Engine
  module Game
    module GSteamOverHolland
      module Step
        class BuySellParShares < Engine::Step::BuySellParShares
          def sell_shares_and_change_price(bundle, allow_president_change: true, swap: nil, movement: nil)
            super
            num_shares = bundle.num_shares
            unless bundle.owner == corporation.owner
              # This allows for the ledges that prevent price drops unless the president is selling
              case corporation.share_price.type
              when :ignore_sale_unless_president
                num_shares = 0
              when :max_one_drop_unless_president
                num_shares = 1
              when :max_two_drops_unless_president
                num_shares = 2 unless num_shares == 1
              end
            end
            num_shares.times { @stock_market.move_down(corporation) }
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
        end
      end
    end
  end
end
