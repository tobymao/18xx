# frozen_string_literal: true

require_relative 'base'

# this is identical to the DiscardTrain action, but this can occur in a buy_trains step
module Engine
  module Action
    class ScrapTrain < Base
      attr_reader :train

      def initialize(entity, train:)
        super(entity)
        @train = train
      end

      def self.h_to_args(h, game)
        {
          train: game.train_by_id(h['train']),
        }
      end

      def args_to_h
        { 'train' => @train.id }
      end
    end
  end
end
