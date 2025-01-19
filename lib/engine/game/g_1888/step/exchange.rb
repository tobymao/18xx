# frozen_string_literal: true

require_relative '../../../step/exchange'
require_relative '../../../step/share_buying'
require_relative '../../../action/buy_shares'

module Engine
  module Game
    module G1888
      module Step
        class Exchange < Engine::Step::Exchange
          def can_exchange?(entity, bundle = nil)
            # This prevents the player from exchanging for a share if they've already sold shares in the same turn
            # This is a special rule for the published version of 1888 North
            return false if @round.current_actions.any? { |x| x.instance_of?(Action::SellShares) } && @game.north?

            super
          end

          def process_buy_shares(action)
            super

            # This makes the Forbidden City exchange count as a Buy action
            @round.current_actions << action if @game.north?
          end
        end
      end
    end
  end
end
