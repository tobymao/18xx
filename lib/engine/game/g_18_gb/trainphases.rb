# frozen_string_literal: true

module Engine
  module Game
    module G18GB
      module TrainPhases
        PHASES = [
          {
            name: '2+1',
            train_limit: { '5-share': 3, '10-share': 4 },
            tiles: [:yellow],
            operating_rounds: 2,
          },
          {
            name: '3+1',
            on: '3+1',
            train_limit: { '5-share': 3, '10-share': 4 },
            tiles: %i[yellow green],
            operating_rounds: 2,
          },
          {
            name: '4+2',
            on: '4+2',
            train_limit: { '5-share': 2, '10-share': 3 },
            tiles: %i[yellow green blue],
            operating_rounds: 2,
          },
          {
            name: '5+2',
            on: '5+2',
            train_limit: { '5-share': 2, '10-share': 3 },
            tiles: %i[yellow green blue brown],
            operating_rounds: 2,
          },
          {
            name: '4X',
            on: '4X',
            train_limit: 2,
            tiles: %i[yellow green blue brown],
            operating_rounds: 2,
          },
          {
            name: '5X',
            on: '5X',
            train_limit: 2,
            tiles: %i[yellow green blue brown],
            operating_rounds: 2,
          },
          {
            name: '6X',
            on: '6X',
            train_limit: 2,
            tiles: %i[yellow green blue brown gray],
            operating_rounds: 2,
          },
        ].freeze

        TRAINS = [
          {
            name: '2+1',
            distance: [
              {
                'nodes' => ['town'],
                'pay' => 1,
                'visit' => 1,
              },
              {
                'nodes' => %w[city offboard town],
                'pay' => 2,
                'visit' => 2,
              },
            ],
            price: 80,
            rusts_on: '4+2',
          },
          {
            name: '3+1',
            distance: [
              {
                'nodes' => ['town'],
                'pay' => 1,
                'visit' => 1,
              },
              {
                'nodes' => %w[city offboard town],
                'pay' => 3,
                'visit' => 3,
              },
            ],
            price: 200,
            rusts_on: '4X',
          },
          {
            name: '4+2',
            distance: [
              {
                'nodes' => ['town'],
                'pay' => 2,
                'visit' => 2,
              },
              {
                'nodes' => %w[city offboard town],
                'pay' => 4,
                'visit' => 4,
              },
            ],
            price: 300,
            rusts_on: '6X',
          },
          {
            name: '5+2',
            distance: [
              {
                'nodes' => ['town'],
                'pay' => 2,
                'visit' => 2,
              },
              {
                'nodes' => %w[city offboard town],
                'pay' => 5,
                'visit' => 5,
              },
            ],
            price: 500,
          },
          {
            name: '4X',
            distance: [
              {
                'nodes' => %w[city offboard],
                'pay' => 4,
                'visit' => 4,
              },
            ],
            price: 550,
          },
          {
            name: '5X',
            distance: [
              {
                'nodes' => %w[city offboard],
                'pay' => 5,
                'visit' => 5,
              },
            ],
            price: 650,
          },
          {
            name: '6X',
            distance: [
              {
                'nodes' => %w[city offboard],
                'pay' => 6,
                'visit' => 6,
              },
            ],
            price: 700,
          },
        ].freeze
      end
    end
  end
end
