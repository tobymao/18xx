# frozen_string_literal: true

require_relative 'draft'

module Engine
  module Game
    module G1835
      module Step
        # Vanderpluym-Auktion variant for 1835.
        #
        # Draft ordering is normal (1-2-3-4-1-2-3-4...), but instead of buying
        # an item outright, the current player nominates an available item at a
        # minimum bid and an open ascending auction is held.  Other players, then
        # the nominator, may raise the bid by at least 5M or pass (eliminating
        # themselves from that auction).  When only the highest bidder remains,
        # they win the item and pay the bank.
        #
        # BY floats as soon as its president's share (BYD) is won.
        class DraftVanderpluym < G1835::Step::Draft
          MIN_BID_INCREMENT = 5

          def setup
            super
            reset_auction_state
          end

          # ── Identification ──────────────────────────────────────────────────

          def name
            'Vanderpluym Auction'
          end

          def description
            'Vanderpluym Auction — each item is auctioned with a minimum bid'
          end

          def may_purchase?(_entity)
            false
          end

          def show_min_bid?
            true
          end

          def auctioneer?
            true
          end

          def may_bid?(_entity)
            true
          end

          def max_place_bid(entity, company)
            max_bid(entity, company)
          end

          # ── Auction state accessors ──────────────────────────────────────────

          def auctioning
            @auctioning_entity
          end

          def bids
            {}
          end

          # ── Bid limits ───────────────────────────────────────────────────────

          # Minimum bid to place on an entity.
          # During an active auction on that entity: current high + increment.
          # Otherwise: the variant-specific floor from VANDERPLUYM_MIN_BIDS.
          def min_bid(entity)
            return unless entity

            if @auctioning_entity == entity
              @highest_amount + MIN_BID_INCREMENT
            else
              @game.class::VANDERPLUYM_MIN_BIDS[entity_sym(entity)] || entity.value
            end
          end

          def max_bid(player, _entity)
            player.cash
          end

          # Only the current highest bidder has committed cash.
          def committed_cash(player, _show_hidden = false)
            return 0 if !@auctioning_entity || !@highest_bidder == player

            @highest_amount
          end

          def min_increment
            MIN_BID_INCREMENT
          end

          # ── Entity selection ─────────────────────────────────────────────────

          # During an auction, the active player is the next in the bidder queue.
          # Outside an auction, use normal draft order (round entity_index).
          def current_entity
            @auctioning_entity ? @active_bidders.first : entities[entity_index]
          end

          def active_entities
            entity = current_entity
            entity ? [entity] : []
          end

          # ── Available actions ────────────────────────────────────────────────

          def actions(entity)
            return [] if finished?
            return [] unless entity == current_entity

            if @auctioning_entity
              # During auction: current bidder can raise or fold
              ACTIONS
            else
              # Nomination phase: can bid (nominate) if can afford anything, else pass
              avail = available
              return ACTIONS if avail.any? { |e| entity.cash >= min_bid(e) }

              ['pass']
            end
          end

          def auto_actions(entity)
            return [] unless entity == current_entity

            can_afford = if @auctioning_entity
                           # Auto-pass in auction if player cannot afford the minimum raise
                           entity.cash >= min_bid(@auctioning_entity)
                         else
                           # Auto-pass nomination if player cannot afford any available item
                           available.any? { |e| entity.cash >= min_bid(e) }
                         end
            return [] if can_afford

            [Engine::Action::Pass.new(entity)]
          end

          # ── Action processing ────────────────────────────────────────────────

          def process_bid(action)
            entity = action.company || action.minor || action.corporation
            player = action.entity
            price = action.price

            if @auctioning_entity
              process_raise(player, entity, price)
            else
              process_nominate(player, entity, price)
            end
          end

          def process_pass(action)
            if @auctioning_entity
              process_auction_pass(action.entity)
            else
              # Nomination pass — player opts out of nominating this turn
              action.entity.pass!
              @log << "#{action.entity.name} passes"
              @round.next_entity_index!
              @log << 'All players passed' if entities.all?(&:passed?)
              action_finalized
            end
          end

          private

          # ── Nomination ───────────────────────────────────────────────────────

          def process_nominate(player, entity, price)
            raise GameError, "#{entity.name} is not available" unless available.include?(entity)
            raise GameError, "Bid of #{price} is below minimum #{min_bid(entity)}" if price < min_bid(entity)
            raise GameError, "Bid must be a multiple of #{MIN_BID_INCREMENT}" unless (price % MIN_BID_INCREMENT).zero?
            raise GameError, "#{player.name} cannot afford #{@game.format_currency(price)}" if price > player.cash

            @auctioning_entity = entity
            @highest_bidder = player
            @highest_amount = price

            # Bidder queue: all players starting from the player after the nominator,
            # wrapping around so the nominator is last (they already set the opening bid).
            nominator_idx = entities.index(player)
            @active_bidders = entities.rotate(nominator_idx + 1).dup

            @log << "#{player.name} opens bidding on #{entity.name} at #{@game.format_currency(price)}"

            check_and_resolve_auction
          end

          # ── Raise ────────────────────────────────────────────────────────────

          def process_raise(player, entity, price)
            raise GameError, "#{entity.name} is not being auctioned" unless entity == @auctioning_entity
            raise GameError, "It is not #{player.name}'s turn to bid" unless player == @active_bidders.first
            raise GameError, "Bid must be at least #{@game.format_currency(min_bid(entity))}" if price < min_bid(entity)
            raise GameError, "Bid must be a multiple of #{MIN_BID_INCREMENT}" unless (price % MIN_BID_INCREMENT).zero?
            raise GameError, "#{player.name} cannot afford #{@game.format_currency(price)}" if price > player.cash

            @highest_bidder = player
            @highest_amount = price
            @active_bidders.rotate! # bidder stays in the queue but goes to the back

            @log << "#{player.name} bids #{@game.format_currency(price)} on #{@auctioning_entity.name}"

            check_and_resolve_auction
          end

          # ── Auction pass ─────────────────────────────────────────────────────

          def process_auction_pass(player)
            raise GameError, "It is not #{player.name}'s turn to bid" unless player == @active_bidders.first

            @active_bidders.shift # eliminated from this auction
            @log << "#{player.name} passes on #{@auctioning_entity.name}"

            check_and_resolve_auction
          end

          # ── Resolution ───────────────────────────────────────────────────────

          # Auction resolves when the queue is empty or only the highest bidder remains.
          def should_resolve?
            return false unless @auctioning_entity

            @active_bidders.empty? ||
              (@active_bidders.size == 1 && @active_bidders.first == @highest_bidder)
          end

          def check_and_resolve_auction
            return unless should_resolve?

            resolve_auction
            reset_auction_state

            # After resolution, unpass everyone (new items may now be available)
            # and advance to the next nomination turn.
            entities.each(&:unpass!)
            @round.next_entity_index!
            action_finalized
          end

          # Deliver the auctioned item to the highest bidder and pay the bank.
          def resolve_auction
            entity = @auctioning_entity
            player = @highest_bidder
            price  = @highest_amount

            if entity.company?
              entity.owner = player
              player.companies << entity

              @game.abilities(entity, :shares) do |ability|
                ability.shares.each do |share|
                  corp = share.corporation
                  @game.add_draft_capital(corp, share.num_shares * corp.par_price.price)
                  @game.share_pool.buy_shares(player, share, exchange: :free)
                end
              end

              if entity.sym == 'BYD'
                @log << "#{entity.name} is exchanged for the president's share of Bayrische Eisenbahn and closes"
                entity.close!
                # Vanderpluym: BY floats immediately when president's share is won
                by = @game.corporation_by_id('BY')
                @game.float_corporation(by) unless by.floated?
              end
            elsif entity.minor?
              entity.owner = player
              entity.float!
              # Minor's start capital = its face value, not the winning bid
              @game.bank.spend(entity.value, entity)
              @game.place_home_token(entity)
            elsif entity.corporation?
              share = entity.shares.first
              @game.share_pool.buy_shares(player, share.to_bundle, exchange: :free)
            end

            player.spend(price, @game.bank)

            @log << "#{player.name} wins #{entity.name} for #{@game.format_currency(price)}"

            # Track last buyer for stock-round priority deal
            @round.last_to_act = player
          end

          def reset_auction_state
            @auctioning_entity = nil
            @highest_bidder    = nil
            @highest_amount    = 0
            @active_bidders    = []
          end
        end
      end
    end
  end
end
