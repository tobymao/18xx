# frozen_string_literal: true

module Engine
  module Game
    module G1713Menorca
      module Trains
        TRAINS = [
          {
            name: '3H',
            distance: 3,
            price: 90,
            rusts_on: '5H',
            num: 4,
          },
          {
            name: '4H',
            distance: 4,
            price: 180,
            rusts_on: '6H',
            num: 3,
          },
          {
            name: '5H',
            distance: 5,
            price: 360,
            rusts_on: '8H',
            num: 3,
          },
          {
            name: '6H',
            distance: 6,
            price: 540,
            num: 2,
          },
          {
            name: '7H',
            distance: 7,
            price: 720,
            num: 1,
          },
          {
            name: '8H',
            distance: 8,
            price: 900,
            num: 6,
            discount: { '6H' => 120, '7H' => 240 },
          },
        ].freeze
      end
    end
  end
end
