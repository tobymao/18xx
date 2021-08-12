# frozen_string_literal: true

require_relative '../../../step/buy_sell_par_shares_companies'

module Engine
  module Game
    module G1829
      module Step
        class BuySellParSharesCompanies < Engine::Step::BuySellParSharesCompanies
          def actions(entity)
            return [] unless entity == current_entity
            return ['sell_shares'] if must_sell?(entity)

            actions = []
            actions << 'buy_shares' if can_buy_any?(entity)
            actions << 'buy_company' if can_buy_any_companies?(entity)
            actions << 'sell_shares' if can_sell_any?(entity)

            actions << 'pass' unless actions.empty?
            actions
          end

          def can_buy_any_companies?(entity)
            return false if
              @game.num_certs(entity) >= @game.cert_limit

            @game.companies.any? { |c| c.owner == @bank && !c.closed? }
          end
        end
      end
    end
  end
end
