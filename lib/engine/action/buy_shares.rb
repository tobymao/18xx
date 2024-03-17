# frozen_string_literal: true

require_relative 'base'

module Engine
  module Action
    class BuyShares < Base
      attr_reader :entity, :bundle, :swap, :purchase_for, :borrow_from, :total_price, :discounter

      def initialize(entity, shares:, share_price: nil, percent: nil, swap: nil, purchase_for: nil,
                     borrow_from: nil, total_price: nil, discounter: nil)
        super(entity)
        @bundle = ShareBundle.new(Array(shares), percent)
        @bundle.share_price = share_price
        @swap = swap
        @purchase_for = purchase_for
        @borrow_from = borrow_from
        @total_price = total_price
        @discounter = discounter
      end

      def self.h_to_args(h, game)
        {
          shares: h['shares'].map { |id| game.share_by_id(id) },
          share_price: h['share_price'],
          percent: h['percent'],
          swap: game.share_by_id(h['swap']),
          purchase_for: game.get(h['purchase_for_type'], h['purchase_for']),
          borrow_from: game.get(h['borrow_from_type'], h['borrow_from']),
          total_price: h['total_price'],
          discounter: game.company_by_id(h['discounter']),
        }
      end

      def args_to_h
        {
          'shares' => @bundle.shares.map(&:id),
          'percent' => @bundle.percent,
          'share_price' => @bundle.share_price,
          'swap' => @swap&.id,
          'purchase_for_type' => type_s(@purchase_for),
          'purchase_for' => @purchase_for&.id,
          'borrow_from_type' => type_s(@borrow_from),
          'borrow_from' => @borrow_from&.id,
          'total_price' => @total_price,
          'discounter' => @discounter&.id,
        }
      end
    end
  end
end
