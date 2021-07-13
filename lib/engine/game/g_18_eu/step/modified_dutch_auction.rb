# frozen_string_literal: true

require_relative '../../../step/base'
require_relative '../../../step/passable_auction'

module Engine
  module Game
    module G18EU
      module Step
        class ModifiedDutchAuction < Engine::Step::Base
          include Engine::Step::PassableAuction
          ACTIONS = %w[bid pass].freeze

          def description
            'Modified Dutch Auction for Minors'
          end

          def actions(entity)
            return [] if available.empty?
            return [] unless entity == current_entity

            return %w[bid] unless @auctioning

            ACTIONS
          end

          def setup
            @current_reduction = 0
            @reduction_step = 10
            @base_starting_bid = 100
            @auction_triggerer = nil

            setup_auction
          end

          def available
            @auctioning ? [@auctioning] : @game.minors.reject(&:owner)
          end

          def active_entities
            return super unless @auctioning

            winning_bid = highest_bid(@auctioning)
            return [@active_bidders[(@active_bidders.index(winning_bid.entity) + 1) % @active_bidders.size]] if winning_bid

            super
          end

          def process_pass(action)
            return unless @auctioning

            entity = action.entity

            pass_auction(entity)

            if entities.all?(&:passed?)
              all_passed!
              force_purchase(@auction_triggerer, @auctioning) if min_bid(@auctioning).zero?
              return
            end

            next_entity! if @auctioning
          end

          def pass_auction(entity)
            entity.pass!

            super
          end

          def next_entity!
            @round.next_entity_index!
            entity = entities[entity_index]
            next_entity! if entity&.passed?
          end

          def process_bid(action)
            action.entity.unpass!
            return add_bid(action) if action.price >= @base_starting_bid
            return purchase(action) if action.price.positive?

            action.entity.pass!
            selection_bid(action)
            next_entity!
          end

          def min_increment
            @game.class::MIN_BID_INCREMENT
          end

          def starting_bid(_entity)
            @base_starting_bid - @current_reduction
          end

          # TODO: Decrease minimum bid if all passed
          def min_bid(entity)
            return unless entity
            return starting_bid(entity) if @bids[entity].empty?

            high_bid = highest_bid(entity)
            (high_bid.price || entity.min_bid) + min_increment
          end

          def may_purchase?(_entity)
            @current_reduction.positive?
          end

          def may_choose?(_entity)
            !@auctioning
          end

          def max_bid(entity, target)
            may_purchase?(target) ? min_bid(target) : entity.cash
          end

          def selection_bid(bid)
            @auction_triggerer = bid.entity
            target = bid_target(bid)

            @game.log << "#{@auction_triggerer.name} selects #{target.name} for auction with no initial bid."
            auction_entity(target)
          end

          def auctioning # rubocop:disable Style/TrivialAccessors
            @auctioning
          end

          protected

          def reduce_price
            @current_reduction += @reduction_step

            @game.log << "#{@auctioning.name} is now offered for #{@game.format_currency(min_bid(@auctioning))}"
          end

          def assign_target(bidder, target)
            target.owner = bidder
            target.float!
          end

          def force_purchase(bidder, target)
            assign_target(bidder, target)

            @log << "#{bidder.name} is forced to take #{target.name} for free"

            reset_auction(bidder, target)
          end

          def purchase(bid)
            target = bid_target(bid)
            bidder = bid.entity
            price = bid.price

            unless may_purchase?(target)
              raise GameError, "#{target.name} cannot be purchased for #{@game.format_currency(price)}."
            end

            assign_target(bidder, target)

            bidder.spend(price, @game.bank) if price.positive?
            @log << "#{bidder.name} purchases #{target.name} for #{@game.format_currency(price)}"

            reset_auction(bidder, target)
          end

          def add_bid(bid)
            target = bid_target(bid)
            @auction_triggerer ||= bid.entity
            auction_entity(target) unless @auctioning

            super

            bidder = bid.entity
            price = bid.price

            @log << "#{bidder.name} bids #{@game.format_currency(price)} for #{target.name}"

            resolve_bids
          end

          def win_bid(winning_bid, _won)
            bidder = winning_bid.entity
            target = bid_target(winning_bid)
            price = winning_bid.price

            assign_target(bidder, target)

            bidder.spend(price, @game.bank) if price.positive?
            @log << "#{bidder.name} wins the auction for #{target.name} "\
                    "with a bid of #{@game.format_currency(price)}"
          end

          def all_passed!
            # Need to move entity round once more to be back to the priority deal player
            reduce_price
            entities.each(&:unpass!)
            next_entity!
          end

          def resolve_bids
            return unless @auctioning

            target = @auctioning

            return unless @active_bidders.one?
            return if @bids[@auctioning].empty?

            winner = @bids[@auctioning].first
            win_bid(winner, target)
            reset_auction(winner, target)
          end

          def reset_auction(winner, target)
            @bids.clear
            @active_bidders.clear
            @auctioning = nil
            @current_reduction = 0
            post_win_bid(winner, target)

            entities.each(&:unpass!)
            @round.goto_entity!(@auction_triggerer)
            @auction_triggerer = nil
            next_entity!
          end
        end
      end
    end
  end
end
