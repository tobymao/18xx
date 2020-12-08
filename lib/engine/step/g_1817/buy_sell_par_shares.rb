# frozen_string_literal: true

require_relative '../buy_sell_par_shares'
require_relative '../../action/take_loan'
require_relative '../passable_auction'
require_relative 'share_buying_with_shorts'

module Engine
  module Step
    module G1817
      class BuySellParShares < BuySellParShares
        include PassableAuction
        include ShareBuyingWithShorts
        TOKEN_COST = 50
        MIN_BID = 100
        MAX_BID = 400

        def actions(entity)
          return corporate_actions(entity) if !entity.player? && entity.owned_by?(current_entity)

          return [] unless entity.player?

          if @corporate_action
            return [] unless entity.owner == current_entity
            return ['pass'] if any_corporate_actions?(entity)

            return []
          end

          if @winning_bid
            return %w[choose] unless @corporation_size

            if available_subsidiaries(entity).any?
              actions = %w[assign]
              actions << 'pass' unless entity.cash.negative?
              return actions
            end
          end

          return [] unless entity == current_entity
          return %w[bid pass] if @auctioning

          actions = super
          unless bought?
            actions << 'short' if can_short_any?(entity)
            actions << 'bid' if max_bid(entity) >= MIN_BID
          end
          actions << 'pass' if (actions.any? || any_corporate_actions?(entity)) && !actions.include?('pass')
          actions
        end

        def can_sell_order?
          !bought? && !shorted?
        end

        def shorted?
          @current_actions.any? { |x| x.class == Action::Short }
        end

        def redeemable_shares(entity)
          return [] if @corporate_action && entity != @corporate_action.entity

          # Done via Buy Shares
          @game.redeemable_shares(entity)
        end

        def can_buy?(entity, bundle)
          return unless bundle
          return unless bundle.buyable

          if entity.corporation?
            entity.cash >= bundle.price && redeemable_shares(entity).include?(bundle)
          else
            super
          end
        end

        def corporate_actions(entity)
          return [] if @winning_bid
          return [] if @corporation_action && @corporation_action.entity != entity

          actions = []
          if @current_actions.none?
            actions << 'take_loan' if @game.can_take_loan?(entity) && !@corporate_action.is_a?(Action::BuyShares)
            actions << 'buy_shares' if @game.redeemable_shares(entity).any?
          end
          actions << 'buy_tokens' if can_buy_tokens?(entity)
          actions
        end

        def any_corporate_actions?(entity)
          @game.corporations.any? { |corp| corp.owner == entity && corporate_actions(corp).any? }
        end

        def can_buy_tokens?(entity)
          entity.corporation? && !entity.operated? && @game.tokens_needed(entity).positive?
        end

        def active_entities
          return [@winning_bid.entity] if @winning_bid
          return super unless @auctioning

          [@active_bidders[(@active_bidders.index(highest_bid(@auctioning).entity) + 1) % @active_bidders.size]]
        end

        def auctioning_corporation
          return @winning_bid.corporation if @winning_bid

          @auctioning
        end

        def can_sell?(entity, bundle)
          super && !(bundle.corporation.share_price.acquisition? || bundle.corporation.share_price.liquidation?)
        end

        def can_short_any?(entity)
          @game.corporations.any? { |c| can_short?(entity, c) }
        end

        def can_short?(entity, corporation)
          # check total shorts
          corporation.total_shares > 2 &&
            @game.shorts(corporation).length < corporation.total_shares &&
            corporation.operated? &&
            entity.num_shares_of(corporation) <= 0 &&
            !(corporation.share_price.acquisition? || corporation.share_price.liquidation?) &&
            !@round.players_sold[entity].values.include?(:short) &&
            @game.phase.name != '8'
        end

        def choice_name
          'Number of Shares'
        end

        def choices
          @game.phase.corporation_sizes
        end

        def description
          return 'Choose Subsidiaries' if available_subsidiaries(current_entity).any?

          super
        end

        def pass_description
          return 'Pass (Subsidiaries)' if available_subsidiaries(current_entity).any?

          if @auctioning
            'Pass (Bid)'
          elsif @game.corporations.any? { |corp| corp.owner == current_entity && @round.tokens_needed?(corp) }
            'Pass (May liquidate corporation)'
          else
            super
          end
        end

        def log_pass(entity)
          return if @auctioning
          return if available_subsidiaries(entity).any?

          if @corporate_action
            @log << "#{entity.name} finishes acting for #{@corporate_action.entity.name}"
          else
            super
          end
        end

        def pass!
          return par_corporation if @winning_bid

          unless @auctioning
            @current_actions << @corporate_action
            return super
          end

          pass_auction(current_entity)
          resolve_bids
        end

        def process_short(action)
          entity = action.entity
          corporation = action.corporation
          @game.game_error("Cannot short #{corporation.name}") unless can_short?(entity, corporation)

          @round.players_sold[entity][corporation] = :short
          @game.short(entity, corporation)

          @round.last_to_act = entity
          @current_actions << action
        end

        def process_bid(action)
          if auctioning
            add_bid(action)
          else
            selection_bid(action)
          end
        end

        def available_company_options(entity)
          values = entity.companies.map(&:value)
          (0..values.size).flat_map { |size| values.combination(size).to_a }
        end

        def add_bid(action)
          entity = action.entity
          corporation = action.corporation
          price = action.price

          options = available_company_options(entity).map(&:sum)
          if options.none? { |option| price >= option && price <= option + entity.cash }
            valid_options = options
            .select { |o| o + entity.cash >= min_bid(corporation) }
            .map { |o| @game.format_currency(o) }
            .join(', ')
            @game.game_error("Invalid bid, bids using privates include #{valid_options}"\
            " and can be supplemented with cash between $0 and #{@game.format_currency(entity.cash)}")
          end

          if @auctioning
            @log << "#{entity.name} bids #{@game.format_currency(price)} for #{corporation.name}"
          else
            @log << "#{entity.name} auctions #{corporation.name} for #{@game.format_currency(price)}"
            @round.last_to_act = action.entity
            @current_actions.clear
            @game.place_home_token(action.corporation)
          end
          super(action)

          resolve_bids
        end

        def process_buy_shares(action)
          entity = action.entity
          bundle = action.bundle
          corporation = bundle.corporation

          if entity.player?
            unshort = entity.percent_of(corporation).negative?

            super

            @game.unshort(entity, bundle.shares[0]) if unshort
          else
            buy_shares(entity, bundle)
            @round.last_to_act = action.entity.player
            @corporate_action = action
          end
        end

        def process_buy_tokens(action)
          # Buying tokens is not an 'action' and so can be done with player actions
          entity = action.entity
          @game.game_error('Cannot buy tokens') unless can_buy_tokens?(entity)
          tokens = @game.tokens_needed(entity)
          token_cost = tokens * TOKEN_COST
          entity.spend(token_cost, @game.bank)
          @log << "#{entity.name} buys #{tokens} tokens for #{@game.format_currency(token_cost)}"
          tokens.times.each do |_i|
            entity.tokens << Engine::Token.new(entity)
          end
        end

        def process_choose(action)
          size = action.choice
          entity = action.entity
          @game.game_error('Corporation size is invalid') unless choices.include?(size)
          size_corporation(size)
          par_corporation if available_subsidiaries(entity).empty?
        end

        def size_corporation(size)
          @corporation_size = size
          @game.size_corporation(@winning_bid.corporation, @corporation_size) unless @corporation_size == 2
        end

        def process_assign(action)
          entity = action.entity
          company = action.target
          corporation = @winning_bid.corporation
          @game.game_error('Cannot use company in formation') unless available_subsidiaries(entity).include?(company)

          company.owner = corporation
          entity.companies.delete(company)
          corporation.companies << company

          # Pay the player for the company
          corporation.spend(company.value, entity)

          @log << "#{company.name} used for forming #{corporation.name} "\
            "contributing #{@game.format_currency(company.value)} value"

          company.abilities(:additional_token) do |ability|
            corporation.tokens << Engine::Token.new(corporation)
            ability.use!
          end

          par_corporation if available_subsidiaries(entity).empty?
        end

        def process_take_loan(action)
          if @corporate_action && action.entity != @corporate_action.entity
            @game.game_error('Cannot act as multiple corporations')
          end
          @corporate_action = action
          @round.last_to_act = action.entity.player
          @game.take_loan(action.entity, action.loan)
        end

        def par_corporation
          return unless @corporation_size

          corporation = @winning_bid.corporation

          @log << "#{corporation.name} starts with #{@game.format_currency(corporation.cash)} and #{@corporation_size}"\
          ' shares'

          tokens = @game.tokens_needed(corporation)
          if tokens.positive?
            token_cost = tokens * TOKEN_COST
            @log << "#{corporation.name} must buy #{tokens} tokens for #{@game.format_currency(token_cost)}"\
            ' before end of stock round'
          end

          @auctioning = nil
          @winning_bid = nil
          pass!
        end

        def win_bid(winner, _company)
          @winning_bid = winner
          entity = @winning_bid.entity
          corporation = @winning_bid.corporation
          price = @winning_bid.price

          @log << "#{entity.name} wins bid on #{corporation.name} for #{@game.format_currency(price)}"

          par_price = price / 2

          share_price = @game.find_share_price(par_price)

          # Temporarily give the entity cash to buy the corporation PAR shares
          @game.bank.spend(share_price.price * 2, entity)

          action = Action::Par.new(entity, corporation: corporation, share_price: share_price)
          process_par(action)

          # Clear the corporation of 'share' cash
          corporation.spend(corporation.cash, @game.bank)

          # Player spends cash to start corporation, even if it forces them negative
          # which they'll need to sort by adding companeis.
          entity.spend(price, corporation, check_cash: false)

          @corporation_size = nil
          size_corporation(@game.phase.corporation_sizes.first) if @game.phase.corporation_sizes.one?

          par_corporation if available_subsidiaries(winner.entity).none?
        end

        def available_subsidiaries(entity)
          entity ||= current_entity
          return [] if !@winning_bid || @winning_bid.entity != entity

          max_total = @winning_bid.corporation.cash
          min_total = entity.cash.negative? ? entity.cash.abs : 0

          # Filter potential values to those that are valid options
          options = available_company_options(entity).select do |option|
            total = option.sum
            total >= min_total && total <= max_total
          end.flatten

          entity.companies.select do |company|
            options.include?(company.value)
          end
        end

        def committed_cash
          0
        end

        def min_bid(corporation)
          return MIN_BID unless @auctioning

          highest_bid(corporation).price + min_increment
        end

        def max_bid(entity, _corporation = nil)
          return 0 if @game.num_certs(entity) >= @game.cert_limit

          [MAX_BID, @game.bidding_power(entity)].min
        end

        def ipo_via_par?(_entity)
          false
        end

        def can_ipo_any?(_entity)
          false
        end

        def ipo_type(_entity)
          :bid
        end

        def setup
          setup_auction
          super
          @corporate_action = nil
        end
      end
    end
  end
end
