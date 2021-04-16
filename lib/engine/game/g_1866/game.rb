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

        REGION_HEXES = {
          'GERMANY_BAVARIA' => %w[I17 I19 J16 J18 J20 K17 K19 K21],
          'GERMANY_HANNOVER' => %w[D18 E15 E17 E19 E21 F16 F18],
          'GERMANY_PRUSSIA' => %w[E23 E25 F20 F22 F24 F26 G15 G17 G19 G21 G23 G25 H14 H16 H18 H24 H26 I25],
          'GERMANY_SAXONY' => %w[H20 H22 I21 I23],
          'GERMANY_WURTTEMBURG' => %w[I13 I15 J14 K15],
          'ITALY_KGDM_2_SICILIES' => %w[S21 S23 T20 T22 T24 U21 V18 V20 W19],
          'ITALY_PAPAL_STATES' => %w[Q19 R18 R20 S19],
          'ITALY_SARDINIA' => %w[N12 O13 O15 S13 T12],
          'ITALY_TUSCANY' => %w[P16 Q17],
          'ITALY_LOM_VENETIA' => %w[M17 N14 N16 N18 N20 O17 P18],
          'LUXEMBOURG' => %w[I11],
          'ASTRO_HUNGARY' => %w[J22 J24 J26 K23 K25 L18 L20 L22 L24 L26 M19 M21 M23 M25 N22 N24 N26 O21 O23 O25
                                P22 P24 P26 Q23 Q25 R24],
          'BELGIUM' => %w[G9 G11 H10 H12],
          'FRANCE' => %w[H6 H8 I1 I3 I5 I7 I9 J0 J2 J4 J6 J8 J10 J12 K1 K3 K5 K7 K9 K11 K13 L2 L4 L6 L8 L10
                         M3 M5 M7 M9 M11 N2 N4 N6 N8 N10 O3 O5 O7 O9 O11 P6 P8 P10 P12 Q13],
          'GREAT_BRITAIN' => %w[A3 B2 B4 C3 C5 D2 D4 D6 E1 E3 E5 E7 F2 F4 F6 G1 G3 G5],
          'NETHERLANDS' => %w[E13 F10 F12 F14 G13],
          'SPAIN' => %w[O1 P0 P2 P4 Q1 Q3 Q5 R0 R2 S1],
          'SWITZERLAND' => %w[L12 L14 L16 M13 M15],
          'AFRICA' => %w[W9],
          'AMERICA' => %w[A11],
        }.freeze

        STOCK_TOKENS = {
          '3': 5,
          '4': 4,
          '5': 3,
          '6': 3,
          '7': 2,
        }.freeze

        def ipo_name(_entity = nil)
          'Treasury'
        end
      end
    end
  end
end
