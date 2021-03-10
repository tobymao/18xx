# frozen_string_literal: true

require_relative 'choose_ability_on_sr'

module Engine
  module Game
    module G18ZOO
      module Step
        class BuySellParShares < Engine::Step::BuySellParShares
          include Engine::Game::G18ZOO::ChooseAbilityOnSr

          def actions(entity)
            return ['choose_ability'] if entity.company? && can_choose_ability?(entity)

            actions = super
            actions << 'choose_ability' if entity.player? && can_choose_any_ability?(entity)
            actions << 'pass' unless actions.empty?
            actions.uniq
          end

          def can_buy_company?(player, _company)
            player.companies.count { |c| !@game.zoo_ticket?(c) } < 3
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
            super # TODO: add log logic to handle sell / par / buy / sell company / use power
          end

          def purchasable_companies(_entity)
            return [] if bought?

            @game.available_companies
          end
        end
      end
    end
  end
end
