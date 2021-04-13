# frozen_string_literal: true

require_relative 'meta'
require_relative 'entities'
require_relative 'map'
require_relative '../base'

module Engine
  module Game
    module G1866
      class Game < Game::Base
        include_meta(G1866::Meta)
        include G1866::Entities
        include G1866::Map

        GAME_END_CHECK = { bank: :full_or, stock_market: :current_or }.freeze

        BANKRUPTCY_ALLOWED = false

        CURRENCY_FORMAT_STR = '£%d'

        BANK_CASH = 99_999

        CERT_LIMIT = { 3 => 42, 4 => 32, 5 => 25, 6 => 21, 7 => 18 }.freeze

        EBUY_OTHER_VALUE = false

        STARTING_CASH = { 3 => 800, 4 => 600, 5 => 480, 6 => 400, 7 => 340 }.freeze

        CAPITALIZATION = :incremental

        MUST_SELL_IN_BLOCKS = false

        TILE_TYPE = :lawson

        MARKET = [
          %w[0 5 10 15 20 25 30 35 40 45 50 55 60 65 70 75 80 90 100 110 120 135 150 165 180 200 220 240 260 280 300
             330 360 390 420 460 500 540 580 630 680],
          %w[0 5 10 15 20 25 30 35 40 45 50 55 60 65 70 75 80 90 100 110 120 135 150 165 180 200 220 240 260 280 300
             330 360 390 420 460 500 540 580 630 680],
          %w[0 5 10 15 20 25 30 35 40 45 50 55 60 65 70 75 80 90 100 110 120 135 150 165 180 200 220 240 260 280 300
             330 360 390 420 460 500 540 580 630 680],
        ].freeze

        PHASES = [
          {
            name: '1',
            on: '',
            train_limit: 5,
            tiles: [:yellow],
            operating_rounds: 1,
          },
          {
            name: '2',
            on: %w[2 3],
            train_limit: 5,
            tiles: [:yellow],
            operating_rounds: 2,
          },
          {
            name: '3',
            on: '3',
            train_limit: 4,
            tiles: %i[yellow green],
            operating_rounds: 2,
          },
          {
            name: '4',
            on: '4',
            train_limit: 4,
            tiles: %i[yellow green],
            operating_rounds: 2,
          },
          {
            name: '5',
            on: '5',
            train_limit: 3,
            tiles: %i[yellow green brown],
            operating_rounds: 2,
          },
          {
            name: '6',
            on: '6',
            train_limit: 3,
            tiles: %i[yellow green brown],
            operating_rounds: 2,
          },
          {
            name: '8',
            on: '8',
            train_limit: 2,
            tiles: %i[yellow green brown gray],
            operating_rounds: 2,
          },
          {
            name: '10',
            on: '10',
            train_limit: 2,
            tiles: %i[yellow green brown gray],
            operating_rounds: 2,
          },
        ].freeze

        TRAINS = [
          {
            name: 'L',
            distance: [
              {
                'nodes' => ['city'],
                'pay' => 1,
                'visit' => 1,
              },
              {
                'nodes' => ['town'],
                'pay' => 1,
                'visit' => 1,
              },
            ],
            num: 12,
            price: 50,
            rusts_on: '3',
            variants: [
              {
                name: '2',
                distance: 2,
                price: 100,
                rusts_on: '4',
                available_on: '1',
              },
            ],
          },
          {
            name: '3',
            distance: 3,
            num: 6,
            price: 200,
            rusts_on: '6',
          },
          {
            name: '4',
            distance: 4,
            num: 6,
            price: 300,
            rusts_on: '8',
          },
          {
            name: '5',
            distance: 5,
            num: 6,
            price: 450,
            variants: [
              {
                name: '3E',
                distance: 3,
                multiplier: 2,
                price: 450,
              },
            ],
          },
          {
            name: '6',
            distance: 6,
            num: 6,
            price: 600,
            variants: [
              {
                name: '4E',
                distance: 4,
                multiplier: 2,
                price: 600,
              },
            ],
          },
          {
            name: '8',
            distance: 8,
            num: 6,
            price: 800,
            variants: [
              {
                name: '5E',
                distance: 5,
                multiplier: 2,
                price: 800,
              },
            ],
          },
          {
            name: '10',
            distance: 10,
            num: 20,
            price: 1000,
            variants: [
              {
                name: '6E',
                distance: 6,
                multiplier: 2,
                price: 1000,
              },
            ],
          },
        ].freeze

        LAYOUT = :pointy

        SELL_MOVEMENT = :down_share

        HOME_TOKEN_TIMING = :operate
        MUST_BID_INCREMENT_MULTIPLE = true
        MUST_BUY_TRAIN = :always
        NEXT_SR_PLAYER_ORDER = :most_cash

        SELL_AFTER = :operate

        SELL_BUY_ORDER = :sell_buy

        STOCK_TOKENS = {
          '3': 5,
          '4': 4,
          '5': 3,
          '6': 3,
          '7': 2,
        }.freeze
      end
    end
  end
end
