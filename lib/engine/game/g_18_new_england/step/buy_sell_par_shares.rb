# frozen_string_literal: true

require_relative '../../../step/buy_sell_par_shares'

module Engine
  module Game
    module G18NewEngland
      module Step
        class BuySellParShares < Engine::Step::BuySellParShares
          def visible_corporations
            @game.corporations.select { |c| c.type == :minor || c.ipoed }
          end

          def get_par_prices(entity, _corp)
            @game.available_minor_prices.select { |p| p.price * 2 <= entity.cash }
          end
        end
      end
    end
  end
end
