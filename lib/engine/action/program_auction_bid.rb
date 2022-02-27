# frozen_string_literal: true

require_relative 'program_enable'

module Engine
  module Action
    class ProgramAuctionBid < ProgramEnable
      attr_reader :bid_target, :enable_maximum_bid, :maximum_bid, :enable_buy_price, :buy_price, :auto_pass_after

      def initialize(entity, bid_target:, maximum_bid:, buy_price:, enable_maximum_bid: false,
                     enable_buy_price: false, auto_pass_after: false)
        super(entity)
        @bid_target = bid_target
        @enable_maximum_bid = enable_maximum_bid
        @maximum_bid = maximum_bid
        @enable_buy_price = enable_buy_price
        @buy_price = buy_price
        @auto_pass_after = auto_pass_after
      end

      def self.h_to_args(h, game)
        {
          bid_target: game.corporation_by_id(h['bid_target']) ||
                      game.company_by_id(h['bid_target']) ||
                      game.minor_by_id(h['bid_target']),
          enable_maximum_bid: h['enable_maximum_bid'],
          maximum_bid: h['maximum_bid'],
          enable_buy_price: h['enable_buy_price'],
          buy_price: h['buy_price'],
          auto_pass_after: h['auto_pass_after'],
        }
      end

      def args_to_h
        {
          'bid_target' => @bid_target.id,
          'enable_maximum_bid' => @enable_maximum_bid,
          'maximum_bid' => @maximum_bid,
          'enable_buy_price' => @enable_buy_price,
          'buy_price' => @buy_price,
          'auto_pass_after' => @auto_pass_after,
        }
      end

      def to_s
        buy = @enable_buy_price ? "Buy if price at #{@buy_price}. " : ''
        bid = @enable_maximum_bid ? "Bid on #{@bid_target.name} up to #{@maximum_bid}. " : ''
        suffix = @auto_pass_after ? 'Otherwise auto pass.' : ''

        "#{buy}#{bid}#{suffix}"
      end

      def disable?(game)
        !game.round.auction?
      end
    end
  end
end
