# frozen_string_literal: true

require_relative 'entities'
require_relative 'map'
require_relative 'meta'
require_relative '../base'

module Engine
  module Game
    module G1826
      class Game < Game::Base
        include_meta(G1826::Meta)
        include Entities
        include Map

        register_colors(red: '#d1232a',
                        orange: '#f58121',
                        black: '#110a0c',
                        blue: '#025aaa',
                        lightBlue: '#8dd7f6',
                        lightishBlue: '#0097df',
                        yellow: '#ffe600',
                        green: '#32763f',
                        brightGreen: '#6ec037',
                        violet: '#601d39',
                        sand: '#c89432')
        TRACK_RESTRICTION = :permissive
        SELL_BUY_ORDER = :sell_buy
        TILE_RESERVATION_BLOCKS_OTHERS = :always
        HOME_TOKEN_TIMING = :float
        CURRENCY_FORMAT_STR = 'F%s'

        BANK_CASH = 12_000

        CERT_LIMIT = { 2 => 28, 3 => 20, 4 => 16, 5 => 13, 6 => 11 }.freeze

        STARTING_CASH = { 2 => 900, 3 => 600, 4 => 450, 5 => 360, 6 => 300 }.freeze

        MARKET = [
          %w[82 90 100 110p 122 135 150 165 180 200 220 245 270 300 330 360 400],
          %w[75 82 90 100p 110 122 135 150 165 180 200 220 245 270],
          %w[70 75 82 90p 100 110 122 135 150 165 180],
          %w[65 70 75 82p 90 100 110 122],
          %w[60y 65 70 75p 82 90],
          %w[50y 60y 65 70 75],
          %w[40y 50y 60y 65],
        ].freeze

        PHASES = [{ name: '2H', train_limit: { five_share: 2, ten_share: 4 }, tiles: [:yellow], operating_rounds: 1 },
                  {
                    name: '4H',
                    on: '4H',
                    train_limit: { five_share: 2, ten_share: 4 },
                    tiles: %i[yellow green],
                    operating_rounds: 2,
                  },
                  {
                    name: '6H',
                    on: '6H',
                    train_limit: { five_share: 1, ten_share: 3 },
                    tiles: %i[yellow green],
                    operating_rounds: 2,
                  },
                  {
                    name: '10H',
                    on: '10H',
                    train_limit: 2,
                    tiles: %i[yellow green brown],
                    operating_rounds: 3,
                  },
                  {
                    name: 'E',
                    on: 'E',
                    train_limit: 2,
                    tiles: %i[yellow green brown blue],
                    operating_rounds: 3,
                  },
                  {
                    name: 'TVG',
                    on: 'TVG',
                    train_limit: 2,
                    tiles: %i[yellow green brown blue gray],
                    operating_rounds: 3,
                  }].freeze

        TRAINS = [
                    { name: '2H', distance: 2, price: 100, rusts_on: '6H', num: 8 },
                    { name: '4H', distance: 4, price: 200, rusts_on: '10H', num: 7 },
                    { name: '6H', distance: 6, price: 300, rusts_on: 'E', num: 6 },
                    {
                      name: '10H',
                      distance: 10,
                      price: 600,
                      num: 5,
                      events: [{ 'type' => 'close_companies' }],
                    },
                    {
                      name: 'E',
                      # distance is equal to the number of E and TGV trains in play. The run is doubled until a TVG is purchased.
                      distance: [{ 'nodes' => %w[city offboard], 'pay' => 99, 'visit' => 99, 'multiplier' => 2 },
                                 { 'nodes' => ['town'], 'pay' => 0, 'visit' => 99 }],
                      price: 800,
                      num: 2,
                    },
                    {
                      name: 'TGV',
                      distance: [{ 'nodes' => %w[city offboard], 'pay' => 3, 'visit' => 99, 'multiplier' => 2 },
                                 { 'nodes' => ['town'], 'pay' => 0, 'visit' => 99 }],
                      price: 1000,
                      num: 20,
                      discount: { '4' => 300, '5' => 300, '6' => 300 },
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
      end
    end
  end
end
