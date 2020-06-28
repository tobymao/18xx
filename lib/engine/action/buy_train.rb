# frozen_string_literal: true

require_relative 'base'

module Engine
  module Action
    class BuyTrain < Base
      attr_reader :train, :price, :exchange

      def initialize(entity, train:, price:, variant: nil, exchange: nil)
        @entity = entity
        @train = train
        @price = price
        @train.variant = variant
        @exchange = exchange
      end

      def self.h_to_args(h, game)
        {
          train: game.train_by_id(h['train']),
          price: h['price'],
          variant: h['variant'],
          exchange: game.train_by_id(h['exchange']),
        }
      end

      def args_to_h
        {
          'train' => @train.id,
          'price' => @price,
          'variant' => @train.variants.one? ? nil : @train.name,
          'exchange' => @exchange&.id,
        }
      end
    end
  end
end
