# frozen_string_literal: true

require_relative '../../../step/buy_sell_par_shares'

module Engine
  module Game
    module G1847AE
      module Step
        class BuySellParShares < Engine::Step::BuySellParShares
          def can_buy?(entity, bundle)           
            return false unless super

            # For NDB the 2 first non president certificates sold need to be 20% ones


            bundle = bundle.to_bundle
            double_cert = bundle.shares.find(&:double_cert)
            corporation = bundle.corporation

            if double_cert && corporation.second_share_double && corporation.last_share_double
              return corporation.ipo_shares.size == 6 || corporation.ipo_shares.size == 1
            elsif double_cert && corporation.last_share_double
              return corporation.ipo_shares.size == 1
            elsif corporation.second_share_double
              return false if corporation.ipo_shares.size == 6
            end

            return true
          end
        end
      end
    end
  end
end
