# frozen_string_literal: true

require_relative '../../../step/base'
require_relative 'upwards_auction'

module Engine
  module Game
    module GSystem18
      module Step
        class CharterAuction < GSystem18::Step::UpwardsAuction
          def all_passed!
            # Need to move entity round once more to be back to the priority deal player
            @round.next_entity_index!
            pass!
          end

          # don't update last_to_act since charter auctions don't affect PD
          def post_win_order(_winning_player)
            entities.each(&:unpass!)

            # start with player after the auction initiator
            @round.goto_entity!(@auction_triggerer)
            next_entity!
          end
        end
      end
    end
  end
end
