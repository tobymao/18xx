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

          def sell_shares(entity, shares, swap: nil)
            raise GameError, "Cannot sell shares of #{shares.corporation.name}" if !can_sell?(entity, shares) && !swap

            allow_president_change = shares.corporation.type != :city

            @round.players_sold[shares.owner][shares.corporation] = :now
            @game.sell_shares_and_change_price(shares, swap: swap,  allow_president_change: allow_president_change)
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

          def can_sell?(entity, bundle)
            return unless bundle
            return false if entity != bundle.owner

            corporation = bundle.corporation

            timing = @game.check_sale_timing(entity, bundle)

            timing &&
              !(@game.class::MUST_SELL_IN_BLOCKS && @round.players_sold[entity][corporation] == :now) &&
              can_sell_order? &&
              (@game.share_pool.fit_in_bank?(bundle) || corporation.type == :city) &&
              can_dump?(entity, bundle)
          end

          def can_dump?(entity, bundle)
            return true if bundle.corporation.type == :city

            bundle.can_dump?(entity)
          end
        end
      end
    end
  end
end
