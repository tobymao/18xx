# frozen_string_literal: true

require_relative 'base'

module Engine
  module Action
    class Par < Base
      attr_reader :corporation, :share_price, :purchase_for, :borrow_from, :slot

      def initialize(entity, corporation:, share_price:, slot: nil, purchase_for: nil, borrow_from: nil)
        super(entity)
        @corporation = corporation
        @share_price = share_price
        @slot = slot
        @purchase_for = purchase_for
        @borrow_from = borrow_from
      end

      def self.h_to_args(h, game)
        {
          corporation: game.corporation_by_id(h['corporation']),
          share_price: game.share_price_by_id(h['share_price']),
          slot: h['slot'],
          purchase_for: game.get(h['purchase_for_type'], h['purchase_for']),
          borrow_from: game.get(h['borrow_from_type'], h['borrow_from']),
        }
      end

      def args_to_h
        {
          'corporation' => @corporation.id,
          'share_price' => @share_price.id,
          'slot' => @slot,
          'purchase_for_type' => type_s(@purchase_for),
          'purchase_for' => @purchase_for&.id,
          'borrow_from_type' => type_s(@borrow_from),
          'borrow_from' => @borrow_from&.id,
        }
      end
    end
  end
end
