# frozen_string_literal: true

require_relative '../../../step/buy_sell_par_shares'

module Engine
  module Game
    module G1837
      module Step
        class BuySellParShares < Engine::Step::BuySellParShares
          UNBOUGHT_COMPANIES_ACTIONS = %w[buy_company pass].freeze

          PURCHASE_ACTIONS = Engine::Step::BuySellParShares::PURCHASE_ACTIONS + [Action]

          def actions(entity)
            return [] unless entity == current_entity
            return super unless unbought_companies?
            return [] unless can_buy_any_company?(entity)

            UNBOUGHT_COMPANIES_ACTIONS
          end

          def visible_corporations
            @game.sorted_corporations.reject { |c| c.type == :minor }
          end

          def hide_corporations?
            unbought_companies?
          end

          def unbought_companies?
            !@game.buyable_bank_owned_companies.empty?
          end

          def can_buy_any_company?(entity)
            return false unless entity.player?
            return false if bought?

            entity.cash >= @game.buyable_bank_owned_companies.min_by(&:value).value
          end

          def process_par(action)
            super
            @game.set_par(action.corporation, action.share_price, action.slot)
          end

          def can_sell?(entity, bundle)
            return false if bundle.corporation.type == :minor

            super
          end
        end
      end
    end
  end
end
