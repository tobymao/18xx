# frozen_string_literal: true

require_relative 'base'

module Engine
  module Action
    class BuyShares < Base
      attr_reader :entity, :bundle

      def initialize(entity, shares, share_price = nil)
        @entity = entity
        @bundle = ShareBundle.new(Array(shares))
        @bundle.share_price = share_price
      end

      def self.h_to_args(h, game)
        [
          h['shares'].map { |id| game.share_by_id(id) },
          h['share_price'],
        ]
      end

      def args_to_h
        {
          'shares' => @bundle.shares.map(&:id),
          'share_price' => @bundle.share_price,
        }
      end
    end
  end
end
