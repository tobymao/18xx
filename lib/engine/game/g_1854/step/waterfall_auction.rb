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

          def setup
            super
            original_companies = @game.initial_auction_companies.sort_by(&:value)
            @companies = @game.companies.select {|company| !company.owned_by_player? && !company.closed? }
            @cheapest = original_companies.first
          end

          def all_passed!
            # Everyone has passed so we need to run a fake OR.
            if @companies.include?(@cheapest)
              # No one has bought anything so we reduce the value of the cheapest company.
              increase_discount!(@cheapest, 5)
            else
              @game.trigger_auction_or
            end

            entities.each(&:unpass!)
          end
        end
      end
    end
  end
end
