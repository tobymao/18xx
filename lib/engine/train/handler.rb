# frozen_string_literal: true

module Engine
  module Train
    class Handler
      attr_reader :trains

      def initialize(trains)
        @trains = trains
      end

      private

      def init_trains
        Array(6).map { Base.new('2', distance: 2, price: 80, phase: :yellow) } +
          Array(5).map { Base.new('3', distance: 3, price: 180, phase: :green) } +
          Array(4).map { Base.new('4', distance: 4, price: 300, phase: :green, rusts: '2') } +
          Array(3).map { Base.new('5', distance: 5, price: 450, phase: :brown) } +
          Array(2).map { Base.new('6', distance: 6, price: 630, phase: :brown, rusts: '3') } +
          Array(20).map { Base.new('D', distance: 999, price: 1100, phase: :brown, rusts: '4') }
      end
    end
  end
end
