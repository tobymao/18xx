# frozen_string_literal: true

require_relative '../../../step/concession_auction'

module Engine
  module Game
    module G1841
      module Step
        class ConcessionAuction < Engine::Step::ConcessionAuction
          MIN_BID = 20

          def description
            if @auctioning
              'Bid on Selected Concession'
            else
              'Bid on Concession'
            end
          end

          def min_bid(company)
            return unless company

            high_bid = highest_bid(company)
            high_bid ? high_bid.price + min_increment : MIN_BID
          end
        end
      end
    end
  end
end
