# frozen_string_literal: true

require_relative '../../../step/waterfall_auction'

module Engine
  module Game
    module G18VA
      module Step
        class ForcedBid
          attr_reader :company, :corporation, :minor, :price, :entity

          def initialize(entity, price:, company: nil)
            @entity = entity
            @company = company
            @price = price
          end
        end

        class WaterfallAuction < Engine::Step::WaterfallAuction
          def may_purchase?(_company)
            false
          end

          def resolve_bids_for_company(company)
            accept_bid(@bids[company].max_by(&:price))
            true
          end

          def end_auction!
            resolve_bids

            @game.log << 'Players are reordered based on remaining cash'

            # players are reordered from most remaining cash to least with prior order as tie breaker
            current_order = @game.players.dup.reverse
            @game.players.sort_by! { |p| [p.cash, current_order.index(p)] }.reverse!
          end

          def min_bid(company)
            return unless company

            high_bid = highest_bid(company)
            return company.value - company.discount unless high_bid

            high_bid.price + min_increment
          end

          def all_passed!
            companies_without_bids = @companies.reject { |c| @bids[c] && !@bids[c].empty? }

            end_auction! if companies_without_bids.empty?

            companies_without_bids.each do |company|
              # each company without a bid gets decreased by 10
              value = company.min_bid
              company.discount += 10
              new_value = company.min_bid
              @game.log << "#{company.name} minimum bid decreases from "\
                "#{@game.format_currency(value)} to #{@game.format_currency(new_value)}"

              next unless new_value <= 0

              # It's now free so the next player is forced to bid on it
              @round.next_entity_index!
              @log << "#{current_entity.name} is forced to bid 0 on #{company.name}"
              @bids[company] = [ForcedBid.new(current_entity, price: 0, company: company)]
            end
            entities.each(&:unpass!)
          end
        end
      end
    end
  end
end
