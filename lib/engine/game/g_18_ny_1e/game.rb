# frozen_string_literal: true

require_relative '../g_18_ny/game'
require_relative 'meta'
require_relative 'map'
require_relative 'entities'

module Engine
  module Game
    module G18NY1E
      class Game < G18NY::Game
        include_meta(G18NY1E::Meta)
        include G18NY1E::Entities
        include G18NY1E::Map

        PHASES = [
          {
            name: '2H',
            train_limit: { minor: 2, major: 4 },
            tiles: [:yellow],
            operating_rounds: 1,
          },
          {
            name: '4H',
            on: '4H',
            train_limit: { minor: 2, major: 4 },
            tiles: %i[yellow green],
            operating_rounds: 2,
            status: %w[can_buy_companies],
          },
          {
            name: '6H',
            on: '6H',
            train_limit: { minor: 1, major: 3 },
            tiles: %i[yellow green],
            operating_rounds: 2,
            status: %w[can_buy_companies],
          },
          {
            name: '12H',
            on: '12H',
            train_limit: { minor: 1, major: 2 },
            tiles: %i[yellow green brown],
            operating_rounds: 3,
          },
          {
            name: '5DE',
            on: '5DE',
            train_limit: { minor: 1, major: 2 },
            tiles: %i[yellow green brown],
            operating_rounds: 3,
          },
          {
            name: 'D',
            on: 'D',
            train_limit: { minor: 1, major: 2 },
            tiles: %i[yellow green brown gray],
            operating_rounds: 3,
          },
        ].freeze

        TRAINS = [
          { name: '2H', num: 11, distance: 2, price: 100, rusts_on: '6H', salvage: 25 },
          { name: '4H', num: 6, distance: 4, price: 200, rusts_on: '5DE', salvage: 50, events: [{ 'type' => 'float_30' }] },
          { name: '6H', num: 4, distance: 6, price: 300, rusts_on: 'D', salvage: 75, events: [{ 'type' => 'float_40' }] },
          {
            name: '12H',
            num: 3,
            distance: 12,
            price: 600,
            salvage: 150,
            events: [{ 'type' => 'float_50' }, { 'type' => 'close_companies' }, { 'type' => 'nyc_formation' },
                     { 'type' => 'capitalization_round', 'when' => 3 }],
          },
          {
            name: '5DE',
            num: 2,
            distance: [{ 'nodes' => %w[city offboard town], 'pay' => 5, 'visit' => 99, 'multiplier' => 2 }],
            price: 800,
            salvage: 200,
            events: [{ 'type' => 'float_60' }],
          },
          { name: 'D', num: 20, distance: 99, price: 1000, salvage: 250 },
        ].freeze

        def second_edition?
          false
        end
      end
    end
  end
end
