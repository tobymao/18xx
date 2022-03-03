# frozen_string_literal: true

module Engine
  module Game
    module G18Dixie
      module Trains
        TRAINS = [
          {
            name: '2M',
            distance: [{ 'nodes' => ['town'], 'pay' => 99, 'visit' => 99 },
                       { 'nodes' => %w[offboard city], 'pay' => 2, 'visit' => 2 }],
            price: 0,
            num: 13,
          },
          {
            name: '2',
            distance: [{ 'nodes' => ['town'], 'pay' => 99, 'visit' => 99 },
                       { 'nodes' => %w[offboard city], 'pay' => 2, 'visit' => 2 }],
            price: 80,
            rusts_on: '4',
            num: 5,
          },
          {
            name: '3',
            distance: [{ 'nodes' => ['town'], 'pay' => 99, 'visit' => 99 },
                       { 'nodes' => %w[offboard city], 'pay' => 3, 'visit' => 3 }],
            price: 180,
            rusts_on: '6+1',
            num: 5,
          },
          {
            name: '4',
            distance: [{ 'nodes' => ['town'], 'pay' => 99, 'visit' => 99 },
                       { 'nodes' => %w[offboard city], 'pay' => 4, 'visit' => 4 }],
            price: 300,
            rusts_on: '7+3',
            num: 4,
          },
          {
            name: '5',
            distance: [{ 'nodes' => ['town'], 'pay' => 99, 'visit' => 99 },
                       { 'nodes' => %w[offboard city], 'pay' => 5, 'visit' => 5 }],
            events: [{ 'type' => 'close_companies' }],
            price: 400,
            rusts_on: '5D',
            num: 4,
          },
          {
            name: '6+1',
            distance: [{ 'nodes' => %w[city offboard], 'pay' => 6, 'visit' => 6 },
                       { 'nodes' => ['town'], 'pay' => 1, 'visit' => 1 }],
            events: [{ 'type' => 'close_companies' }],
            price: 600,
            num: 3,
          },
          {
            name: '7+3',
            distance: [{ 'nodes' => %w[city offboard], 'pay' => 7, 'visit' => 7 },
                       { 'nodes' => ['town'], 'pay' => 1, 'visit' => 3 }],
            events: [{ 'type' => 'close_companies' }],
            price: 700,
            num: 2,
          },
          {
            name: '2D',
            available_on: '7',
            distance: [{ 'nodes' => %w[city offboard town], 'pay' => 2, 'visit' => 2, 'multiplier' => 2 }],
            price: 600,
            num: 2,
            variants: [

              name: '4D',
              distance: [{ 'nodes' => %w[city offboard town], 'pay' => 4, 'visit' => 4, 'multiplier' => 2 }],
              events: [], # SCL Merger chance
              price: 800,
            ],
          },
          {
            name: '5D',
            available_on: '7',
            distance: [{ 'nodes' => %w[city offboard town], 'pay' => 5, 'visit' => 5, 'multiplier' => 2 }],
            events: [], # ICG Merger Chance
            price: 900,
            num: 5,
          },
        ].freeze
      end
    end
  end
end
