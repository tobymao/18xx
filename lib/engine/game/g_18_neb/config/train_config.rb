# frozen_string_literal: true

module Engine
  module Game
    module G18Neb
      module Config
        module TrainConfig
          TRAINS = [
            {
              name: '2+2',
              distance: [{ 'nodes' => %w[town], 'pay' => 2 },
                         { 'nodes' => %w[town city offboard], 'pay' => 2 }],
              price: 100,
              rusts_on: '4+4',
              num: 5,
            },
            {
              name: '3+3',
              distance: [{ 'nodes' => %w[town], 'pay' => 3 },
                         { 'nodes' => %w[town city offboard], 'pay' => 3 }],
              price: 200,
              rusts_on: '6/8',
              num: 4,
            },
            {
              name: '4+4',
              distance: [{ 'nodes' => %w[town], 'pay' => 4 },
                         { 'nodes' => %w[town city offboard], 'pay' => 4 }],
              price: 300,
              rusts_on: '4D',
              num: 3,
            },
            {
              name: '5/7',
              distance: [{ 'nodes' => %w[city offboard town], 'pay' => 5, 'visit' => 7 }],
              price: 450,
              num: 2,
              events: [{ 'type' => 'close_companies' },
                       { 'type' => 'local_railroads_available' }],
            },
            {
              name: '6/8',
              distance: [{ 'pay' => 6, 'visit' => 8 }],
              price: 600,
              num: 2,
            },
            {
              name: '4D',
              # Can pick 4 best city or offboards, skipping smaller cities.
              distance: [{ 'nodes' => %w[city offboard], 'pay' => 4, 'visit' => 99, 'multiplier' => 2 },
                         { 'nodes' => ['town'], 'pay' => 99, 'visit' => 99 }],
              price: 900,
              num: 20,
              available_on: '6',
              discount: { '4' => 300, '5' => 300, '6' => 300 },
            },
          ].freeze
        end
      end
    end
  end
end
