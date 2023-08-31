# frozen_string_literal: true

require_relative '../g_1817/game'
require_relative 'meta'
require_relative 'entities'
require_relative 'map'

module Engine
  module Game
    module G1817NA
      class Game < G1817::Game
        include_meta(G1817NA::Meta)
        include Entities
        include Map

        CURRENCY_FORMAT_STR = '$%s'

        BANK_CASH = 99_999

        CERT_LIMIT = { 2 => 21, 3 => 16, 4 => 13, 5 => 11, 6 => 9 }.freeze

        STARTING_CASH = { 2 => 420, 3 => 315, 4 => 252, 5 => 210, 6 => 180 }.freeze

        CAPITALIZATION = :incremental

        MUST_SELL_IN_BLOCKS = false

        MARKET = [
          %w[0l
             0a
             0a
             0a
             40
             45
             50p
             55s
             60p
             65p
             70s
             80p
             90p
             100p
             110p
             120s
             135p
             150p
             165p
             180p
             200p
             220
             245
             270
             300
             330
             360
             400
             440
             490
             540
             600],
           ].freeze

        PHASES = [
          {
            name: '2',
            train_limit: 4,
            tiles: [:yellow],
            operating_rounds: 2,
            corporation_sizes: [2],
          },
          {
            name: '2+',
            on: '2+',
            train_limit: 4,
            tiles: [:yellow],
            operating_rounds: 2,
            corporation_sizes: [2],
          },
          {
            name: '3',
            on: '3',
            train_limit: 4,
            tiles: %i[yellow green],
            operating_rounds: 2,
            corporation_sizes: [2, 5],
          },
          {
            name: '4',
            on: '4',
            train_limit: 3,
            tiles: %i[yellow green],
            operating_rounds: 2,
            corporation_sizes: [5],
          },
          {
            name: '5',
            on: '5',
            train_limit: 3,
            tiles: %i[yellow green brown],
            operating_rounds: 2,
            corporation_sizes: [5, 10],
          },
          {
            name: '6',
            on: '6',
            train_limit: 2,
            tiles: %i[yellow green brown],
            operating_rounds: 2,
            corporation_sizes: [10],
          },
          {
            name: '7',
            on: '7',
            train_limit: 2,
            tiles: %i[yellow green brown gray],
            operating_rounds: 2,
            corporation_sizes: [10],
          },
          {
            name: '8',
            on: '8',
            train_limit: 2,
            tiles: %i[yellow green brown gray],
            status: ['no_new_shorts'],
            operating_rounds: 2,
            corporation_sizes: [10],
          },
        ].freeze

        TRAINS = [{ name: '2', distance: 2, price: 100, rusts_on: '4', num: 31 },
                  { name: '2+', distance: 2, price: 100, obsolete_on: '4', num: 3 },
                  { name: '3', distance: 3, price: 250, rusts_on: '6', num: 8 },
                  { name: '4', distance: 4, price: 400, rusts_on: '8', num: 6 },
                  { name: '5', distance: 5, price: 600, num: 4 },
                  { name: '6', distance: 6, price: 750, num: 3 },
                  { name: '7', distance: 7, price: 900, num: 2 },
                  {
                    name: '8',
                    distance: 8,
                    price: 1100,
                    num: 30,
                    events: [{ 'type' => 'signal_end_game' }],
                  }].freeze

        SEED_MONEY = 150
        LOANS_PER_INCREMENT = 4

        def setup_preround
          super
          @pittsburgh_private = @companies.find { |c| c.id == 'DTC' }
        end
      end
    end
  end
end
