# frozen_string_literal: true

require_relative '../buy_sell_par_shares'
require_relative '../../action/take_loan'
require_relative 'passable_auction'

module Engine
  module Step
    module G1817
      class BuySellParShares < BuySellParShares
        include PassableAuction
        TOKEN_COST = 50

        def actions(entity)
          return corporate_actions(entity) if !entity.player? && entity.owned_by?(current_entity)

          return [] unless entity.player?

          if @corporate_action
            return ['pass'] if any_corporate_actions?(entity)

            return []
          end

          if @winning_bid
            return %w[choose] unless @corporation_size

            if available_subsidiaries(entity).any?
              actions = %w[assign]
              actions << 'pass' if entity.cash >= @winning_bid.price
              return actions
            end
          end

          return %w[bid pass] if @auctioning

          actions = super
          actions |= %w[short pass] if can_short_any?(entity)
          actions |= %w[bid pass] unless bought?
          actions
        end

        def redeemable_shares(entity)
          # Done via Buy Shares
          @game.redeemable_shares(entity)
        end

        def corporate_actions(entity)
          actions = []
          if @current_actions.none?
            actions << 'take_loan' if @game.can_take_loan?(entity) && !@corporate_action.is_a?(Action::BuyShares)
            if @game.redeemable_shares(entity).any? && !@corporate_action.is_a?(Action::TakeLoan)
              actions << 'buy_shares'
            end
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
          super && !bundle.corporation.share_price.acquisition?
        end

        def can_short_any?(entity)
          @game.corporations.any? { |c| can_short?(entity, c) }
        end

        def can_short?(entity, corporation)
          # check total shorts
          corporation.total_shares > 2 &&
            corporation.operated? &&
            entity.num_shares_of(corporation) <= 0 &&
            !corporation.share_price.acquisition? &&
            @game.phase.name != '8'
        end

        def choice_name
          'Number of Shares'
        end

        def choices
          @game.phase.corporation_sizes
        end

        def pass_description
          return 'Pass (Subsidiaries)' if available_subsidiaries.any?
          return super unless @auctioning

          'Pass (Bid)'
        end

        def log_pass(entity)
          return super unless @auctioning
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
          price = corporation.share_price.price
          @log << "#{entity.name} shorts #{corporation.name} and receives #{@game.format_currency(price)}"
        end

        def process_bid(action)
          if auctioning
            add_bid(action)
          else
            selection_bid(action)
          end
        end

        def add_bid(action)
          entity = action.entity
          corporation = action.corporation
          price = action.price

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
          if action.entity.player?
            super
          else
            buy_shares(action.entity, action.bundle)
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
          @corporation_size = size
          par_corporation if available_subsidiaries(entity).empty?
        end

        def process_assign(action)
          entity = action.entity
          company = action.target
          corporation = @winning_bid.corporation
          @game.game_error('Cannot use company in formation') unless available_subsidiaries(entity).include?(company)
          @subsidiaries << company
          @log << "#{company.name} used for forming #{corporation.name} "\
            "contributing #{@game.format_currency(company.value)} value"
          par_corporation if available_subsidiaries(entity).empty?
        end

        def process_take_loan(action)
          @corporate_action = action
          @game.take_loan(action.entity, action.loan)
        end

        def par_corporation
          entity = @winning_bid.entity
          corporation = @winning_bid.corporation
          price = @winning_bid.price
          par_price = price / 2

          share_price = @game.find_share_price(par_price)
          action = Action::Par.new(@winning_bid.entity, corporation: @winning_bid.corporation, share_price: share_price)
          process_par(action)
          corporation.spend(corporation.cash, entity)

          @subsidiaries.each do |company|
            company.owner = corporation
            entity.companies.delete(company)
            corporation.companies << company
            price -= company.value
            company.abilities(:additional_token) do |ability|
              corporation.tokens << Engine::Token.new(corporation)
              ability.use!
            end
          end

          entity.spend(price, corporation)
          @game.size_corporation(corporation, @corporation_size) unless @corporation_size == 2
          @log << "#{corporation.name} starts with #{@game.format_currency(price)} and #{@corporation_size} shares"

          tokens = @game.tokens_needed(corporation)
          if tokens.positive?
            token_cost = tokens * TOKEN_COST
            @log << "#{corporation.name} must buy #{tokens} tokens for #{@game.format_currency(token_cost)}"\
            ' before end of stock round'
          end

          @auctioning = nil
          @winning_bid = nil
          @subsidiaries = []
          pass!
        end

        def win_bid(winner, _company)
          @winning_bid = winner
          @corporation_size = nil
          @corporation_size = @game.phase.corporation_sizes.first if @game.phase.corporation_sizes.one?

          par_corporation if @corporation_size && available_subsidiaries(winner.entity).none?
        end

        def available_subsidiaries(entity)
          entity ||= current_entity
          return [] if !@winning_bid || @winning_bid.entity != entity

          total = @subsidiaries.sum(&:value)

          (entity.companies - @subsidiaries).select do |company|
            @winning_bid.price > company.value + total
          end
        end

        def committed_cash
          0
        end

        def min_bid(corporation)
          return 100 unless @auctioning

          highest_bid(corporation).price + min_increment
        end

        def max_bid(player, _corporation)
          [400, bidding_power(player)].min
        end

        def bidding_power(player)
          player.cash + player.companies.sum(&:value)
        end

        def can_ipo_any?(_entity)
          false
        end

        def setup
          setup_auction
          super
          @subsidiaries = []
          @corporate_action = nil
        end
      end
    end
  end
end
