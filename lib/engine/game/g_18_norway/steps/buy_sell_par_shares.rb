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
                  corporation.player_share_holders.reject do |p, _|
                    p == bundle.owner || p == @game.nsb
                  end.values.max.to_i < bundle.presidents_share.percent
              return false
            end

            super
          end
        end
      end
    end
  end
end
