# frozen_string_literal: true

require_relative 'meta'
require_relative '../base'
require_relative 'entities'
require_relative 'map'

module Engine
  module Game
    module G18Scan
      class Game < Game::Base
        include_meta(G18Scan::Meta)
        include Map
        include Entities

        GAME_END_CHECK = { bank: :full_or }.freeze

        BANKRUPTCY_ENDS_GAME_AFTER = :all_but_one

        BANK_CASH = 6_000

        CURRENCY_FORMAT_STR = 'K%d'

        STARTING_CASH = { 2 => 900, 3 => 600, 4 => 450 }.freeze

        CAPITALIZATION = :incremental

        SELL_AFTER = :operate

        SELL_BUY_ORDER = :sell_buy

        HOME_TOKEN_TIMING = :float

        MUST_BUY_TRAIN = :always

        CERT_LIMIT = { 2 => 18, 3 => 12, 4 => 9 }.freeze
        MARKET = [
          %w[82 90 100 110 122 135 150 165 180 200 220 245 270 300 330 360 400],
          %w[75 82 90 100 110 122 135 150 165 180 200 220 245 270],
          %w[70 75 82 90 100p 110 122 135 150 165 180],
          %w[65 70 75 82p 90p 100 110 122],
          %w[60 65 70p 75p 82 90],
          %w[50 60 65 70 75],
          %w[40 50 60 65],
        ].freeze

        PHASES = [
          {
            name: '2',
            train_limit: { minor: 2, major: 4  },
            tiles: [:yellow],
            operating_rounds: 2,
          },
          {
            name: '3',
            on: '3',
            train_limit: 4,
            tiles: %w[yellow green],
            operating_rounds: 2,
            on: '3'
          },
          {
            name: '4',
            on: '4',
            train_limit: 3,
            tiles: %w[yellow green],
            operating_rounds: 2,
            on: '4'
          },
          {
            name: '5',
            on: '5',
            train_limit: 2,
            tiles: %w[yellow green brown],
            operating_rounds: 2,
            on: '5'
          },
          {
            name: '5E',
            on: '5E',
            train_limit: 2,
            tiles: %w[yellow green brown],
            operating_rounds: 2,
            on: '5E'
          },
          {
            name: '4D',
            on: '4D',
            train_limit: 2,
            tiles: %w[yellow green brown],
            operating_rounds: 2,
            on: '4D'
          },
        ].freeze

        TRAINS = [
          {
            name: '2',
            distance: 2,
            price: 100,
            rusts_on: '4',
            num: 6,
            variants: [
              {
                name: '1+1',
                distance: [
                  { 'nodes' => ['city'], 'pay' => 1, 'visit' => 1 },
                  { 'nodes' => ['town'], 'pay' => 1, 'visit' => 1 },
                ],
                price: 80,
              },
            ],
          },
          {
            name: '3',
            distance: 3,
            price: 200,
            rusts_on: '5',
            num: 4,
            variants: [
              {
                name: '2+2',
                distance: [
                  { 'nodes' => ['city'], 'pay' => 2, 'visit' => 2 },
                  { 'nodes' => ['town'], 'pay' => 2, 'visit' => 2 },
                ],
                price: 180,
              },
            ],
          },
          {
            name: '4',
            distance: 4,
            price: 300,
            rusts_on: '4D',
            num: 3,
            variants: [
              {
                name: '3+3',
                distance: [
                  { 'nodes' => ['city'], 'pay' => 3, 'visit' => 3 },
                  { 'nodes' => ['town'], 'pay' => 3, 'visit' => 3 },
                ],
                price: 80,
              },
            ],
          },
          {
            name: '5',
            distance: 5,
            price: 500,
            num: 2,
            variants: [
              {
                name: '4+4',
                distance: [
                  { 'nodes' => ['city'], 'pay' => 4, 'visit' => 4 },
                  { 'nodes' => ['town'], 'pay' => 4, 'visit' => 4 },
                ],
                price: 480,
              },
            ],
          },
          {
            name: '5E',
            distance: 5,
            price: 600,
            num: 2,
          },
          {
            name: '4D',
            distance: 99,
            price: 800,
            num: 2,
          },
       ].freeze
      end
    end
  end
end
