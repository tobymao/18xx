# frozen_string_literal: true

require_relative '../buy_sell_par_shares'

module Engine
  module Step
    module G18ZOO
      class BuySellParShares < BuySellParShares
        def actions(entity)
          return [] unless entity == current_entity
          return ['sell_shares'] if must_sell?(entity)

          actions = []
          actions << 'buy_shares' if can_buy_any?(entity)
          actions << 'par' if can_ipo_any?(entity)
          actions << 'buy_company' unless purchasable_unsold_companies.empty?
          actions << 'sell_shares' if can_sell_any?(entity)
          actions << 'pass' unless actions.empty?
          actions
        end

        def can_buy_company?(player, _company)
          player.companies.count { |c| !c.name.start_with?('ZOOTicket') } < 3
        end

        def process_buy_company(action)
          super

          @game.available_companies.delete(action.company)
        end

        private

        def purchasable_unsold_companies
          return [] if bought?

          @game.available_companies
        end
      end
    end
  end
end
