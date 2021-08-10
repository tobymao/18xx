# frozen_string_literal: true

require_relative '../../../step/buy_sell_par_shares'

module Engine
  module Game
    module G1829
      module Step
        class BuySellParShares < Engine::Step::BuySellParShares
          def actions(_entity)
            %w[buy_shares buy_company pass]
          end

          def can_buy_company?(player, company = nil)
            return false if @game.num_certs(player) >= @game.cert_limit
            return buyable_company?(player, company) if company

            @game.buyable_bank_owned_companies.any? { |c| buyable_company?(player, c) }
          end

          def buyable_company?(player, company)
            return false if sold? || bought?

            player.cash >= company.value
          end

          def buyable_bank_owned_companies
            @companies.select { |c| c.owner == @bank && c.revenue > 20 }
          end
        end
      end
    end
  end
end
