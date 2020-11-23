# frozen_string_literal: true

require_relative '../base'
require_relative '../../token'
require_relative '../passable_auction'
require_relative 'token_merger'

module Engine
  module Step
    module G1817
      class Acquire < Base
        include PassableAuction
        include TokenMerger

        attr_reader :auctioning, :last_president

        def actions(entity)
          return %w[assign pass] if @offer
          return %w[bid pass] if @auctioning
          return %w[take_loan pass] if can_take_loan?(entity)
          return %w[payoff_loan pass] if can_payoff?(entity)

          actions = []
          actions << 'merge' if @winner&.entity == entity

          actions
        end

        def description
          'Acquire Corporations'
        end

        def pass_description
          if @offer
            'Pass (Offer for Sale)'
          elsif @auctioning
            'Pass (Bid)'
          elsif @buyer && can_take_loan?(@buyer)
            'Pass (Take Loan)'
          elsif @buyer
            'Pass (Repay Loan)'
          end
        end

        def can_take_loan?(entity)
          entity == @buyer && @game.can_take_loan?(entity) && !@passed_take_loans
        end

        def can_payoff?(entity)
          entity == @buyer && @unpaid_loans.positive? && @buyer.cash >= @game.loan_value && !@passed_payoff_loans
        end

        def active_entities
          # Double check that a cash crisis hasn't just been resolved, as the corp may now be in liquidation.
          if auctioning_corporation && corporation_entered_acquisition_this_round?(auctioning_corporation)
            @game.log << "#{auctioning_corporation.name} is no longer eligable to be auctioned"
            @round.offering.delete(auctioning_corporation)
            @offer = nil
            setup_auction
          end

          if @offer
            [@offer.owner]
          elsif @auctioning
            winning_bid = highest_bid(@auctioning)
            if winning_bid
              [@active_bidders[(@active_bidders.index(winning_bid.entity) + 1) % @active_bidders.size]]
            else
              # Player to the left of the president of the corporation
              owner =
                if @auctioning.owner == @game.share_pool
                  @game.owner_when_liquidated[@auctioning]
                else
                  @auctioning.owner
                end

              players = @game.players.rotate((@game.players.index(owner) + 1) % @game.players.size)
              [players.find { |p| @active_bidders.include?(p) }]
            end
          elsif @buyer
            [@buyer]
          elsif @winner
            [@winner.entity]
          else
            []
          end
        end

        def process_take_loan(action)
          corporation = action.entity
          @game.take_loan(corporation, action.loan)
          acquire_post_loan unless can_take_loan?(corporation)
        end

        def show_other_players
          true
        end

        def process_payoff_loan(action)
          entity = action.entity
          loan = action.loan
          amount = loan.amount
          @log << "#{entity.name} pays off a loan for #{@game.format_currency(amount)}"
          entity.spend(amount, @game.bank)

          entity.loans.delete(loan)
          @game.loans << loan
          # The unpaid loans don't affect share price unless they're not paid off.
          @unpaid_loans -= 1
          @passed_take_loans = true
          acquire_post_loan unless can_payoff?(entity)
        end

        def process_pass(action)
          if @offer
            @game.log << "#{@offer.owner.name} declines to put #{@offer.name} up for sale"
            @round.offering.delete(@offer)
            @offer = nil
            setup_auction
          elsif @buyer && can_take_loan?(@buyer)
            @passed_take_loans = true
            @game.log << "#{@buyer.name} passes taking additional loans"
            acquire_post_loan
          elsif @buyer
            @passed_payoff_loans = true
            @game.log << "#{@buyer.name} passes paying off additional loans"
            acquire_post_loan
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
              process_bank_liquidate(corporation)
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

        def process_bank_liquidate(acquired_corp)
          tokens = acquired_corp.tokens.map do |token|
            id = token.city&.hex&.id
            token.remove!
            # @todo: does this need to invalid the graph?
            id
          end

          @game.log << "Bank liquidates #{acquired_corp.name} for $0,"\
          " removing tokens (#{tokens.size}: hexes #{tokens.compact})"

          settle_president(acquired_corp)
        end

        def treasury_share_compensation(corp)
          @mode == :offered ? corp.num_shares_of(corp) * corp.share_price.price : 0
        end

        def process_acquire(buyer)
          acquired_corp = @winner.corporation

          if !buyer || !mergeable(acquired_corp).include?(buyer)
            @game.game_error("Choose a corporation to acquire #{acquired_corp.name}")
          end

          if buyer.owner != @winner.entity
            @game.game_error("Target corporation must be owned by #{@winner.entity.name}")
          end

          @buyer = buyer

          receiving = []

          # Step 6, sell treasury shares to the market
          if @mode == :offered
            compensation = treasury_share_compensation(acquired_corp)
            @game.bank.spend(compensation, acquired_corp) if compensation.positive?
          end

          # Step 6a, acquire assets
          if acquired_corp.cash.positive?
            receiving << @game.format_currency(acquired_corp.cash)
            acquired_corp.spend(acquired_corp.cash, buyer)
          end
          @liquidation_cash += @winner.price if acquired_corp.share_price.liquidation?
          @shareholder_cash = @winner.price
          companies = acquired_corp.transfer(:companies, buyer).map(&:name)
          receiving << "companies (#{companies.join(', ')})" if companies.any?

          @unpaid_loans = acquired_corp.transfer(:loans, buyer).size
          receiving << "loans (#{@unpaid_loans})" if @unpaid_loans.positive?
          # share price modification is delayed until after the player has passed paying off loans

          trains = acquired_corp.transfer(:trains, buyer).map(&:name)
          receiving << "trains (#{trains})" if trains.any?

          remove_duplicate_tokens(buyer, acquired_corp)
          if tokens_above_limits?(buyer, acquired_corp)
            @game.log << "#{buyer.name} will be above token limit and must decide which tokens to keep"
            @round.corporations_removing_tokens = [buyer, acquired_corp]
          else
            tokens = move_tokens_to_surviving(buyer, acquired_corp)
            receiving << "and tokens (#{tokens.size}: hexes #{tokens.compact})"
          end
          @game.log << "#{buyer.name} acquires #{acquired_corp.name} "\
            "receiving #{receiving.join(', ')}"

          # Step 7, take mandatory loans and pay for the bid
          # Take mandatory loans automatically, then allow the player to take the optional loans if they can do.
          @game.take_loan(buyer, @game.loans.first) while buyer.cash < @winner.price
          buyer.spend(@winner.price, @game.bank)

          # Step 7a, allow the player to take more loans if they desire.
          @passed_take_loans = false
          @passed_payoff_loans = false
          acquire_post_loan
        end

        def acquire_post_loan
          # Wait until the player passes on taking loans or paying off.
          return if can_take_loan?(@buyer)

          # Automatically pay of loans a player must repay to get under the loan limit
          acquired_corp = @winner.corporation
          while @buyer.loans.size > @game.maximum_loans(@buyer)
            # Note, these don't affect share price as they are the acquired corps loans.
            loan = @buyer.loans.last
            amount = loan.amount
            @log << "#{@buyer.name} pays off #{acquired_corp.name} loan for #{@game.format_currency(amount)}"
            @buyer.spend(amount, @game.bank)

            @buyer.loans.delete(loan)
            @game.loans << loan
            @unpaid_loans -= 1
          end

          # Player now chooses to pay off remaining loans
          if can_payoff?(@buyer)
            @log << "#{acquired_corp.name} has #{@unpaid_loans} outstanding loan, " \
            "if unpaid will reduce #{@buyer.name} share price"
            return
          end

          # Step 7b, unpaid loans affect stock price and may mean a corporation falls into acquisition.
          if @unpaid_loans.positive?
            price = @buyer.share_price.price
            @unpaid_loans.times do
              @game.stock_market.move_left(@buyer)
            end
            @game.log_share_price(@buyer, price)
            if @buyer.share_price.acquisition? && @round.offering.include?(@buyer)
              # Can no longer be offered this round
              @log << "#{@buyer.name} falls into acquisition and will not be offered for sale this round"
              @round.offering.delete(@buyer)
            end
          end

          settle_president(@winner.corporation)
        end

        def settle_president(acquired_corp)
          # Step 8
          if acquired_corp.share_price.liquidation?
            president = acquired_corp.owner

            loan_value = @liquidation_loans.size * @game.loan_value
            debt = [0, loan_value - @liquidation_cash].max
            @game.loans.concat(@liquidation_loans)
            @liquidation_loans = []

            if debt.positive?
              unless president == @game.share_pool
                @game.log << "#{president.name} settles #{acquired_corp.name} debts for #{@game.format_currency(debt)}"
                president.spend(debt, @game.bank, check_cash: false)
              end

              @shareholder_cash = 0
            elsif loan_value.positive?
              unless president == @game.share_pool
                @game.log << "#{@buyer.name} settles #{acquired_corp.name} loans for "\
                "#{@game.format_currency(loan_value)}"
              end
              @shareholder_cash = @liquidation_cash - loan_value
            else
              @shareholder_cash = @liquidation_cash
            end
          end

          settle_shareholders(acquired_corp)
        end

        def settle_shareholders(acquired_corp)
          # Step 9
          if @shareholder_cash.positive?
            per_share = (@shareholder_cash / acquired_corp.total_shares).to_i
            payouts = {}
            @game.players.each do |player|
              amount = player.num_shares_of(acquired_corp) * per_share
              next if amount.zero?

              payouts[player] = amount
              @game.bank.spend(amount, player, check_positive: false)
            end

            if payouts.any?
              receivers = payouts
                            .sort_by { |_r, c| -c }
                            .map { |receiver, cash| "#{@game.format_currency(cash)} to #{receiver.name}" }.join(', ')

              @log << "#{acquired_corp.name} settles with shareholders #{@game.format_currency(@shareholder_cash)} = "\
                              "#{@game.format_currency(per_share)} (#{receivers})"
            end
          end
          finalize_acquisition(acquired_corp)
        end

        def finalize_acquisition(acquired_corp)
          # Step 10
          @round.cash_crisis_player = acquired_corp.owner unless acquired_corp.owner == @game.share_pool
          @game.reset_corporation(acquired_corp)
          @shareholder_cash = 0
          @buyer = nil
          return unless @winner

          # If not aquired by the bank
          @round.offering.delete(acquired_corp)
          @winner = nil
          setup_auction
        end

        def can_acquire?(corporation, buyer)
          buyer.floated? &&
          !buyer.share_price.liquidation? &&
          !buyer.share_price.acquisition? &&
          buyer != corporation
        end

        def mergeable_type(corporation)
          "#{@winner ? '' : 'Potential '}Corporations that can acquire #{corporation.name}"
        end

        def mergeable_by_entity(entity, corporation, bid)
          entity.presidencies.select do |buyer|
            max_bid_for_corporation(buyer, corporation) >= bid &&
            can_acquire?(corporation, buyer)
          end
        end

        def mergeable(corporation)
          return [] if corporation.player?
          return [] if @offer || @buyer
          return mergeable_by_entity(current_entity, corporation, min_bid(corporation)) unless @winner

          mergeable_by_entity(@winner.entity, corporation, @winner.price)
        end

        def starting_bid(corporation)
          if corporation.share_price.liquidation?
            10 # while technically the bank bids 0 this isn't done by a player.
          elsif corporation.share_price.acquisition?
            10
          else
            # Needs rounding to 10
            ((corporation.total_shares * corporation.share_price.price).to_f / 10).round * 10
          end
        end

        def min_bid(corporation)
          if (bid = highest_bid(corporation)&.price)
            bid + 10
          else
            starting_bid(corporation)
          end
        end

        def min_increment
          10
        end

        def max_bid_for_corporation(corporation, acquired_corp)
          # Notionally pay off all the acquired corps loans, and then they can be taken again
          loan_payoff = acquired_corp.loans.size * @game.loan_value

          @game.buying_power(corporation) +
          acquired_corp.cash +
          treasury_share_compensation(acquired_corp) -
          loan_payoff
        end

        def max_bid(player, corporation)
          corps = player.presidencies.select { |c| can_acquire?(corporation, c) }

          bid = corps.map { |c| max_bid_for_corporation(c, corporation) }.max || 0
          if corporation.owner == player
            # If the corporation is owned then the bid can only be increased by 10
            [bid, min_bid(corporation)].min
          else
            bid
          end
        end

        def process_bid(action)
          entity = action.entity
          corporation = action.corporation
          price = action.price

          @game.game_error("Bid #{price} is not a multple of 10") unless (price % 10).zero?
          @log << "#{entity.name} bids #{@game.format_currency(price)} for #{corporation.name}"
          add_bid(action)
          resolve_bids
        end

        def process_assign(action)
          corporation = action.target
          @game.game_error("Can only assign if offering for sale #{corporation.name}") unless @mode == :offered
          @game.game_error("Can only offer up #{@offer.name}") unless corporation == @offer

          @game.log << "#{corporation.name} is offered at auction, buying corporation will receive "\
            "#{@game.format_currency(treasury_share_compensation(corporation))} for treasury shares"
          @offer = nil
          auction_entity(corporation)
        end

        def auctioning_corporation
          @offer || @auctioning || @winner&.corporation
        end

        def setup
          setup_auction
        end

        private

        def corporation_entered_acquisition_this_round?(corporation)
          # Has the corporation entered acquisition and liquidation this round?
          %i[acquisition liquidation].include?(corporation.share_price.type) &&
          corporation.share_price.type != @game.stock_prices_start_merger[corporation].type
        end

        def setup_auction
          super
          if @round.offering.none?
            pass!
            return
          end

          corporation = @round.offering.first

          @liquidation_cash = 0
          @liquidation_loans = []

          if corporation_entered_acquisition_this_round?(corporation)
            type = corporation.share_price.liquidation? ? 'liquidation' : 'acquisition'
            @game.log << "#{corporation.name} moved into #{type} during M&A and so is skipped"

            @round.offering.delete(corporation)
            setup_auction
          elsif corporation.share_price.liquidation?

            @liquidation_cash = corporation.cash
            @liquidation_loans = corporation.loans.dup

            corporation.spend(corporation.cash, @game.bank) if corporation.cash.positive?
            corporation.loans.clear

            @game.log << "#{corporation.name} is being liquidated, bank offers $0, corporation had"\
            " #{@game.format_currency(@liquidation_cash)} and #{@liquidation_loans.size} loans"
            @mode = :liquidate
            auction_entity(corporation)
            :liquidate
          elsif corporation.share_price.acquisition?
            @game.log << "#{corporation.name} offered for acquisition"
            @mode = :acquisition
            auction_entity(corporation)

          else
            # This needs the owner to either offer(assign) or pass up putting the corp for sale.
            @mode = :offered
            # Check to see if any players can actually buy it
            bidders = entities.select do |player|
              max_bid(player, corporation) >= min_bid(corporation)
            end

            if bidders.any?
              @game.log << "#{corporation.name} may be offered for sale for "\
                "#{@game.format_currency(starting_bid(corporation))}"
              @offer = corporation
            else
              @game.log << "#{corporation.name} cannot be bought at "\
                "#{@game.format_currency(starting_bid(corporation))}, skipping"
              @round.offering.delete(corporation)
              setup_auction
            end
          end
        end
      end
    end
  end
end
