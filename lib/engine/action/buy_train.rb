# frozen_string_literal: true

require_relative 'base'

module Engine
  module Action
    class BuyTrain < Base
      attr_reader :train, :price, :exchange, :variant

      def initialize(entity, train:, price:, variant: nil, exchange: nil)
        super(entity)
        @train = train
        @price = price
        @variant = variant
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
          'variant' => @variant,
          'exchange' => @exchange&.id,
        }
      end
    end
  end
end
