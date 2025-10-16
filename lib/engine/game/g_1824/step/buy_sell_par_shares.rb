# frozen_string_literal: true

require_relative '../../../step/buy_sell_par_shares'

module Engine
  module Game
    module G1824
      module Step
        class BuySellParShares < Engine::Step::BuySellParShares
          def visible_corporations
            @game.sorted_corporations.reject { |c| c.closed? || c.type == :minor || c.type == :construction_railway }
          end

          def allow_president_change?(corporation)
            # In case of Staatsbahn, president change is only allowed after formation
            return false if @game.staatsbahn?(corporation) && !corporation.floated?

            reserved = corporation.reserved_shares
            reserved.none? { |s| s.percent == 20 }
          end
        end
      end
    end
  end
end
