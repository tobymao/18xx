# frozen_string_literal: true

require_relative 'buy_sell_par_shares'

module Engine
  module Game
    module G1824
      module Step
        class BuySellParSharesFirstSr < G1824::Step::BuySellParShares
          def can_sell?(_entity, _bundle)
            false
          end

          def can_gain?(_entity, bundle, exchange: false)
            exchange ? false : super
          end

          def can_exchange?(_entity)
            false
          end
        end
      end
    end
  end
end
