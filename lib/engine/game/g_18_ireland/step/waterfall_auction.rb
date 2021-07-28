# frozen_string_literal: true

require_relative '../../../step/waterfall_auction'

module Engine
  module Game
    module G18Ireland
      module Step
        class WaterfallAuction < Engine::Step::WaterfallAuction
          def all_passed!
            if @bought
              @log << 'All players passed, companies without bids removed'
              @bids.each { |company, players| @companies.delete(company) if players.empty? }
              resolve_bids
            else
              @log << 'No companies bought, auction restarted and bids cleared'
              # No one has bought anything so we reduce the value of the cheapest company.
              value = @cheapest.min_bid
              @cheapest.discount += 5
              new_value = @cheapest.min_bid
              # All bids are cleared
              @bids.clear
              @bidders.clear

              @log << "#{@cheapest.name} minimum bid decreases from "\
                      "#{@game.format_currency(value)} to #{@game.format_currency(new_value)}"

              if new_value <= 0
                # It's now free so the next player is forced to take it.
                @round.next_entity_index!
                buy_company(current_entity, @cheapest, 0)
                resolve_bids
              end
            end

            entities.each(&:unpass!)
          end

          def buy_company(player, company, price)
            @bought = true
            super
          end
        end
      end
    end
  end
end
