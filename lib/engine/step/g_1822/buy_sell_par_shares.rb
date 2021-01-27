# frozen_string_literal: true

require_relative '../buy_sell_par_shares'
require_relative 'bidbox_auction'

module Engine
  module Step
    module G1822
      class BuySellParShares < BuySellParShares
        include BidboxAuction

        attr_accessor :bidders, :bid_actions

        def actions(entity)
          actions = super
          actions << 'bidding_tokens'
          actions << 'bid'
          actions
        end

        def description
          'Bid, convert concession or buy/sell shares'
        end

        def log_pass(entity)
          @log << "#{entity.name} passes"
        end

        def pass!
          @round.bidders = @bidders
          @round.bids = @bids
          super
        end

        def process_bid(action)
          action.entity.unpass!
          add_bid(action)
        end

        def setup
          setup_auction
          super

          @bid_actions = 0
          @bidders = (@round.bidders.nil? ? Hash.new { |h, k| h[k] = [] } : @round.bidders)
          @bids = @round.bids unless @round.bids.nil?
        end

        def bidding_tokens(player)
          @game.bidding_token_per_player - (bids_for_player(player)&.size || 0)
        end

        def can_bid?(entity, company)
          return false if highest_player_bid?(entity, company)

          !(find_bid(entity, company).nil? && bidding_tokens(entity).zero?)
        end

        protected

        def add_bid(action)
          super

          company = action.company
          price = action.price
          entity = action.entity

          @bidders[company] |= [entity]

          @current_actions << action
          @log << "#{entity.name} bids #{@game.format_currency(price)} for #{company.name}"
          @round.last_to_act = action.entity
          @bid_actions += 1

          return if @bid_actions < @game.class::BIDDING_TOKENS_PER_ACTION

          log_pass(entity)
          pass!
        end
      end
    end
  end
end
