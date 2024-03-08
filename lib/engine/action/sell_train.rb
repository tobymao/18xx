# frozen_string_literal: true

require_relative 'base'

module Engine
  module Action
    class SellTrain < Base
      attr_reader :train, :price

      def initialize(entity, train:, price:)
        super(entity)
        @train = train
        @price = price
      end

      def self.h_to_args(h, game)
        {
          train: game.train_by_id(h['train']),
          price: h['price'],
        }
      end

      def args_to_h
        {
          'train' => @train.id,
          'price' => @price,
        }
      end
    end
  end
end
