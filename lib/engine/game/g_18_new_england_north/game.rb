# frozen_string_literal: true

require_relative '../g_18_new_england/game'
require_relative 'meta'
require_relative 'map'
require_relative 'entities'

module Engine
  module Game
    module G18NewEnglandNorth
      class Game < G18NewEngland::Game
        include_meta(G18NewEnglandNorth::Meta)
        include G18NewEnglandNorth::Entities
        include G18NewEnglandNorth::Map

        register_colors(black: '#16190e',
                        blue: '#0189d1',
                        brown: '#7b352a',
                        gray: '#7c7b8c',
                        green: '#3c7b5c',
                        olive: '#808000',
                        lightGreen: '#009a54ff',
                        lightBlue: '#4cb5d2',
                        lightishBlue: '#0097df',
                        teal: '#009595',
                        orange: '#d75500',
                        magenta: '#d30869',
                        purple: '#772282',
                        red: '#ef4223',
                        rose: '#b7274c',
                        coral: '#f3716d',
                        white: '#fff36b',
                        navy: '#000080',
                        cream: '#fffdd0',
                        yellow: '#ffdea8')

        CURRENCY_FORMAT_STR = '$%d'
        BANK_CASH = 6_000
        CERT_LIMIT = { 2 => 16, 3 => 12, 4 => 10 }.freeze
        STARTING_CASH = { 2 => 520, 3 => 400, 4 => 280 }.freeze
        CAPITALIZATION = :incremental
        MUST_SELL_IN_BLOCKS = false

        MARKET = [
          %w[35
             40
             45
             50
             55
             60
             65
             70
             80
             90
             100p
             110p
             120p
             130p
             145p
             160p
             180p
             200p
             220
             240
             260
             280
             310
             340
             380
             420
             460
             500],
           ].freeze

        PHASES = [
          {
            name: '2',
            train_limit: '4',
            tiles: %i[yellow],
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
            train_limit: 3,
            tiles: %i[yellow green],
            operating_rounds: 2,
          },
          {
            name: '5',
            on: '5E',
            train_limit: 3,
            tiles: %i[yellow green brown],
            operating_rounds: 2,
          },
          {
            name: '6',
            on: '6E',
            train_limit: 2,
            tiles: %i[yellow green brown],
            operating_rounds: 2,
          },
          {
            name: '8',
            on: '8E',
            train_limit: 2,
            tiles: %i[yellow green brown gray],
            operating_rounds: 2,
          },
          #    status: ['can_buy_companies'],
          #    status: %w[can_buy_companies export_train],
          #    status: %w[can_buy_companies export_train],
        ].freeze

        TRAINS = [
          {
            name: '2',
            distance: 2,
            price: 100,
            rusts_on: '4',
            num: 10,
          },
          {
            name: '3',
            distance: 3,
            price: 180,
            rusts_on: '6E',
            num: 7,
          },
          {
            name: '4',
            distance: 4,
            price: 300,
            rusts_on: '8E',
            num: 1,
          },
          {
            name: '5E',
            distance: 5,
            price: 500,
            num: 4,
          },
          {
            name: '6E',
            distance: 6,
            price: 600,
            num: 3,
          },
          {
            name: '8E',
            distance: 8,
            price: 800,
            num: 20,
          },
        ].freeze

        HOME_TOKEN_TIMING = :float
        MUST_BUY_TRAIN = :always # mostly true, needs custom code
        SELL_MOVEMENT = :down_block_pres
        SELL_BUY_ORDER = :sell_buy

        # Two lays or one upgrade
        TILE_LAYS = [
          { lay: true, upgrade: true },
          { lay: true, upgrade: :not_if_upgraded },
        ].freeze
      end
    end
  end
end
