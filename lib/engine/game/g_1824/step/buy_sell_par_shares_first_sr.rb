# frozen_string_literal: true

require_relative '../../../step/buy_sell_par_shares'

module Engine
  module Game
    module G1824
      module Step
        class BuySellParSharesFirstSr < Engine::Step::BuySellParShares
          def can_buy_company?(_player, _company)
            !bought?
          end

          def can_sell?(_entity, _bundle)
            false
          end

          def can_gain?(_entity, bundle, exchange: false)
            exchange ? false : super
          end

          def can_exchange?(_entity)
            false
          end

          def visible_corporations
            @game.sorted_corporations.reject { |c| c.closed? || c.type == :minor }
          end
        end
      end
    end
  end
end
