# frozen_string_literal: true

require_relative '../../../step/selection_auction'

module Engine
  module Game
    module G1837
      module Step
        class SelectionAuction < Engine::Step::SelectionAuction
          def actions(entity)
            return [] if @finished

            super
          end

          def description
            'Auction Start Packet items'
          end

          def may_bid?(_company)
            true
          end

          protected

          def initial_auction_entity
            nil
          end

          private

          def all_passed!
            @finished = true
            entities.each(&:unpass!)
          end

          def post_win_bid(winner, _company)
            entities.each(&:unpass!)
            @round.goto_entity!(winner.entity)
            next_entity!
          end
        end
      end
    end
  end
end
