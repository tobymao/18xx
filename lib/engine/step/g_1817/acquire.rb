# frozen_string_literal: true

require_relative '../base'
require_relative '../../token'
require_relative 'passable_auction'

module Engine
  module Step
    module G1817
      class Acquire < Base
        include PassableAuction

        attr_reader :auctioning

        def actions(entity)
          return %w[assign pass] if @offer
          return %w[bid pass] if @auctioning

          actions = []
          actions << 'merge' if @winner&.entity == entity

          actions
        end

        def description
          'Acquire Corporations'
        end

        def active_entities
          if @offer
            [@offer.owner]
          elsif @auctioning
            winning_bid = highest_bid(@auctioning)
            if winning_bid
              [@active_bidders[(@active_bidders.index(winning_bid.entity) + 1) % @active_bidders.size]]
            else
              # Player to the left of the president of the corporation
              players = @game.players.rotate((@game.players.index(@auctioning.owner) + 1) % @game.players.size)
              [players.find { |p| @active_bidders.include?(p) }]
            end
          elsif @winner
            [@winner.entity]
          end
        end

        def process_take_loan(action)
          corporation = action.entity
          @game.take_loan(corporation, action.loan)
          purchase_tokens(corporation) unless @game.can_take_loan?(corporation)
        end

        def process_pass(action)
          if @offer
            @game.log << "#{@offer.owner.name} declines to put #{@offer.name} up for sale"
            @round.offering.delete(@offer)
            @offer = nil
            setup_auction
          else
            pass_auction(action.entity)
          end
        end

        def post_win_bid(winner, corporation)
          if winner
            m = mergeable(winner.corporation)
            process_acquire(m.first) if m.one?
          else
            case @mode
            when :acquisition
              @game.log << "All players pass on #{corporation.name}, not acquired"
            when :liquidate
              @game.log << "All players pass on #{corporation.name}, bank acquires for $0"
              # @todo: bank acquires liquidations
            when :offered
              @game.log << "All players pass on #{corporation.name}, not sold"
            end
            @round.offering.delete(corporation)
            setup_auction
          end
        end

        def win_bid(winner, _corporation)
          return unless winner

          @game.log << "#{winner.entity.name} wins the auction of #{winner.corporation.name}"\
                  " for #{@game.format_currency(winner.price)}"
          @winner = winner
        end

        def process_merge(action)
          process_acquire(action.corporation)
        end

        def process_acquire(buyer)
          # @todo: this needs a lot of rework.
          acquired_corp = @winner.corporation

          if !buyer || !mergeable(acquired_corp).include?(buyer)
            @game.game_error("Choose a corporation to acquire #{acquired_corp.name}")
          end

          if buyer.owner != @winner.entity
            @game.game_error("Target corporation must be owned by #{@winner.entity.name}")
          end

          receiving = []

          # @todo: this needs to be able to force loan
          buyer.spend(@winner.price, @game.bank)
          # @todo: slightly different rules for liquidation
          if acquired_corp.cash.positive?
            receiving << @game.format_currency(acquired_corp.cash)
            acquired_corp.spend(acquired_corp.cash, buyer)
          end

          companies = acquired_corp.transfer(:companies, buyer).map(&:name)
          receiving << "companies (#{companies.join(', ')})" if companies.any?

          # @todo: what if loans cannot be held?
          loans = acquired_corp.transfer(:loans, buyer).size
          receiving << "loans (#{loans})" if loans.positive?
          # @todo: loans affect stock price

          trains = acquired_corp.transfer(:trains, buyer).map(&:name)
          receiving << "trains (#{trains})" if trains.any?

          tokens = acquired_corp.tokens.map do |token|
            new_token = Engine::Token.new(buyer)
            buyer.tokens << new_token

            token.swap!(new_token)
            new_token.city&.hex&.id
          end
          receiving << "and tokens (#{tokens.size}: hexes #{tokens.compact})"

          @game.log << "#{buyer.name} acquires #{acquired_corp.name} "\
            "receiving #{receiving.join(', ')}"

          # @todo: liqudation needs the president to pay for outstanding Loans
          # @todo: pay off stock holders

          @game.reset_corporation(acquired_corp)
          @round.offering.delete(acquired_corp)
          @winner = nil
          setup_auction
        end

        def can_acquire?(corporation, buyer)
          buyer.floated? &&
          buyer.share_price.normal_movement? &&
          buyer != corporation
        end

        def mergeable(corporation)
          return [] unless @winner

          @game.corporations.select do |buyer|
            buyer.owner == @winner.entity && buyer.cash >= @winner.price && can_acquire?(corporation, buyer)
          end
        end

        def starting_bid(corporation)
          if corporation.share_price.liquidation?
            0
          elsif corporation.share_price.acquisition?
            10
          else
            corporation.total_shares * corporation.share_price.price
          end
        end

        def min_bid(corporation)
          if (bid = highest_bid(corporation)&.price)
            bid + 10
          else
            starting_bid(corporation)
          end
        end

        def max_bid(player, corporation)
          # @todo: Only 10 more if it's owned by them
          # Otherwise max of corporation treasury
          # @todo: some modes can use the treasury from a corporation
          companies = player.presidencies.select { |c| can_acquire?(corporation, c) }

          companies.map(&:cash).max || 0
        end

        def process_bid(action)
          entity = action.entity
          corporation = action.corporation
          price = action.price

          add_bid(action)
          @log << "#{entity.name} bids #{@game.format_currency(price)} for #{corporation.name}"
          resolve_bids
        end

        def process_assign(action)
          corporation = action.target
          @game.game_error("Can only assign if offering for sale #{corporation.name}") unless @mode == :offered
          @game.game_error("Can only offer up #{@offer.name}") unless corporation == @offer

          @game.log << "#{corporation.name} is offered at auction"
          @offer = nil
          auction_entity(corporation)
        end

        def auctioning_corporation
          @offer || @auctioning || @winner.corporation
        end

        private

        def setup_auction
          super
          if @round.offering.none?
            pass!
            return
          end

          corporation = @round.offering.first

          @mode =
            if corporation.share_price.liquidation?
              @game.log << "#{corporation.name} is being liquidated, bank offers $0"
              auction_entity(corporation)
              :liquidate
            elsif corporation.share_price.acquisition?
              @game.log << "#{corporation.name} offered for acquisition"
              auction_entity(corporation)
              :acquisition
            else
              # This needs the owner to either offer(assign) or pass up putting the corp for sale.

              # Check to see if any players can actually buy it
              bidders = entities.select do |player|
                max_bid(player, corporation) >= min_bid(corporation)
              end

              if bidders.any?
                @game.log << "#{corporation.name} may be offered for sale for "\
                  "#{@game.format_currency(starting_bid(corporation))}"
                @offer = corporation
                :offered
              else
                @game.log << "#{corporation.name} cannot be bought at "\
                  "#{@game.format_currency(starting_bid(corporation))}, skipping"
                @round.offering.delete(corporation)
                setup_auction
                @mode
              end
            end
        end

        def setup
          setup_auction
        end
      end
    end
  end
end
