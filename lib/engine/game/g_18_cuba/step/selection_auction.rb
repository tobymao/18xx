# frozen_string_literal: true

require_relative '../../../step/base'
require_relative '../../../step/passable_auction'

module Engine
  module Game
    module G18Cuba
      module Step
        class SelectionAuction < Engine::Step::SelectionAuction
          def setup
            # Initializes the auction: gets commissioners, sets the starting player, and starts the first auction
            setup_auction
            @companies = @game.commissioners.dup
            @cheapest = @companies.first
            @auction_triggerer = current_entity
            auction_entity(@cheapest)
          end

          def round_state
            {
              companies_pending_par: [],
            }
          end

          def post_win_bid(_winner, _company)
            # After a commission (company) is won, rotate the auction starter to the next player.
            # Reset all pass states and automatically begin the next auction, if any
            # companies remain.
            @round.goto_entity!(@auction_triggerer)
            entities.each(&:unpass!)
            next_entity!
            @auction_triggerer = current_entity
            auction_entity(@companies.first) unless @companies.empty?
          end

          def assign_company(company, player)
            company.value = 0
            super
          end
        end
      end
    end
  end
end
