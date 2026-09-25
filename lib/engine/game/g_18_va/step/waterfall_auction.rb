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

          # Replays Bid actions (main and auto) logged before `program` was armed. Live
          # @bids can't be used: it only holds each bidder's current bid, so a leader's
          # later re-bid would erase their earlier lead. Forced 0-bids aren't logged and
          # so don't count as defended.
          #
          # @param entity [Player]
          # @param program [Action::ProgramAuctionPass]
          # @return [Array<Company>] companies `entity` led when `program` was armed
          def auction_pass_defending(entity, program)
            leader_by_company = {}
            @game.actions.each do |action|
              break if action >= program

              [action, *action.auto_actions].each do |a|
                leader_by_company[bid_target(a)] = a.entity if a.is_a?(Action::Bid)
              end
            end
            leader_by_company.select { |_company, leader| leader == entity }.keys
          end

          # "Auto-pass unless outbid": keep passing until a company `entity` was
          # defending when they armed is topped by someone else.
          #
          # @param entity [Player]
          # @param program [Action::ProgramAuctionPass]
          # @return [Array<Action::Pass>, Array<Action::ProgramDisable>, nil] nil leaves
          #   the program armed without acting (pass not currently legal)
          def activate_program_auction_pass(entity, program)
            return unless actions(entity).include?('pass')

            lost = auction_pass_defending(entity, program).reject { |company| highest_bid(company)&.entity == entity }
            return [Action::Pass.new(entity)] if lost.empty?

            [Action::ProgramDisable.new(entity, reason: "#{entity.name} was outbid on #{lost.map(&:name).join(', ')}")]
          end

          def resolve_bids_for_company(company)
            accept_bid(@bids[company].max_by(&:price))
            true
          end

          def end_auction!
            resolve_bids
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
