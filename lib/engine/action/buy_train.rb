# frozen_string_literal: true

require_relative 'base'

module Engine
  module Action
    class BuyTrain < Base
      attr_reader :train, :price, :exchange

      def initialize(entity, train, price, exchange = nil)
        @entity = entity
        @train = train
        @price = price
        @exchange = exchange
      end

      def self.h_to_args(h, game)
        [game.train_by_id(h['train']), h['price'], game.train_by_id(h['exchange'])]
      end

      def args_to_h
        h = {
          'train' => @train.id,
          'price' => @price,
        }
        h['exchange'] = @exchange.id if @exchange
        h
      end
    end
  end
end
