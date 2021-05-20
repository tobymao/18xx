# frozen_string_literal: true

require_relative '../../../step/buy_sell_par_shares'

module Engine
  module Game
    module G1840
      module Step
        class BuySellParShares < Engine::Step::BuySellParShares
          def actions(entity)
            return ['choose_ability'] if entity.company?

            return [] unless entity == current_entity

            actions = []
            actions << 'buy_shares' if can_buy_any?(entity)
            actions << 'par' if can_ipo_any?(entity)
            actions << 'sell_shares' if can_sell_any?(entity)

            actions << 'pass' if !actions.empty? && @game.all_major_corporations_ipoed?

            actions << 'choose_ability' if !actions.empty? && entity.player? && !entity.companies.empty?

            actions
          end

          def get_par_prices(entity, corp)
            @game.par_prices(corp).select { |p| p.price * 5 <= entity.cash }
          end

          def can_buy?(entity, bundle)
            super && (@game.all_major_corporations_ipoed? || !bundle.corporation.ipoed)
          end

          def process_buy_shares(action)
            @round.bought_from_ipo = true if action.bundle.owner.corporation?

            allow_president_change = action.bundle.corporation.type != :city
            buy_shares(action.entity, action.bundle, swap: action.swap, allow_president_change: allow_president_change)

            track_action(action, action.bundle.corporation)
          end

          def visible_corporations
            @game.corporations.reject { |item| item.type == :minor }
          end

          def choices_ability(company)
            @game.sell_company_choice(company)
          end

          def process_choose_ability(action)
            company = action.entity
            @game.sell_company(company)
          end
        end
      end
    end
  end
end
