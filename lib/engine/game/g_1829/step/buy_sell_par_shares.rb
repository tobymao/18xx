# frozen_string_literal: true

require_relative '../../../step/buy_sell_par_shares'

module Engine
  module Game
    module G1829
      module Step
        class BuySellParShares < Engine::Step::BuySellParShares
          FIRST_SR_ACTIONS = %w[buy_company pass].freeze
          EXCHANGE_ACTIONS = %w[buy_shares pass].freeze

          def actions(entity)
            return [] unless entity&.player?

            result = super

            result.concat(FIRST_SR_ACTIONS) if can_buy_company?(entity)
            result.concat(EXCHANGE_ACTIONS) if can_exchange?(entity)
            result
          end

          def can_buy_company?(player, company = nil)
            return false if first_sr_passed?(player) || @game.num_certs(player) >= @game.cert_limit
            return buyable_company?(player, company) if company

            @game.buyable_bank_owned_companies.any? { |c| buyable_company?(player, c) }
          end

          def buyable_company?(player, company)
            return false if first_sr_passed?(player) || sold? || bought?
            return false if @game.bond?(company) && @round.players_sold[player][:bond]

            player.cash >= company.value
          end

          def buyable_bank_owned_companies
            @companies.select { |c| c.owner == @bank && c.revenue > 20 }
          end

          def available
            @companies.select { |c| !c.closed? && c.owner == @bank && c.revenue > 20 }
          end
        end
      end
    end
  end
end
