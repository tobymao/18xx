# frozen_string_literal: true

require_relative '../../../step/buy_sell_par_shares'

module Engine
  module Game
    module G1830
      module Step
        class BuySellParShares < Engine::Step::BuySellParShares
          def can_buy_multiple?(entity, corporation, owner)
            # Use Lookout rule by default
            super && (owner.share_pool? || @game.optional_rules&.include?(:multiple_brown_from_ipo))
          end
        end
      end
    end
  end
end
