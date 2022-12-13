# frozen_string_literal: true

require_relative 'base'

module Engine
  module Action
    class DoubleHeadTrains < Base
      attr_reader :trains

      def initialize(entity, trains:)
        super(entity)
        @trains = trains
      end

      def self.h_to_args(h, game)
        {
          trains: h['trains'].map { |t| game.train_by_id(t) },
        }
      end

      def args_to_h
        {
          'trains' => @trains.map(&:id),
        }
      end
    end
  end
end
