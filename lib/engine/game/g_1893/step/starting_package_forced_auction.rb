# frozen_string_literal: true

require_relative '../../../step/base'
require_relative '../../../step/passable_auction'
require_relative 'buy_minor'

module Engine
  module Game
    module G1893
      module Step
        class StartingPackageForcedAuction < Engine::Step::Base
          attr_reader :auctioning

          include Engine::Step::PassableAuction
          include BuyMinor

          ACTIONS = %w[bid pass].freeze

          def description
            'Drafting Auction for Remaining Starting Package Certificates'
          end

          def help
            return 'Select a company to auction' unless @auctioning

            text = "Buy #{@auctioning.name} for #{format(min_bid(@auctioning))} or Pass. "\
                   "If everyone passes, the price is lowered by #{format(10)} "\
                   'and a new buy/pass opportunity is presented. This continues until someone buys it or until '\
                   "the price has been lowered to #{format(min_purchase(@auctioning))} (50%). "\
                   "If noone buys it #{@auction_triggerer.name} is forced to buy it. "
            if @game.minor_proxy?(@auctioning) && min_purchase(@auctioning) < 100
              text += "Note! If purchase price is below #{format(100)}, bank will add so that the corresponding "\
                      "minor receives a treasury of #{format(100)}."
            end
            text
          end

          def actions(entity)
            return [] if available.empty?
            return [] unless entity == current_entity

            return %w[bid] unless @auctioning
            return [] if min_bid(@auctioning) > entity.cash

            ACTIONS
          end

          def setup
            @reduction_step = 10
            @auction_triggerer = nil
            @current_reduction = 0

            setup_auction
          end

          def available
            @auctioning ? [@auctioning] : @game.draftables
          end

          def process_pass(action)
            return unless @auctioning

            target = @auctioning
            entity = action.entity

            pass_auction(entity)
            @auctioning = target

            return if all_passed?(target)

            next_entity! if @auctioning
          end

          def all_passed?(target)
            return true unless target

            if entities.all?(&:passed?)
              if min_purchase(target) >= min_bid(target)
                force_purchase(@auction_triggerer, target)
              else
                all_passed!(target)
              end
              true
            else
              false
            end
          end

          def pass_auction(entity)
            entity.pass!

            super
          end

          def next_entity!
            @round.next_entity_index!
            entity = entities[entity_index]
            return unless entity
            return if all_passed?(@auctioning) || !(entity.passed? || actions(entity).empty?)

            entity.pass!
            @log << "#{entity.name} is forced to pass on #{@auctioning.name} as price exceed cash"
            next_entity!
          end

          def process_bid(action)
            return purchase(action) if @auctioning

            selection_bid(action)
            next_entity!
          end

          def min_bid(entity)
            entity.min_bid
          end

          def min_increment
            0
          end

          def min_purchase(entity)
            entity.value / 2
          end

          def may_purchase?(entity)
            return false unless !!@auctioning

            @game.buyable_companies.include?(entity)
          end

          def may_choose?(_entity)
            !@auctioning
          end

          def max_bid(_player, object)
            min_bid(object)
          end

          def max_place_bid(_entity, _company)
            0
          end

          def selection_bid(bid)
            @auction_triggerer = bid.entity
            target = @game.to_company(bid_target(bid))

            @game.log << "#{@auction_triggerer.name} selects #{target.name} for auction"
            auction_entity(target)
          end

          protected

          def reduce_price(target)
            @current_reduction += @reduction_step
            target.discount += @reduction_step if target.company?
            new_price = min_bid(target)
            @game.log << "Price of #{target.name} is now lowered to #{format(new_price)}"
          end

          def force_purchase(bidder, target)
            price = min_bid(target)
            info = forced_purchaser(target, bidder, price, bidder)
            draft_object(target, info[:buyer], info[:price], forced: true)

            reset_auction(info[:buyer], target)
          end

          # In case the one starting the auction is forced to buy (all passes until price reaches 50%) then select
          # the first player in player order that can afford to buy it. Now there is a theoretical possibility that
          # no-one can afford to buy it... The rules does not cover this but I decided to implement that the auctioner
          # gets to buy the target for whatever cash that player holds. If it ever happens - good for that player...
          def forced_purchaser(target, candidate, price, first_candidate)
            return { buyer: candidate,  price: price } unless price > candidate.cash

            @game.log << "#{candidate.name} would be forced to buy #{target.name} but cannot afford "\
                         "#{@game.format_currency(price)}"
            entity_index = entities.find_index(candidate)
            entity_index = (entity_index + 1) % entities.size
            next_candidate = entities[entity_index]
            if next_candidate == first_candidate
              @game.log << "As noone can afford #{candidate.name} for #{@game.format_currency(price)}, "\
                           "price is reduced to whatever #{first_candidate.name} has in cash"
              { buyer: first_candidate, price: first_candidate.cash }
            else
              return { buyer: next_candidate, price: price } unless price > next_candidate.cash

              forced_purchaser(target, next_candidate, price, first_candidate)
            end
          end

          def purchase(bid)
            target = @game.to_company(bid_target(bid))
            bidder = bid.entity
            price = bid.price

            raise GameError, "#{target.name} cannot be purchased for #{format(price)}." unless may_purchase?(target)

            draft_object(target, bidder, price)

            reset_auction(bidder, target)
          end

          def purchase_company(company, buyer)
            buyer.spend(company.min_bid, @game.bank)
          end

          def all_passed!(target)
            # Need to move entity round once more to be back to the priority deal player
            reduce_price(target)
            entities.each(&:unpass!)
            next_entity!
          end

          def reset_auction(winner, target)
            @bids.clear
            @active_bidders.clear
            @auctioning = nil
            post_win_bid(winner, target)

            entities.each(&:unpass!)
            @round.goto_entity!(@auction_triggerer)
            @auction_triggerer = nil
            @current_reduction = 0
            next_entity!
          end

          private

          def format(value)
            @game.format_currency(value)
          end
        end
      end
    end
  end
end
