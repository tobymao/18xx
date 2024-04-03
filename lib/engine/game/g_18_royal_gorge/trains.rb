# frozen_string_literal: true

module Engine
  module Game
    module G18RoyalGorge
      module Trains
        TRAINS = [
          {
            name: '2+',
            distance: [{ 'nodes' => %w[city offboard], 'pay' => 2, 'visit' => 2 },
                       { 'nodes' => ['town'], 'pay' => 99, 'visit' => 99 }],
            price: 80,
            rusts_on: '4+',
            salvage: 20,
            num: 4,
            events: [{ 'type' => 'green_phase', 'when' => 4 }],
          },
          {
            name: '3+',
            distance: [{ 'nodes' => %w[city offboard], 'pay' => 3, 'visit' => 3 },
                       { 'nodes' => ['town'], 'pay' => 99, 'visit' => 99 }],
            price: 180,
            rusts_on: '6',
            salvage: 45,
            num: 4,
            events: [{ 'type' => 'treaty_of_boston', 'when' => 2 }],
          },
          {
            name: '4+',
            distance: [{ 'nodes' => %w[city offboard], 'pay' => 4, 'visit' => 4 },
                       { 'nodes' => ['town'], 'pay' => 99, 'visit' => 99 }],
            price: 400,
            num: 3,
            events: [{ 'type' => 'brown_phase', 'when' => 3 }],
          },
          {
            name: '5+',
            distance: [{ 'nodes' => %w[city offboard], 'pay' => 5, 'visit' => 5 },
                       { 'nodes' => ['town'], 'pay' => 99, 'visit' => 99 }],
            price: 500,
            num: 2,
            events: [{ 'type' => 'close_gold_miner' }, { 'type' => 'gray_phase', 'when' => 2 }],
          },
          {
            name: '6',
            distance: [{ 'nodes' => %w[city offboard town], 'pay' => 6, 'visit' => 6, 'multiplier' => 2 }],
            price: 650,
            num: 5,
            events: [{ 'type' => 'trigger_endgame' }],
          },
        ].deep_freeze

        PHASES = [
          {
            name: 'Yellow',
            train_limit: 2,
            tiles: [:yellow],
            status: [],
            operating_rounds: 2,
          },
          {
            name: 'Green',
            on: '2+-3',
            train_limit: 2,
            tiles: %i[yellow green],
            status: %w[can_buy_companies],
            operating_rounds: 2,
          },
          {
            name: 'Brown',
            on: '4+-2',
            train_limit: 2,
            tiles: %i[yellow green brown],
            status: %w[can_buy_companies],
            operating_rounds: 2,
          },
          {
            name: 'Silver',
            on: '5+-1',
            train_limit: 2,
            tiles: %i[yellow green brown gray],
            status: %w[can_buy_companies],
            operating_rounds: 2,
          },
        ].deep_freeze
      end
    end
  end
end
