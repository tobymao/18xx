# frozen_string_literal: true

module Engine
  module Game
    module G18Uruguay
      module Trains
        TRAINS = [
          {
            name: 'Ship 1',
            distance: 2,
            price: 50,
            rusts_on: '3',
            num: 1,
          },
          {
            name: '2',
            distance: 2,
            price: 80,
            rusts_on: '4',
            num: 9,
            variants: [
              {
                name: 'Ship 2',
                distance: 2,
                price: 80,
              },
            ],
          },
          {
            name: '3',
            distance: 3,
            price: 180,
            rusts_on: '6',
            num: 6,
            variants: [
              {
                name: 'Ship 3',
                distance: 2,
                price: 160,
                rusts_on: '5',
              },
            ],
          },
          {
            name: '4',
            distance: 4,
            price: 300,
            rusts_on: 'D',
            num: 5,
            variants: [
              {
                name: 'Ship 4',
                distance: 2,
                price: 300,
              },
            ],
          },
          {
            name: '5',
            distance: 5,
            price: 440,
            num: 3,
            events: [{ 'type' => 'close_companies' }],
            variants: [
              {
                name: 'Ship 5',
                distance: 2,
                price: 440,
              },
            ],
          },
          {
            name: '6',
            distance: 6,
            price: 620,
            num: 2,
            events: [{ 'type' => 'nationalization', 'when' => 2 }],
            variants: [
              {
                name: 'Ship 6',
                distance: 2,
                price: 620,
              },
            ],
          },
          {
            name: '7',
            distance: 7,
            price: 1,
            num: 1,
            variants: [
              {
                name: 'Ship 7',
                distance: 2,
                price: 620,
              },
            ],
          },
          {
            name: 'D',
            distance: 999,
            price: 950,
            num: 20,
            discount: { '4' => 200, '5' => 200, '6' => 200, '7' => 200 },
            variants: [
              {
                name: '4D',
                distance: [
                  {
                    'nodes' => %w[offboard city],
                    'pay' => 4,
                    'visit' => 4,
                  },
                  {
                    'nodes' => ['town'],
                    'pay' => 0,
                    'visit' => 999,
                  },
                ],
                price: 850,
              },
            ],
          },
        ].freeze
      end
    end
  end
end
