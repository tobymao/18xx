# frozen_string_literal: true

require_relative 'base'

module Engine
  module Action
    class BuyCorporation < Base
      attr_reader :entity, :corporation, :price

      def initialize(entity, corporation:, price:)
        super(entity)
        @corporation = corporation
        @price = price
      end

      def self.h_to_args(h, game)
        {
          corporation: game.corporation_by_id(h['corporation']),
          price: h['price'],
        }
      end

      def args_to_h
        {
          'corporation' => @corporation.id,
          'price' => @price,
        }
      end
    end
  end
end
