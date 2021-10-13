# frozen_string_literal: true

require_relative 'base'

module Engine
  module Action
    class BuyCorporation < Base
      attr_reader :entity, :corporation, :minor, :price

      def initialize(entity, price:, corporation: nil, minor: nil)
        super(entity)
        @corporation = corporation
        @minor = minor
        @price = price
      end

      def self.h_to_args(h, game)
        {
          corporation: game.corporation_by_id(h['corporation']),
          minor: game.minor_by_id(h['minor']),
          price: h['price'],
        }
      end

      def args_to_h
        {
          'corporation' => @corporation&.id,
          'minor' => @minor&.id,
          'price' => @price,
        }
      end
    end
  end
end
