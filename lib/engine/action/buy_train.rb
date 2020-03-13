# frozen_string_literal: true

require 'engine/action/base'

module Engine
  module Action
    class BuyTrain < Base
      attr_reader :entity, :train, :price

      def initialize(entity, train, price)
        @entity = entity
        @train = train
        @price = price
      end

      def copy(game)
        self.class.new(
          game.player_by_name(@entity.name),
          game.train_by_id(@train.id),
          @price,
        )
      end
    end
  end
end
