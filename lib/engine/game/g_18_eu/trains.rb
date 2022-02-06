# frozen_string_literal: true

module Engine
  module Game
    module G18EU
      module Trains
        PHASES = [
          {
            name: '2',
            train_limit: 4,
            tiles: [:yellow],
            status: ['minor_limit_two'],
            operating_rounds: 2,
          },
          {
            name: '3',
            on: '3',
            train_limit: 4,
            tiles: %i[yellow green],
            status: ['minor_limit_two'],
            operating_rounds: 2,
          },
          {
            name: '4',
            on: '4',
            train_limit: 3,
            tiles: %i[yellow green],
            status: ['minor_limit_one'],
            operating_rounds: 2,
          },
          {
            name: '5',
            on: '5',
            train_limit: 2,
            tiles: %i[yellow green brown],
            status: %w[minor_limit_one normal_formation],
            operating_rounds: 2,
          },
          {
            name: '6',
            on: '6',
            train_limit: 2,
            tiles: %i[yellow green brown],
            status: ['normal_formation'],
            operating_rounds: 2,
          },
          {
            name: '8',
            on: '8',
            train_limit: 2,
            tiles: %i[yellow green brown gray],
            status: ['normal_formation'],
            operating_rounds: 2,
          },
        ].freeze

        TRAINS = [
          {
            name: '2',
            rusts_on: '4',
            distance: [{ 'nodes' => %w[city offboard], 'pay' => 2, 'visit' => 2 },
                       { 'nodes' => ['town'], 'pay' => 99, 'visit' => 99 }],
            price: 100,
            num: 15,
          },
          {
            name: '3',
            rusts_on: '6',
            distance: [{ 'nodes' => %w[city offboard], 'pay' => 3, 'visit' => 3 },
                       { 'nodes' => ['town'], 'pay' => 99, 'visit' => 99 }],
            price: 200,
            num: 5,
          },
          {
            name: '4',
            rusts_on: '8',
            distance: [{ 'nodes' => %w[city offboard], 'pay' => 4, 'visit' => 4 },
                       { 'nodes' => ['town'], 'pay' => 99, 'visit' => 99 }],
            price: 300,
            num: 4,
          },
          {
            name: '5',
            distance: [{ 'nodes' => %w[city offboard], 'pay' => 5, 'visit' => 5 },
                       { 'nodes' => ['town'], 'pay' => 99, 'visit' => 99 }],
            events: [{ 'type' => 'minor_exchange' }],
            price: 500,
            num: 3,
          },
          {
            name: '6',
            distance: [{ 'nodes' => %w[city offboard], 'pay' => 6, 'visit' => 6 },
                       { 'nodes' => ['town'], 'pay' => 99, 'visit' => 99 }],
            price: 600,
            num: 2,
          },
          {
            name: '8',
            distance: [{ 'nodes' => %w[city offboard], 'pay' => 8, 'visit' => 8 },
                       { 'nodes' => ['town'], 'pay' => 99, 'visit' => 99 }],
            price: 800,
            num: 99,
          },
          {
            name: 'P',
            available_on: '3',
            requires_token: false,
            distance: [{ 'nodes' => %w[city offboard], 'pay' => 1, 'visit' => 1 },
                       { 'nodes' => ['town'], 'pay' => 0, 'visit' => 0 }],
            price: 100,
            num: 5,
          },
        ].freeze
      end
    end
  end
end
