# frozen_string_literal: true

require_relative '../../g_1846/step/buy_sell_par_shares'

module Engine
  module Game
    module G18MO
      module Step
        class BuySellParShares < G1846::Step::BuySellParShares
          def can_sell?(entity, bundle)
            return unless bundle
            return if @game.exchanged_share && bundle.shares.include?(@game.exchanged_share)

            super
          end
        end
      end
    end
  end
end
