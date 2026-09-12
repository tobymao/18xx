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
          def setup
            super
            @auction_pass_defending = {}
          end

          def may_purchase?(_company)
            false
          end

          # Companies the entity is currently the high bidder on.
          def auction_pass_defending(entity)
            bids_for_player(entity).map { |bid| bid_target(bid) }
          end

          # Snapshot what the player was winning when they armed "Auto-pass unless outbid"
          # (Action::ProgramAuctionPass), so activate_program_auction_pass can tell when
          # they've actually been outbid on something they cared about.
          def player_enabled_program(entity)
            return unless @game.programmed_actions[entity].last.is_a?(Action::ProgramAuctionPass)

            @auction_pass_defending[entity] = auction_pass_defending(entity)
          end

          # Drives "Auto-pass unless outbid": pass every time the turn cycles back, and hand
          # control back once one of the bids the player was defending has been topped. If
          # player_enabled_program never snapshotted this entity, take the snapshot now instead
          # of assuming "defending nothing" — otherwise a missed hook means never disabling.
          def activate_program_auction_pass(entity, _program)
            return unless actions(entity).include?('pass')

            defending = @auction_pass_defending.key?(entity) ? @auction_pass_defending[entity] : auction_pass_defending(entity)
            currently_defending = auction_pass_defending(entity)
            @auction_pass_defending[entity] = currently_defending
            lost = defending - currently_defending
            unless lost.empty?
              return [Action::ProgramDisable.new(entity,
                                                 reason: "#{entity.name} was outbid on "\
                                                         "#{lost.map(&:name).join(', ')}")]
            end

            [Action::Pass.new(entity)]
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
