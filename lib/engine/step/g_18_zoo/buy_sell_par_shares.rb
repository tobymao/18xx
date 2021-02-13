# frozen_string_literal: true

require_relative '../buy_sell_par_shares'
require_relative 'sell_company'
require_relative 'choose_power'

module Engine
  module Step
    module G18ZOO
      class BuySellParShares < BuySellParShares
        include SellCompany
        include ChoosePower

        def actions(entity)
          return [] unless entity == current_entity
          return ['sell_shares'] if must_sell?(entity)

          actions = []
          actions << 'buy_shares' if can_buy_any?(entity)
          actions << 'par' if can_ipo_any?(entity)
          actions << 'buy_company' unless purchasable_unsold_companies.empty?
          actions << 'sell_shares' if can_sell_any?(entity)
          actions << 'sell_company' if can_sell_any_companies?(entity)
          actions << 'choose' if choice_available?(entity)
          actions << 'pass' unless actions.empty?
          actions
        end

        def can_buy_company?(player, _company)
          player.companies.count { |c| !c.name.start_with?('ZOOTicket') } < 3
        end

        def process_buy_company(action)
          super

          @game.available_companies.delete(action.company)
          @game.apply_custom_ability(action.company)
        end

        def get_par_prices(_entity, _corp)
          super.reject do |p|
            (p.price == 9 && !@game.phase.tiles.include?(:green)) ||
            (p.price == 12 && !@game.phase.tiles.include?(:brown))
          end
        end

        def can_buy?(entity, bundle)
          super && more_than_80_only_from_market(entity, bundle)
        end

        def more_than_80_only_from_market(entity, bundle)
          corporation = bundle.corporation
          ipo_share = corporation.shares[0]
          is_ipo_share = ipo_share == bundle
          percent = entity.percent_of(corporation)
          !is_ipo_share || percent < 80
        end

        def log_pass(entity)
          return @log << "#{entity.name} passes" if @current_actions.empty?
          return if bought? && sold?

          action = bought? ? 'to sell' : 'to buy'
          @log << "#{entity.name} declines #{action} shares"
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
