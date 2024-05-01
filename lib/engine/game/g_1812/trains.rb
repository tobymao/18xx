# frozen_string_literal: true

module Engine
  module Game
    module G1812
      module Trains
        TRAINS = [
          {
            name: '2',
            distance: [{ 'nodes' => %w[city offboard town], 'pay' => 2, 'visit' => 2 },
                       { 'nodes' => ['town'], 'pay' => 0, 'visit' => 99 }],
            price: 100,
            rusts_on: '4',
            variants: [
              {
                name: '1G',
                distance: [{ 'nodes' => %w[city offboard town], 'pay' => 3, 'visit' => 3 },
                           { 'nodes' => ['town'], 'pay' => 0, 'visit' => 99 }],
                price: 90,
              },
            ],
          },
          {
            name: '3',
            distance: [{ 'nodes' => %w[city offboard town], 'pay' => 3, 'visit' => 3 },
                       { 'nodes' => ['town'], 'pay' => 0, 'visit' => 99 }],
            price: 200,
            rusts_on: '5',
            variants: [
              {
                name: '2G',
                distance: [{ 'nodes' => %w[city offboard town], 'pay' => 4, 'visit' => 4 },
                           { 'nodes' => ['town'], 'pay' => 0, 'visit' => 99 }],
                price: 180,
              },
            ],
          },
          {
            name: '3+1',
            distance: [{ 'nodes' => %w[city offboard town], 'pay' => 3, 'visit' => 3 },
                       { 'nodes' => ['town'], 'pay' => 1, 'visit' => 99 }],
            price: 220,
            rusts_on: '3D',
            variants: [
              {
                name: '2+1G',
                distance: [{ 'nodes' => %w[city offboard town], 'pay' => 5, 'visit' => 5 },
                           { 'nodes' => ['town'], 'pay' => 0, 'visit' => 99 }],
                price: 200,
              },
            ],
          },
          {
            name: '4',
            distance: [{ 'nodes' => %w[city offboard town], 'pay' => 4, 'visit' => 4 },
                       { 'nodes' => ['town'], 'pay' => 0, 'visit' => 99 }],
            price: 400,
            variants: [
              {
                name: '3+2G',
                distance: [{ 'nodes' => %w[city offboard town], 'pay' => 5, 'visit' => 5 },
                           { 'nodes' => ['town'], 'pay' => 0, 'visit' => 99 }],
                price: 360,
              },
            ],
          },
          {
            name: '5',
            distance: [{ 'nodes' => %w[city offboard town], 'pay' => 3, 'visit' => 3 },
                       { 'nodes' => ['town'], 'pay' => 1, 'visit' => 99 }],
            price: 500,
            variants: [
              {
                name: '4+2G',
                distance: [{ 'nodes' => %w[city offboard town], 'pay' => 6, 'visit' => 6 },
                           { 'nodes' => ['town'], 'pay' => 0, 'visit' => 99 }],
                price: 460,
              },
            ],
            events: [{ 'type' => 'close_companies' }],
          },
          {
            name: '3D',
            distance: [{ 'nodes' => %w[city offboard], 'pay' => 3, 'visit' => 3, 'multiplier' => 2 },
                       { 'nodes' => ['town'], 'pay' => 0, 'visit' => 99 }],
            price: 750,
            variants: [
              {
                name: '2+2GD',
                distance: [{ 'nodes' => %w[city offboard town], 'pay' => 6, 'visit' => 6, 'multiplier' => 2 },
                           { 'nodes' => ['town'], 'pay' => 0, 'visit' => 99 }],
                price: 460,
              },
            ],
          },
        ].freeze
      end
    end
  end
end
