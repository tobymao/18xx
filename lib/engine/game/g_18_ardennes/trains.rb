# frozen_string_literal: true

module Engine
  module Game
    module G18Ardennes
      module Trains
        PHASES = [
          {
            name: '2',
            train_limit: { minor: 2, '5-share': 4, '10-share': 4 },
            tiles: [:yellow],
            operating_rounds: 2,
          },
          {
            name: '3',
            on: '3',
            train_limit: { minor: 2, '5-share': 4, '10-share': 4 },
            tiles: %i[yellow green],
            operating_rounds: 2,
          },
          {
            name: '4',
            on: '4',
            train_limit: { minor: 2, '5-share': 3, '10-share': 3 },
            tiles: %i[yellow green],
            operating_rounds: 2,
          },
          {
            name: '5',
            on: '5',
            train_limit: { minor: 2, '5-share': 2, '10-share': 2 },
            tiles: %i[yellow green brown],
            operating_rounds: 2,
          },
          {
            name: '6',
            on: %w[6 4D],
            train_limit: { minor: 2, '5-share': 2, '10-share': 2 },
            tiles: %i[yellow green brown],
            operating_rounds: 2,
          },
        ].freeze

        TRAINS = [
          {
            name: '2',
            rusts_on: '4',
            distance: [{ 'nodes' => %w[city], 'pay' => 2, 'visit' => 2 },
                       { 'nodes' => %w[town], 'pay' => 99, 'visit' => 99 }],
            num: 15,
            price: 100,
          },
          {
            name: '3',
            num: 7,
            rusts_on: '6',
            distance: [{ 'nodes' => %w[city], 'pay' => 3, 'visit' => 3 },
                       { 'nodes' => %w[town], 'pay' => 99, 'visit' => 99 }],
            price: 200,
          },
          {
            name: '4',
            num: 4,
            distance: [{ 'nodes' => %w[city], 'pay' => 4, 'visit' => 4 },
                       { 'nodes' => %w[town], 'pay' => 99, 'visit' => 99 }],
            price: 400,
          },
          {
            name: '5',
            num: 3,
            distance: [{ 'nodes' => %w[city], 'pay' => 5, 'visit' => 5 },
                       { 'nodes' => %w[town], 'pay' => 99, 'visit' => 99 }],
            price: 500,
          },
          {
            name: '6',
            num: 30,
            distance: [{ 'nodes' => %w[city], 'pay' => 6, 'visit' => 6 },
                       { 'nodes' => %w[town], 'pay' => 99, 'visit' => 99 }],
            price: 600,
            variants: [
              {
                name: '4D',
                distance: [{ 'nodes' => %w[city], 'pay' => 4, 'visit' => 99 },
                           { 'nodes' => %w[town], 'pay' => 0, 'visit' => 99 }],
                multiplier: 2,
                price: 800,
                discount: {
                  '4' => 200,
                  '5' => 200,
                  '6' => 200,
                },
              },
            ],
          },
        ].freeze
      end
    end
  end
end
