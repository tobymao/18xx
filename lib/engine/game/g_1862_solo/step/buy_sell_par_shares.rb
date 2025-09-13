# frozen_string_literal: true

require_relative '../../../step/buy_sell_par_shares'

module Engine
  module Game
    module G1862Solo
      module Step
        class BuySellParShares < Engine::Step::BuySellParShares
          ACTIONS = %w[buy_company pass].freeze

          def actions(entity)
            return [] unless entity == current_entity

            actions = ACTIONS.dup
            actions << 'sell_shares' if can_sell_any?(entity)
            actions
          end

          # Shares only bought as companies
          def visible_corporations
            []
          end

          def can_buy_company?(player, company)
            @game.ipo_rows.flatten.include?(company) && available_cash(player) >= company.value
          end

          def get_par_prices(entity, _corp)
            @game.repar_prices.select { |p| p.price * 3 <= entity.cash }
          end
        end
      end
    end
  end
end
