# frozen_string_literal: true

require_relative '../../../step/waterfall_auction'

module Engine
  module Game
    module G2038
      module Step
        class WaterfallAuction < Engine::Step::WaterfallAuction
          def all_passed!
            super
          end

          def may_purchase?(company)
            return false unless super
            return true if @purchasing_first_minor
            is_minor = @game.minors.find { |m| m.id == company.id }
            return !is_minor
          end

          def min_bid(company)
            return unless company
            return company.min_bid if may_purchase?(company)
    
            high_bid = highest_bid(company)
            high_bid ? high_bid.price + min_increment : company.min_bid
          end

          def placement_bid(bid)
            @purchasing_first_minor = bid.company && bid.company == @companies.first
            super
            @purchasing_first_minor = false
          end
        end
      end
    end
  end
end
