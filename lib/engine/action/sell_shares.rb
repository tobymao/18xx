# frozen_string_literal: true

require_relative 'base'
require_relative '../share_bundle'

module Engine
  module Action
    class SellShares < Base
      attr_reader :entity, :bundle

      def initialize(entity, shares, share_price = nil, percent = nil)
        @entity = entity
        @bundle = ShareBundle.new(shares, percent)
        @bundle.share_price = share_price
      end

      def self.h_to_args(h, game)
        [
          h['shares'].map { |id| game.share_by_id(id) },
          h['share_price'],
          h['percent'],
        ]
      end

      def args_to_h
        {
          'shares' => @bundle.shares.map(&:id),
          'percent' => @bundle.percent,
          'share_price' => @bundle.share_price,
        }
      end
    end
  end
end
