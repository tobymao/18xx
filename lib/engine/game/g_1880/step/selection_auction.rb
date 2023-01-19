# frozen_string_literal: true

require_relative '../../../step/base'
require_relative '../../../step/passable_auction'

module Engine
  module Game
    module G1880
      module Step
        class SelectionAuction < Engine::Step::SelectionAuction
          def setup
            setup_auction
            @companies = @game.companies.sort_by(&:sym)
            @cheapest = @companies.first
            auction_entity(@cheapest)
            @auction_triggerer = current_entity
          end

          def all_passed!
            # Everyone has passed so we need to run a fake OR.
            if @companies.include?(@game.p1)
              # No one has bought P0 or P1 so we reduce the value of the cheapest company.
              first = @companies.first
              value = first.min_bid
              first.discount += 5
              new_value = first.min_bid
              @log << "#{first.name} minimum bid decreases from "\
                      "#{@game.format_currency(value)} to #{@game.format_currency(new_value)}"
              auction_entity(first)
              if new_value <= 0
                # It's now free so the next player is forced to take it.
                @round.next_entity_index!
                forced_win(current_entity, first)
              end
            else
              @game.payout_companies
              @game.or_set_finished
              auction_entity(@companies.first)
            end

            entities.each(&:unpass!)
          end

          def post_win_bid(_winner, _company)
            @round.goto_entity!(@auction_triggerer)
            entities.each(&:unpass!)
            next_entity!
            @auction_triggerer = current_entity
            auction_entity(@companies.first) unless companies.empty?
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
