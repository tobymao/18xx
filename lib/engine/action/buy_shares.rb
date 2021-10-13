# frozen_string_literal: true

require_relative 'base'

module Engine
  module Action
    class BuyShares < Base
      attr_reader :entity, :bundle, :swap

      def initialize(entity, shares:, share_price: nil, percent: nil, swap: nil)
        super(entity)
        @bundle = ShareBundle.new(Array(shares), percent)
        @bundle.share_price = share_price
        @swap = swap
      end

      def self.h_to_args(h, game)
        {
          shares: h['shares'].map { |id| game.share_by_id(id) },
          share_price: h['share_price'],
          percent: h['percent'],
          swap: game.share_by_id(h['swap']),
        }
      end

      def args_to_h
        {
          'shares' => @bundle.shares.map(&:id),
          'percent' => @bundle.percent,
          'share_price' => @bundle.share_price,
          'swap' => @swap&.id,
        }
      end
    end
  end
end
