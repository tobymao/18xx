# frozen_string_literal: true

require_relative '../../../step/base'
require_relative '../../../step/passable_auction'

module Engine
  module Game
    module G18Ardennes
      module Step
        class MinorAuction < Engine::Step::Base
          include Engine::Step::PassableAuction
          ACTIONS = %w[bid pass].freeze

          def actions(entity)
            return [] unless entity == current_entity
            return [] if @minors.empty?

            ACTIONS
          end

          def setup
            setup_auction
            @minors = @game.companies + @game.minors
          end

          def description
            return "Minor #{@auctioning.id} auction" if @auctioning

            'Select minor company to auction'
          end

          def show_map
            true
          end

          def available
            @minors
          end

          def ipo_type(_corporation)
            :bid
          end

          def min_bid(minor)
            return 100 unless @auctioning

            highest_bid(minor).price + @game.class::MIN_BID_INCREMENT
          end

          def max_bid(player, _minor)
            player.cash
          end

          def active_entities
            return super unless @auctioning

            winning_bid = highest_bid(@auctioning)
            [@active_bidders[(@active_bidders.index(winning_bid.entity) + 1) % @active_bidders.size]]
          end

          def add_bid(bid)
            super(bid)

            @log << "#{bid.entity.name} bids " \
                    "#{@game.format_currency(bid.price)} " \
                    "for #{bid.corporation.name}"
          end

          def win_bid(winner, minor)
            player = winner.entity
            price = winner.price
            player.spend(price, @game.bank)
            @log << "#{player.name} wins the auction for #{minor.name} " \
                    "with a bid of #{@game.format_currency(price)}"

            purchase_minor(minor, player, price)
          end

          def process_bid(action)
            action.entity.unpass!

            if @auctioning
              add_bid(action)
            else
              selection_bid(action)
              next_entity! if @auctioning
            end
          end

          def process_pass(action)
            entity = action.entity

            if @auctioning
              pass_auction(entity)
              resolve_bids
            else
              # raise GameError, 'Not allowed to pass selecting a minor'
              @log << "#{entity.name} passes bidding"
              entity.pass!
              all_passed! if entities.all?(&:passed?)
            end
            next_entity!
          end

          def next_entity!
            @round.next_entity_index!
            entity = entities[entity_index]
            next_entity! if entity&.passed?
          end

          def purchase_minor(minor, player, price)
            price = 100 if price < 100

            par_price = @game.stock_market.par_prices.find do |pp|
              pp.types.include?(:par_1) && (pp.price * 2 <= price)
            end
            @game.stock_market.set_par(minor, par_price)
            @game.bank.spend(par_price.price * 2, minor)
            @game.share_pool.transfer_shares(minor.shares.first.to_bundle, player)
            @game.after_par(minor)
          end
        end
      end
    end
  end
end
