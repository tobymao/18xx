# frozen_string_literal: true

require_relative '../../../step/waterfall_auction'

module Engine
  module Game
    module G18GB
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
          def setup
            setup_auction
            @companies = @game.companies.dup
            @required_bids = @game.required_bids_to_pass
            @bidders = Hash.new { |h, k| h[k] = [] }
          end

          def actions(entity)
            return [] if @companies.empty?
            return [] if entity != current_entity

            allowed_to_pass(entity) ? ACTIONS : ['bid']
          end

          def auction_restaged?
            @companies.any? { |company| company.discount.positive? }
          end

          def allowed_to_pass(entity)
            winning_bids = @companies.map { |company| highest_bid(company) }.select { |bid| bid }
            return true if winning_bids.size == @companies.size
            return true if auction_restaged?

            winning_bids.count { |bid| bid.entity == entity } >= @required_bids
          end

          def may_purchase?(_company)
            false
          end

          def min_bid(company)
            return unless company

            high_bid = highest_bid(company)
            return company.value - company.discount unless high_bid

            high_bid.price + min_increment
          end

          def resolve_winning_bids
            @companies.dup.each do |company|
              accept_bid(@bids[company].max_by(&:price)) unless @bids[company].empty?
            end
          end

          def all_passed!
            resolve_winning_bids
            companies_without_bids = @companies.reject { |c| @bids[c] && !@bids[c].empty? }

            companies_without_bids.each do |company|
              # each company without a bid gets decreased by £10
              value = company.min_bid
              company.discount += 10
              new_value = company.min_bid
              @game.log << "#{company.name} minimum bid decreases from "\
                           "#{@game.format_currency(value)} to #{@game.format_currency(new_value)}"

              next unless new_value <= 0

              # item is now free, so next player must bid on it
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
