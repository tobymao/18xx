# frozen_string_literal: true

require 'engine/action/base'

module Engine
  module Action
    class BuyTrain < Base
      attr_reader :train, :price

      def initialize(entity, train, price)
        @entity = entity
        @train = train
        @price = price
      end

      def self.h_to_args(h, game)
        [game.train_by_id(h['train']), h['price']]
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
