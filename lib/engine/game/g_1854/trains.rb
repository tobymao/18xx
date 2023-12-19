# frozen_string_literal: true

module Engine
  module Game
    module G1854
      module Trains
        TRAINS = [
          {
            name: '2',
            distance: 2,
            num: 6,
            price: 100,
            rusts_on: '4',
          },
          {
            name: '1+',
            distance: [{ 'nodes' => %w[city offboard], 'pay' => 1, 'visit' => 1 },
                       { 'nodes' => ['town'], 'pay' => 99, 'visit' => 99 }],
            num: 6,
            price: 100,
            rusts_on: '4',
            available_on: '2',
          },
          {
            name: '3',
            distance: 3,
            num: 5,
            price: 200,
            rusts_on: '6',
            variants: [
              {
                name: '2+',
                num: 4,
                distance: [{ 'nodes' => %w[city offboard], 'pay' => 2, 'visit' => 2 },
                           { 'nodes' => ['town'], 'pay' => 99, 'visit' => 99 }],
                price: 120,
                rusts_on: '6',
                available_on: '3',
              },
              {
                name: '3+',
                num: 3,
                distance: [{ 'nodes' => %w[city offboard], 'pay' => 3, 'visit' => 3 },
                           { 'nodes' => ['town'], 'pay' => 99, 'visit' => 99 }],
                price: 160,
                rusts_on: '6',
              },
            ],
            available_on: '3',
          },
          {
            name: '4',
            distance: 4,
            num: 4,
            price: 320,
            rusts_on: '4',
          },
          {
            name: '5',
            distance: 5,
            num: 3,
            price: 530,
          },
          {
            name: '6',
            distance: 6,
            num: 2,
            price: 670,
          },
          {
            name: '8',
            distance: 8,
            num: 6,
            price: 900,
          },
          {
            name: '8Ox',
            distance: 8,
            num: 5,
            price: 1200,
          },
        ].freeze
      end
    end
  end
end
