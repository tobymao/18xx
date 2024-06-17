# frozen_string_literal: true

require_relative '../../../step/buy_sell_par_shares_via_bid'

module Engine
  module Game
    module G1812
      module Step
        class BuySellParShares < Engine::Step::BuySellParSharesViaBid
          MIN_BID = 100
          MAX_MINOR_PAR = 100

          def can_bid_any?(entity)
            return false if max_bid(entity) < MIN_BID || bought?

            @game.minors.any? { |m| @game.can_par?(m, entity) }
          end

          def can_par?(entity, _parrer)
            return false if entity.type != :minor && @game.phase.name.to_i < 5
            return false if entity.type == :minor && @game.phase.name.to_i > 3

            super
          end
        end
      end
    end
  end
end
