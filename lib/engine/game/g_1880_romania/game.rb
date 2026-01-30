# frozen_string_literal: true

require_relative 'meta'
require_relative '../g_1880/game'
require_relative 'map'
require_relative 'entities'

module Engine
  module Game
    module G1880Romania
      class Game < G1880::Game
        include_meta(G1880Romania::Meta)
        include Map
        include Entities

        CURRENCY_FORMAT_STR = 'L%s'

        CERT_LIMIT = { 3 => 20, 4 => 16, 5 => 14, 6 => 12 }.freeze

        STARTING_CASH = { 3 => 600, 4 => 480, 5 => 400, 6 => 340 }.freeze

        PHASES = [{ name: 'A1', train_limit: 4, tiles: [:yellow] },
                  {
                    name: 'A2',
                    on: '2+2',
                    train_limit: 4,
                    tiles: %i[yellow],
                  },
                  {
                    name: 'B1',
                    on: '3',
                    train_limit: 4,
                    tiles: %i[yellow green],
                  },
                  {
                    name: 'B2',
                    on: '3+3',
                    train_limit: 3,
                    tiles: %i[yellow green],
                  },
                  {
                    name: 'C1',
                    on: '4',
                    train_limit: 3,
                    tiles: %i[yellow green brown],
                  },
                  {
                    name: 'C2',
                    on: '4+4',
                    train_limit: 3,
                    tiles: %i[yellow green brown],
                  },
                  {
                    name: 'D1',
                    on: '6',
                    train_limit: 2,
                    tiles: %i[yellow green brown gray],
                  },
                  {
                    name: 'D2',
                    on: '6E',
                    train_limit: 2,
                    tiles: %i[yellow green brown gray],
                  },
                  {
                    name: 'D3',
                    on: '8',
                    train_limit: 2,
                    tiles: %i[yellow green brown gray],
                  }].freeze

        TRAINS = [{ name: '2', distance: 2, price: 100, rusts_on: '4', num: 10 },
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
                    events: [{ 'type' => 'communist_takeover' }],
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
                  { name: '2P', distance: 2, price: 250, num: 10, available_on: 'C2' }].freeze

        EVENTS_TEXT = G1880::Game::EVENTS_TEXT.merge(
          'signal_end_game' => ['Signal End Game', 'Game ends 3 ORs after purchase of last 6E train']
        ).freeze
      end
    end
  end
end
