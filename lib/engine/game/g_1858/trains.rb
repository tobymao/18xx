# frozen_string_literal: true

module Engine
  module Game
    module G1858
      module Trains
        OBSOLETE_TRAINS_COUNT_FOR_LIMIT = true

        PHASES = [
          {
            name: '2',
            train_limit: 4,
            tiles: [:yellow], # FIXME: narrow gauge tiles not available until phase 3
            operating_rounds: 2,
          },
          {
            name: '3',
            on: %w[4H 2M],
            train_limit: 4,
            tiles: %i[yellow green],
            operating_rounds: 2,
          },
          {
            name: '4',
            on: %w[6H 3M],
            train_limit: 3,
            tiles: %i[yellow green],
            operating_rounds: 2,
          },
          {
            name: '5',
            on: %w[5E 4M],
            train_limit: 2,
            tiles: %i[yellow green brown],
            operating_rounds: 2,
          },
          {
            name: '6',
            on: %w[6E 5M],
            train_limit: 2,
            tiles: %i[yellow green brown],
            operating_rounds: 2,
          },
          {
            name: '7',
            on: %w[7E 6M],
            train_limit: 2,
            tiles: %i[yellow green brown gray],
            operating_rounds: 2,
          },
        ].freeze

        TRAINS = [
          {
            name: '2H',
            obsolete_on: '6H',
            rusts_on: '6E',
            distance: 2,
            price: 100,
            num: 6,
          },
          {
            name: '4H',
            obsolete_on: '6E',
            rusts_on: '7E',
            distance: 4,
            price: 200,
            num: 5,
            variants: [
              {
                name: '2M',
                distance: [{ 'nodes' => %w[city offboard], 'pay' => 2, 'visit' => 2 },
                           { 'nodes' => %w[town], 'pay' => 99, 'visit' => 99 }],
                price: 100,
              },
            ],
          },
          {
            name: '6H',
            obsolete_on: '7E',
            rusts_on: '5D',   # FIXME: rusted by fifth 7E/6M/5D train bought
            distance: 6,
            price: 300,
            num: 4,
            variants: [
              {
                name: '3M',
                distance: [{ 'nodes' => %w[city offboard], 'pay' => 3, 'visit' => 3 },
                           { 'nodes' => %w[town], 'pay' => 99, 'visit' => 99 }],
                price: 200,
              },
            ],
          },
          {
            name: '5E',
            distance: [{ 'nodes' => %w[city offboard], 'pay' => 5, 'visit' => 5 },
                       { 'nodes' => %w[town], 'pay' => 99, 'visit' => 0 }],
            price: 500,
            num: 3,
            variants: [
              {
                name: '4M',
                distance: [{ 'nodes' => %w[city offboard], 'pay' => 4, 'visit' => 4 },
                           { 'nodes' => %w[town], 'pay' => 99, 'visit' => 99 }],
                price: 400,
              },
            ],
          },
          {
            name: '6E',
            distance: [{ 'nodes' => %w[city offboard], 'pay' => 6, 'visit' => 6 },
                       { 'nodes' => %w[town], 'pay' => 99, 'visit' => 0 }],
            price: 650,
            num: 2,
            variants: [
              {
                name: '5M',
                distance: [{ 'nodes' => %w[city offboard], 'pay' => 5, 'visit' => 5 },
                           { 'nodes' => %w[town], 'pay' => 99, 'visit' => 99 }],
                price: 550,
              },
            ],
          },
          {
            name: '7E',
            distance: [{ 'nodes' => %w[city offboard], 'pay' => 7, 'visit' => 7 },
                       { 'nodes' => %w[town], 'pay' => 99, 'visit' => 0 }],
            price: 800,
            num: 16,
            variants: [
              {
                name: '6M',
                distance: [{ 'nodes' => %w[city offboard], 'pay' => 6, 'visit' => 6 },
                           { 'nodes' => %w[town], 'pay' => 99, 'visit' => 99 }],
                price: 700,
              },
            ],
          },
          {
            name: '5D',
            distance: [{ 'nodes' => %w[city offboard], 'pay' => 5, 'visit' => 5 },
                       { 'nodes' => %w[town], 'pay' => 99, 'visit' => 0 }],
            price: 1_100,
            num: 8,
            multiplier: 2,
          },
        ].freeze
      end
    end
  end
end
