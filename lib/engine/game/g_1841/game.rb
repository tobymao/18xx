# frozen_string_literal: true

require_relative '../base'
require_relative 'meta'
require_relative 'entities'
require_relative 'map'

module Engine
  module Game
    module G1841
      class Game < Game::Base
        include_meta(G1841::Meta)
        include Entities
        include Map

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

        CURRENCY_FORMAT_STR = 'L.%d'
        BANK_CASH = 14_400
        CERT_LIMIT = { 3 => 21, 4 => 16, 5 => 13, 6 => 11, 7 => 10, 8 => 9 }.freeze
        STARTING_CASH = { 3 => 1120, 4 => 840, 5 => 672, 7 => 480, 8 => 420 }.freeze
        CAPITALIZATION = :incremental
        MUST_SELL_IN_BLOCKS = false
        SELL_MOVEMENT = :down_share
        SOLD_OUT_INCREASE = true
        POOL_SHARE_DROP = :one
        TRACK_RESTRICTION = :semi_restrictive

        MARKET = [
          %w[72 83 95 107 120 133 147 164 182 202 224 248 276 306 340p 377 419 465 516],
          %w[63 72 82 93 104 116 128 142 158 175 195 216p 240 266 295 328 365 404 449],
          %w[57 66 75 84 95 105 117 129 144p 159 177 196 218 242 269 298 331 367 408],
          %w[54 62 71 80 90 100p 111 123 137 152 169 187 208 230 256 284],
          %w[52 59 68p 77 86 95 106 117 130 145 160 178 198 219],
          %w[47 54 62 70 78 87 96 107 118 131 146 162 180],
          %w[41 47 54 61 68 75 84 93 103 114 127 141],
          %w[34 39 45 50 57 63 70 77 86 95 106],
          %w[27 31 36 40 45 50 56 62 69 76],
          %w[21 24 27 31 35 39 43 48 53],
          %w[16 18 20 23 26 29 32 35],
          %w[11 13 15 16 18 20 23],
          %w[8 9 10 11 13 14],
        ].freeze

        MARKET_TEXT = {
          par: 'Par value',
          no_cert_limit: 'Corporation shares do not count towards cert limit',
          unlimited: 'Corporation shares can be held above 60%',
          multiple_buy: 'Can buy more than one share in the corporation per turn',
          close: 'Corporation closes',
          endgame: 'End game trigger',
          liquidation: 'Liquidation',
          repar: 'Minor company value',
          ignore_one_sale: 'Ignore first share sold when moving price',
        }.freeze

        PHASES = [
          {
            name: '2',
            train_limit: { minor: 2, major: 4 },
            tiles: %i[yellow],
            operating_rounds: 1,
            status: %w[no_border_crossing one_tile_per_base],
          },
          {
            name: '3',
            on: '3',
            train_limit: { minor: 2, major: 4 },
            tiles: %i[yellow green],
            operating_rounds: 2,
            status: %w[one_tile_per_base_max_2 start_non_hist],
          },
          {
            name: '4',
            on: '4',
            train_limit: { minor: 2, major: 3 },
            tiles: %i[yellow green],
            operating_rounds: 2,
            status: %w[one_tile_per_base_max_2 start_non_hist concessions_removed],
          },
          {
            name: '5',
            on: '5',
            train_limit: { minor: 2, major: 2 },
            tiles: %i[yellow green brown],
            operating_rounds: 3,
            status: %w[one_tile_per_or start_non_hist],
          },
          {
            name: '6',
            on: '6',
            train_limit: { minor: 1, major: 2 },
            tiles: %i[yellow green brown],
            operating_rounds: 3,
            status: %w[one_tile_per_or start_non_hist],
          },
          {
            name: '7',
            on: '7',
            train_limit: { minor: 1, major: 2 },
            tiles: %i[yellow green brown],
            operating_rounds: 3,
            status: %w[one_tile_per_or start_non_hist],
          },
          {
            name: '8',
            on: '8',
            train_limit: { minor: 1, major: 2 },
            tiles: %i[yellow green brown],
            operating_rounds: 3,
            status: %w[one_tile_per_or start_non_hist],
          },
        ].freeze

        TRAINS = [
          {
            name: '2',
            distance: [{ 'nodes' => %w[city offboard pass], 'pay' => 2, 'visit' => 2 },
                       { 'nodes' => ['town'], 'pay' => 99, 'visit' => 99 }],
            price: 100,
            rusts_on: '4',
            num: 8,
          },
          {
            name: '3',
            distance: [{ 'nodes' => %w[city offboard pass], 'pay' => 3, 'visit' => 3 },
                       { 'nodes' => ['town'], 'pay' => 99, 'visit' => 99 }],
            price: 200,
            rusts_on: '5',
            num: 6,
          },
          {
            name: '4',
            distance: [{ 'nodes' => %w[city offboard pass], 'pay' => 4, 'visit' => 4 },
                       { 'nodes' => ['town'], 'pay' => 99, 'visit' => 99 }],
            price: 350,
            rusts_on: '7',
            num: 4,
          },
          {
            name: '5',
            distance: [{ 'nodes' => %w[city offboard pass], 'pay' => 5, 'visit' => 5 },
                       { 'nodes' => ['town'], 'pay' => 99, 'visit' => 99 }],
            price: 550,
            num: 2,
          },
          {
            name: '6',
            distance: [{ 'nodes' => %w[city offboard pass], 'pay' => 6, 'visit' => 6 },
                       { 'nodes' => ['town'], 'pay' => 99, 'visit' => 99 }],
            price: 800,
            num: 2,
          },
          {
            name: '7',
            distance: [{ 'nodes' => %w[city offboard pass], 'pay' => 7, 'visit' => 7 },
                       { 'nodes' => ['town'], 'pay' => 99, 'visit' => 99 }],
            price: 110,
            num: 2,
          },
          {
            name: '8',
            distance: [{ 'nodes' => %w[city offboard], 'pay' => 8, 'visit' => 8 },
                       { 'nodes' => %w[town pass], 'pay' => 99, 'visit' => 99 }],
            price: 1450,
            num: 7,
          },
        ].freeze

        HOME_TOKEN_TIMING = :start
        SELL_BUY_ORDER = :sell_buy
        BANKRUPTCY_ENDS_GAME_AFTER = :all_but_one

        GAME_END_CHECK = { bankrupt: :immediate, stock_market: :immediate, bank: :current_or }.freeze

        # Per base (needs special code in track step)
        TILE_LAYS = [
          { lay: true, upgrade: true, cost: 0 },
        ].freeze

        def transfer_share(share, new_owner)
          corp = share.corporation
          corp.share_holders[share.owner] -= share.percent
          corp.share_holders[new_owner] += share.percent
          share.owner.shares_by_corporation[corp].delete(share)
          new_owner.shares_by_corporation[corp] << share
          share.owner = new_owner
        end

        # FIXME
        def ipo_name(_corp)
          'Treasury'
        end

        # FIXME
        def corporation_available?(corp)
          super
        end

        # FIXME
        def can_par?(corporation, entity)
          return false unless corporation_available?(corporation)

          super
        end
      end
    end
  end
end
