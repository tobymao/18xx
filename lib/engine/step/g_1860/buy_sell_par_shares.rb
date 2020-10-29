# frozen_string_literal: true

require_relative '../base'
require_relative '../share_buying'
require_relative '../../action/buy_company.rb'
require_relative '../../action/buy_shares'
require_relative '../../action/par'

module Engine
  module Step
    module G1860
      class BuySellParShares < BuySellParShares
        include ShareBuying

        def actions(entity)
          return [] unless entity == current_entity
          return ['sell_shares'] if must_sell?(entity)

          actions = []
          actions << 'buy_shares' if can_buy_any?(entity)
          actions << 'par' if can_ipo_any?(entity)
          actions << 'buy_company' if can_buy_any_companies?(entity)
          actions << 'sell_shares' if can_sell_any?(entity)

          actions << 'pass' if actions.any?
          actions
        end

        def purchasable_companies(_entity)
          []
        end

        def can_buy_any_companies?(entity)
          return false if bought? ||
            !entity.cash.positive? ||
            @game.num_certs(entity) >= @game.cert_limit

          @game.companies_in_bank.any?
        end

        def get_par_prices(_entity, corp)
          @game.par_prices(corp)
        end

        def sell_shares(entity, shares)
          @game.game_error("Cannot sell shares of #{shares.corporation.name}") unless can_sell?(entity, shares)

          @players_sold[shares.owner][shares.corporation] = :now
          @game.sell_shares_and_change_price(shares)
        end

        def bought?
          @current_actions.any? { |x| self.class::PURCHASE_ACTIONS.include?(x.class) }
        end

        def process_buy_company(action)
          player = action.entity
          company = action.company
          price = action.price
          owner = company.owner

          @game.game_error("Cannot buy #{company.name} from #{owner.name}") unless owner == @game.bank

          company.owner = player

          player.companies << company
          player.spend(price, owner)
          @current_actions << action
          @log << "#{player.name} buys #{company.name} from #{owner.name} for #{@game.format_currency(price)}"
        end
      end
    end
  end
end
