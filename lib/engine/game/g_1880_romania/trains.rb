# frozen_string_literal: true

module Engine
  module Game
    module G1880Romania
      module Trains
        TRAINS = [
          { name: '2', distance: 2, price: 100, rusts_on: '4', num: 10 },
          {
            name: '2+2',
            distance: [{ 'nodes' => ['town'], 'pay' => 2, 'visit' => 2 },
                       { 'nodes' => %w[city offboard town], 'pay' => 2, 'visit' => 2 }],
            price: 180,
            rusts_on: '4+4',
            num: 5,
          },
          {
            name: '3',
            distance: 3,
            price: 180,
            rusts_on: '6',
            num: 5,
            events: [{ 'type' => 'float_30' },
                     { 'type' => 'permit_b' },
                     { 'type' => 'all_shares_available' },
                     { 'type' => 'receive_capital' },
                     { 'type' => 'can_buy_trains' }],
          },
          {
            name: '3+3',
            distance: [{ 'nodes' => ['town'], 'pay' => 3, 'visit' => 3 },
                       { 'nodes' => %w[city offboard town], 'pay' => 3, 'visit' => 3 }],
            price: 300,
            rusts_on: '6E',
            num: 5,
            events: [{ 'type' => 'communist_takeover' },
                     { 'type' => 'close_p7' }],
          },
          {
            name: '4',
            distance: 4,
            price: 300,
            rusts_on: '8',
            num: 5,
            events: [{ 'type' => 'float_40' },
                     { 'type' => 'permit_c' }],
          },
          {
            name: '4+4',
            distance: [{ 'nodes' => ['town'], 'pay' => 4, 'visit' => 4 },
                       { 'nodes' => %w[city offboard town], 'pay' => 4, 'visit' => 4 }],
            price: 600,
            num: 5,
            events: [{ 'type' => 'stock_exchange_reopens' }],
          },
          {
            name: '6',
            distance: 6,
            price: 600,
            num: 5,
            events: [{ 'type' => 'float_60' },
                     { 'type' => 'token_cost_doubled' },
                     { 'type' => 'permit_d' }],
          },
          {
            name: '6E',
            distance: [{ 'nodes' => %w[city offboard town], 'pay' => 6, 'visit' => 99 }],
            price: 700,
            num: 5,
            events: [{ 'type' => 'signal_end_game', 'when' => 5 }],
          },
          {
            name: '8',
            distance: 8,
            price: 800,
            num: 2,
          },
          {
            name: '8E',
            distance: [{ 'nodes' => %w[city offboard town], 'pay' => 8, 'visit' => 99 }],
            price: 900,
            num: 2,
          },
          { name: '2P', distance: 2, price: 250, num: 10, available_on: 'C2' },
        ].freeze
      end
    end
  end
end
