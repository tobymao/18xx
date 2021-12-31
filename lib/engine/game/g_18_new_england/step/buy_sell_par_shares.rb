# frozen_string_literal: true

require_relative '../../../step/buy_sell_par_shares'

module Engine
  module Game
    module G18NewEngland
      module Step
        class BuySellParShares < Engine::Step::BuySellParShares
          def visible_corporations
            @game.stock_round_corporations
          end

          def get_par_prices(entity, _corp)
            @game.available_minor_par_prices.select { |p| p.price * 2 <= entity.cash }
          end

          def can_ipo_any?(entity)
            !bought? && @game.corporations.any? do |c|
              if c.type == :minor
                @game.can_par?(c, entity) && can_par_minor?(entity, c.shares.first&.to_bundle)
              else
                @game.can_par?(c, entity) && can_buy?(entity, c.shares.first&.to_bundle)
              end
            end
          end

          def can_par_minor?(entity, bundle)
            @game.available_minor_prices.any? { |p| 2 * p.price <= entity.cash } &&
              can_gain?(entity, bundle)
          end
        end
      end
    end
  end
end
