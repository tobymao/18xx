# frozen_string_literal: true

require_relative '../../../step/waterfall_auction'

module Engine
  module Game
    module G1854
      module Step
        class WaterfallAuction < Engine::Step::WaterfallAuction
          def actions(entity)
            return [] if @game.need_auction_or

            super
          end

          def all_passed!
            # FIXME: currently auction is not always resuming with the correct player
            if @companies.include?(@game.first_company)
              # No one has bought anything so we reduce the value of the cheapest company.
              increase_discount!(@game.first_company, 5)
            else
              # Everyone has passed so we need to run an OR.
              @game.trigger_auction_or
            end

            entities.each(&:unpass!)
          end
        end
      end
    end
  end
end
