# frozen_string_literal: true

require_relative '../buy_sell_par_shares'

module Engine
  module Step
    module G18ZOO
      class BuySellParShares < BuySellParShares

        def setup
          @game.just_ipoed = nil

          super
        end

        def can_buy_company?(player, company)
          !did_sell?(company, player)
        end

        def process_buy_company(action)
          entity = action.entity
          company = action.company
          price = action.price
          owner = company.owner

          company.owner = entity
          @game.bank_corporation.companies.delete(@game.bank_corporation.companies.select { |c| c.sym == company.sym }.first)

          entity.companies << company
          entity.spend(price, owner)
          @current_actions << action
          @log << "-- #{entity.name} buys #{company.name} from #{owner.name} for #{@game.format_currency(price)}"
        end

        def can_buy?(entity, bundle)
          return unless bundle
          return unless bundle.buyable

          corporation = bundle.corporation
          entity.cash >= bundle.price && can_gain?(entity, bundle) &&
              !@players_sold[entity][corporation] &&
              (can_buy_multiple?(entity, corporation) || !bought?) &&
              more_than_60_only_from_market(entity, bundle)
        end

        def more_than_60_only_from_market(entity, bundle)
          corporation = bundle.corporation
          ipo_share = corporation.shares[0]
          is_ipo_share = ipo_share == bundle
          percent = entity.percent_of(corporation)
          !is_ipo_share || percent < 60
        end

      end
    end
  end
end
