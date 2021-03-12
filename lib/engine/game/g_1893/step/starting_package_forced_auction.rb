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

            "Buy (if enough cash) or Pass. If everyone passes, the price is lowered by #{@game.format_currency(10)} "\
              'and a new buy/pass opportunity is presented. This continues until someone buys it or when price go '\
              'below 50% of the value in which case the player that selected the company is force to buy it. '\
              'Then next player in SR order gets to select a new company to be auctioned, and so on until all ' \
              'companies are sold. Then the game continues with SR2. Note! Minors bought in this way will get the '\
              "purchase price as treasury, or #{@game.format_currency(100)}, whichever is highest."
          end

          def actions(entity)
            return [] if available.empty?
            return [] unless entity == current_entity

            return %w[bid] unless @auctioning

            ACTIONS
          end

          def setup
            @reduction_step = 10
            @auction_triggerer = nil

            setup_auction
          end

          def available
            @auctioning ? [@auctioning] : @game.buyable_companies
          end

          def process_pass(action)
            return unless @auctioning

            target = @auctioning
            entity = action.entity

            pass_auction(entity)
            @auctioning = target

            if entities.all?(&:passed?)
              if (target.discount + @reduction_step) > target.value / 2
                force_purchase(@auction_triggerer, target)
              else
                all_passed!(target)
              end
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
            return purchase(action) if @auctioning

            selection_bid(action)
            next_entity!
          end

          def min_bid(company)
            company&.min_bid
          end

          def may_purchase?(_entity)
            !!@auctioning
          end

          def may_choose?(_entity)
            !@auctioning
          end

          def max_bid(entity, target)
            may_purchase?(target) ? target.min_bid : entity.cash
          end

          def selection_bid(bid)
            @auction_triggerer = bid.entity
            target = bid_target(bid)

            @game.log << "#{@auction_triggerer.name} selects #{target.name} for auction"
            auction_entity(target)
          end

          protected

          def reduce_price(target)
            target.discount += @reduction_step

            @game.log << "Price of #{target.name} is now lowered to #{@game.format_currency(target.min_bid)}"
          end

          def force_purchase(bidder, target)
            # TODO: Handle the case when bidder cannot afford this

            @log << "#{bidder.name} is forced to buy #{target.name}"

            purchase_company(target, bidder, target.min_bid)

            treasury = target.min_bid < 100 ? 100 : target.min_bid
            handle_connected_minor(target, bidder, treasury)

            reset_auction(bidder, target)
          end

          def purchase(bid)
            target = bid_target(bid)
            bidder = bid.entity
            price = bid.price

            unless may_purchase?(target)
              raise GameError, "#{target.name} cannot be purchased for #{@game.format_currency(price)}."
            end

            purchase_company(target, bidder, price)

            treasury = price < 100 ? 100 : price
            handle_connected_minor(target, bidder, treasury)

            reset_auction(bidder, target)
          end

          def purchase_company(company, buyer)
            @game.bank.companies&.delete(company)
            company.owner = buyer

            buyer.companies << company
            buyer.spend(company.min_bid, @game.bank)
            @log << "#{buyer.name} buy #{company.name} for #{@game.format_currency(company.min_bid)}"
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
