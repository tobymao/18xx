# frozen_string_literal: true

require_relative '../../../step/base'
require_relative '../../../step/passable_auction'

module Engine
  module Game
    module G18Ardennes
      module Step
        class MinorAuction < Engine::Step::Base
          include Engine::Step::PassableAuction
          MIN_PRICE = 100

          def actions(entity)
            return [] unless entity == current_entity
            return [] if @minors.empty?
            return %w[bid pass] if @auctioning
            return %w[par] if discount_mode?

            %w[bid]
          end

          def setup
            setup_auction
            @minors = @game.companies +
                      @game.corporations.select { |corp| corp.type == :minor }
          end

          def description
            return "#{minor_name(@auctioning)} auction" if @auctioning

            'Select minor company to auction'
          end

          def show_map
            true
          end

          def available
            @minors
          end

          def may_purchase?(_company)
            # The Guillaume-Luxembourg is auctioned in the initial round, not
            # purchased.
            false
          end

          def ipo_type(_corporation)
            discount_mode? ? :par : :bid
          end

          def bid_target(bid)
            bid.corporation || bid.company
          end

          def minor_name(minor)
            "#{minor.corporation? ? 'Minor ' : ''}#{minor.name}"
          end

          def get_par_prices(_entity, _corporation)
            # This only gets called once everyone has less than 100F, and the
            # remaining minor companies are being purchased.
            [par_price(MIN_PRICE)]
          end

          def min_bid(minor)
            return MIN_PRICE unless @auctioning

            highest_bid(minor).price + @game.class::MIN_BID_INCREMENT
          end

          def max_bid(player, _minor)
            player.cash
          end

          # If everyone has less than 100F then the auction ends and instead
          # the remaining minors are sold off one-by-one.
          def discount_mode?
            @game.players.all? { |player| player.cash < MIN_PRICE }
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
                    "for #{minor_name(bid_target(bid))}"
          end

          def win_bid(bid, minor)
            player = bid.entity
            price = bid.price
            @log << "#{player.name} wins the auction for " \
                    "#{minor_name(bid_target(bid))} " \
                    "with a bid of #{@game.format_currency(price)}"
            purchase_minor(minor, player, price)
          end

          def post_win_bid(_bid, _minor)
            next_entity!
          end

          def next_entity!
            if discount_mode?
              # Go to the player with the most cash. If there is a tie then
              # choose the one who is next in table order.
              @round.goto_entity!(entities.rotate(entity_index + 1).max_by(&:cash))
            else
              # Go to the next player in table order after the player who
              # started the current auction. Skip anyone who does not have
              # enough cash to start another auction.
              @round.next_entity_index!
              entity = entities[entity_index]
              next_entity! if entity.cash < MIN_PRICE
            end
          end

          def process_bid(action)
            action.entity.unpass!

            if @auctioning
              add_bid(action)
            else
              selection_bid(action)
            end
          end

          def process_pass(action)
            entity = action.entity
            pass_auction(entity)
            resolve_bids
          end

          def process_par(action)
            player = action.entity
            minor = action.corporation
            price = player.cash
            @log << "#{player.name} purchases #{minor.name} " \
                    "for #{@game.format_currency(price)}"
            purchase_minor(minor, player, price)
            next_entity!
          end

          def purchase_minor(minor, player, price)
            player.spend(price, @game.bank) if price.positive?

            @minors.delete(minor)
            if minor.corporation?
              share_price = par_price(price)
              @game.stock_market.set_par(minor, share_price)
              @game.bank.spend(share_price.price * 2, minor)
              @game.share_pool.buy_shares(player,
                                          minor.presidents_share.to_bundle,
                                          exchange: :free,
                                          silent: true)
              @game.after_par(minor)

              @round.minor_floated = minor
              @round.num_laid_track = 0
              @round.laid_hexes.clear
            else
              # Guillaume-Luxembourg has been bought
              minor.owner = player
              player.companies << minor
            end
          end

          def par_price(price)
            cert_cost = [price, MIN_PRICE].max
            @game.stock_market.par_prices.find do |pp|
              pp.types.include?(:par_1) && (pp.price * 2 <= cert_cost)
            end
          end
        end
      end
    end
  end
end
