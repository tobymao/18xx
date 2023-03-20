# frozen_string_literal: true

require_relative '../../../step/buy_sell_par_shares'

module Engine
  module Game
    module G1847AE
      module Step
        class BuySellParShares < Engine::Step::BuySellParShares
          def can_buy?(entity, bundle)
            return false unless super

            bundle = bundle.to_bundle
            double_cert = bundle.shares.find(&:double_cert)
            corporation = bundle.corporation
            # Filter out investor shares
            ipo_shares = corporation.ipo_shares.select(&:buyable)

            if double_cert && corporation.second_share_double && corporation.last_share_double
              return ipo_shares.size == 6 || ipo_shares.size == 1
            end

            return ipo_shares.size == 1 if double_cert && corporation.last_share_double

            return false if corporation.second_share_double && (ipo_shares.size == 6)

            true
          end

          def get_par_prices(_entity, corporation)
            [corporation.par_price]
          end

          def can_gain?(entity, bundle, exchange: false)
            return false if exchange && !@game.can_corporation_have_investor_shares_exchanged?(bundle.corporation)

            super(entity, bundle, exchange: exchange)
          end
        end
      end
    end
  end
end
