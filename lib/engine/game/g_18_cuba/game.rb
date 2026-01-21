# frozen_string_literal: true

require_relative 'entities'
require_relative 'map'
require_relative 'meta'
require_relative '../base'
require_relative '../double_sided_tiles'

module Engine
  module Game
    module G18Cuba
      class Game < Game::Base
        include_meta(G18Cuba::Meta)
        include Entities
        include Map

        include DoubleSidedTiles

        register_colors(red: '#d1232a',
                        orange: '#f58121',
                        black: '#110a0c',
                        blue: '#025aaa',
                        lightBlue: '#8dd7f6',
                        yellow: '#ffe600',
                        green: '#32763f',
                        brightGreen: '#6ec037')
        TRACK_RESTRICTION = :permissive
        CURRENCY_FORMAT_STR = '$%s'

        COMPANY_CONCESSION_PREFIX = 'C'
        COMPANY_COMMISIONER_PREFIX = 'M'

        BANK_CASH = 10_000

        CERT_LIMIT = { 2 => 35, 3 => 30, 4 => 20, 5 => 17, 6 => 15 }.freeze

        STARTING_CASH = { 2 => 950, 3 => 900, 4 => 680, 5 => 650, 6 => 650 }.freeze

        MARKET = [
          %w[50 55 60 65 70p 75p 80p 85p 90p 95p 100p 105 110 115 120 126 192 198 144
             151 158 172 180 188 196 204 013 222 231 240 250 260 275 290 300],
        ].freeze

        TRAIN_FOR_PLAYER_COUNT = {
          2 => { '2': 5, '3': 4, '4': 2, '5': 3, '6': 3, '8': 4, '2n': 7, '3n': 5, '4n': 4, '5n': 5 },
          3 => { '2': 7, '3': 5, '4': 3, '5': 3, '6': 3, '8': 6, '2n': 5, '3n': 5, '4n': 3, '5n': 4 },
          4 => { '2': 9, '3': 7, '4': 4, '5': 3, '6': 3, '8': 8, '2n': 7, '3n': 6, '4n': 4, '5n': 5 },
          5 => { '2': 10, '3': 8, '4': 5, '5': 3, '6': 3, '8': 10, '2n': 9, '3n': 7, '4n': 5, '5n': 6 },
          6 => { '2': 10, '3': 9, '4': 5, '5': 3, '6': 3, '8': 12, '2n': 10, '3n': 8, '4n': 6, '5n': 7 },
        }.freeze

        PHASES = [{ name: '2', train_limit: 4, tiles: [:yellow], operating_rounds: 1 },
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
                    on: '5',
                    train_limit: 2,
                    tiles: %i[yellow green brown],
                    operating_rounds: 3,
                  },
                  {
                    name: '6',
                    on: '6',
                    train_limit: 2,
                    tiles: %i[yellow green brown],
                    operating_rounds: 3,
                  },
                  {
                    name: '8',
                    on: '8',
                    train_limit: 2,
                    tiles: %i[yellow green brown gray],
                    operating_rounds: 3,
                  }].freeze

        TRAINS = [
                  # Regular Trains
                  {
                    name: '2',
                    distance: 2,
                    price: 100,
                    track_type: :broad,
                    rusts_on: '4',
                  },
                  {
                    name: '3',
                    distance: 3,
                    price: 200,
                    track_type: :broad,
                    rusts_on: '6',
                    variants: [
                      {
                        name: '3+',
                        distance: 3,
                        track_type: :broad,
                        price: 230,
                      },
                    ],
                  },
                  {
                    name: '4',
                    distance: 4,
                    price: 300,
                    track_type: :broad,
                    rusts_on: '8',
                    variants: [
                      {
                        name: '4+',
                        distance: 4,
                        track_type: :broad,
                        price: 340,
                      },
                    ],
                  },
                  {
                    name: '5',
                    distance: 5,
                    price: 500,
                    track_type: :broad,
                    variants: [
                      {
                        name: '5+',
                        distance: 5,
                        track_type: :broad,
                        price: 550,
                      },
                    ],
                  },
                  {
                    name: '6',
                    distance: 6,
                    price: 600,
                    track_type: :broad,
                    variants: [
                      {
                        name: '6+',
                        distance: 6,
                        track_type: :broad,
                        price: 660,
                      },
                    ],
                  },
                  {
                    name: '8',
                    distance: 8,
                    price: 700,
                    track_type: :broad,
                    variants: [
                      {
                        name: '4D',
                        distance: 4,
                        track_type: :broad,
                        price: 800,
                      },
                    ],
                  },
                  # Narrow Gauge Trains
                  {
                    name: '2n',
                    distance: 2,
                    price: 80,
                    track_type: :narrow,
                    rusts_on: '4',
                  },
                  {
                    name: '3n',
                    distance: 3,
                    price: 160,
                    track_type: :narrow,
                    rusts_on: '6',
                  },
                  {
                    name: '4n',
                    distance: 4,
                    price: 260,
                    track_type: :narrow,
                  },
                  {
                    name: '5n',
                    distance: 5,
                    price: 380,
                    track_type: :narrow,
                  },
                  ].freeze

        def operating_round(round_num)
          Round::Operating.new(self, [
            Engine::Step::Bankrupt,
            Engine::Step::Exchange,
            Engine::Step::SpecialTrack,
            Engine::Step::SpecialToken,
            Engine::Step::BuyCompany,
            Engine::Step::HomeToken,
            Engine::Step::Track,
            Engine::Step::Token,
            Engine::Step::Route,
            Engine::Step::Dividend,
            Engine::Step::DiscardTrain,
            Engine::Step::BuyTrain,
            [Engine::Step::BuyCompany, { blocks: true }],
          ], round_num: round_num)
        end

        def init_stock_market
          StockMarket.new(self.class::MARKET, [], zigzag: :flip)
        end

        def multiple_buy_only_from_market?
          !optional_rules&.include?(:multiple_brown_from_ipo)
        end

        def num_trains(train)
          num_players = [@players.size, 2].max
          TRAIN_FOR_PLAYER_COUNT[num_players][train[:name].to_sym]
        end

        def company_header(company)
          company.id[0] == self.class::COMPANY_CONCESSION_PREFIX ? 'CONCESSION' : 'COMMISSIONER'
        end

        def setup
          super
          @tile_groups = init_tile_groups
          initialize_tile_opposites!
          @unused_tiles = []
        end

        def init_tile_groups
          self.class::TILE_GROUPS
        end
      end
    end
  end
end
