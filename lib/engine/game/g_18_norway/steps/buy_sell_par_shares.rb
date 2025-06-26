# frozen_string_literal: true

require_relative '../../../step/buy_sell_par_shares'

module Engine
  module Game
    module G18Norway
      module Step
        class BuySellParShares < Engine::Step::BuySellParShares
          def can_dump?(entity, bundle)
            corporation = bundle.corporation
            # Check if selling would make NSB president
            if bundle.shares.any?(&:president) &&
                  corporation.share_holders[@game.nsb] >= bundle.presidents_share.percent &&
                  corporation.player_share_holders.none? do |sh, pct|
                    next false if sh == bundle.owner

                    pct >= bundle.presidents_share.percent
                  end
              return false
            end

            super
          end
        end
      end
    end
  end
end
