# frozen_string_literal: true

require_relative '../../../step/base'
require_relative '../../../step/passable_auction'

module Engine
  module Game
    module G1871
      module Step
        class Exchange < Engine::Step::Exchange
          # In 1871 exchanging is an action so it affects pass order
          def process_buy_shares(action)
            super

            # Make sure shares are buyable
            action.bundle.shares.each do |share|
              share.buyable = true
            end

            # This exchange does affect pass order
            @round.last_to_act = action.entity.player

            # Put a empty fake action onto the action list. This doesn't count
            # as a "buy" action but makes sure that this allows the user to
            # still act after.
            non_buy_action = Engine::Action::Base.new(action.entity)
            @round.current_actions << non_buy_action
          end
        end
      end
    end
  end
end
