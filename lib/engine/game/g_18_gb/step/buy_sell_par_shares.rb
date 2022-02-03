# frozen_string_literal: true

require_relative '../../../step/buy_sell_par_shares'

module Engine
  module Game
    module G18GB
      module Step
        class BuySellParShares < Engine::Step::BuySellParShares
          def actions(entity)
            return ['choose_ability'] unless choices_ability(entity).empty?
            return [] unless entity == current_entity
            return ['sell_shares'] if must_sell?(entity)

            actions = []
            actions << 'buy_shares' if can_buy_any?(entity)
            actions << 'par' if can_ipo_any?(entity)
            actions << 'sell_shares' if can_sell_any?(entity)
            actions << 'choose_ability' unless abilities(entity).empty?

            actions << 'pass' unless actions.empty?
            actions
          end

          def abilities(entity, **kwargs, &block)
            return {} unless entity.company?

            @game.abilities(entity, :choose_ability, **kwargs, &block)
          end

          def choices_ability(company)
            return {} unless company.company?

            ability = @game.abilities(company, :choose_ability)
            return {} unless ability

            ability.choices
          end

          def process_choose_ability(action)
            return unless action.choice.start_with?('close')
            return unless action.entity.company?

            @game.close_company(action.entity)
          end

          def ipo_buy_forbidden(entity, corporation, extra_percent)
            return false if corporation.share_price&.type == :unlimited

            percent = entity.percent_of(corporation) + extra_percent
            percent > 60
          end

          def can_buy?(entity, bundle)
            return unless bundle&.buyable

            corporation = bundle.corporation

            return if @game.married_to_lnwr(entity) && corporation.id != 'LNWR'

            entity.cash >= bundle.price &&
              !@round.players_sold[entity][corporation] &&
              (can_buy_multiple?(entity, corporation, bundle.owner) || !bought?) &&
              !(bundle.owner == corporation && ipo_buy_forbidden(entity, corporation, bundle.percent)) &&
              can_gain?(entity, bundle)
          end

          def can_sell?(entity, bundle)
            return super unless @game.class::PRESIDENT_SALES_TO_MARKET
            return unless bundle

            corporation = bundle.corporation

            timing = @game.check_sale_timing(entity, corporation)

            timing &&
              !(@game.class::MUST_SELL_IN_BLOCKS && @round.players_sold[entity][corporation] == :now) &&
              can_sell_order? &&
              @game.share_pool.fit_in_bank?(bundle) &&
              can_dump?(entity, bundle)
          end

          # can't sell partial president's share to pool if pool is empty
          def can_dump?(entity, bundle)
            corp = bundle.corporation
            return true if !bundle.presidents_share || bundle.percent >= corp.presidents_percent

            max_shares = corp.player_share_holders.reject { |p, _| p == entity }.values.max || 0
            return true if max_shares > 10

            pool_shares = @game.share_pool.percent_of(corp) || 0
            pool_shares.positive?
          end
        end
      end
    end
  end
end
