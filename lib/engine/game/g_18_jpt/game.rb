# frozen_string_literal: true

require_relative 'meta'
require_relative '../base'
require_relative 'entities'
require_relative 'map'

module Engine
  module Game
    module G18JPT
      class Game < Game::Base
        include_meta(G18JPT::Meta)
        include Entities
        include Map

        register_colors(lightGreen: '#84BF48',
                        darkgreen: '#00984C',
                        grey: '#949595',
                        red: '#D72A33',
                        lightBlue: '#00A1D8',
                        darkBlue: '#292A74',
                        yellow: '#FFF234',
                        orange: '#EA8D3B',
                        pink: '#E591B4',
                        brown: '#5E4E35',
                        purple: '#572979')

        CURRENCY_FORMAT_STR = '¥%d'

        BANK_CASH = 12_000

        CERT_LIMIT = { 2 => 28, 3 => 20, 4 => 16, 5 => 13, 6 => 11, 7 => 11 }.freeze

        STARTING_CASH = { 2 => 1200, 3 => 800, 4 => 600, 5 => 480, 6 => 400, 7 => 400 }.freeze

        MARKET = [
          %w[75 80 90 100p 110 120 140 170 200 230 260 290 320 350 380 420 460],
          %w[70 75 80 90p 100 110 120 140 170 200 230 260 290 320 350 380 420],
          %w[65 70 75 80p 90 100 110 120 140 170 200 230],
          %w[60y 65 70 75p 80 90 100 110 120 140],
          %w[55y 60 65 70p 75 80 90 100],
          %w[50y 55y 60 65p 70 75 80],
          %w[45y 50y 55 60 65 70],
          %w[40y 45y 50y 55 60],
          %w[30y 40y 45y 50],
          %w[20y 30y 40y 45y],
          %w[10y 20y 30y 40y],
        ].freeze

        PHASES = [{ name: '2', train_limit: 4, tiles: [:yellow], operating_rounds: 1 },
                  {
                    name: '3',
                    on: '3',
                    train_limit: 4,
                    tiles: %i[yellow green],
                    operating_rounds: 2,
                    status: ['can_buy_companies'],
                  },
                  {
                    name: '4',
                    on: '4',
                    train_limit: 3,
                    tiles: %i[yellow green],
                    operating_rounds: 2,
                    status: ['can_buy_companies'],
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
                    name: 'D',
                    on: 'D',
                    train_limit: 2,
                    tiles: %i[yellow green brown],
                    operating_rounds: 3,
                  }].freeze

        TRAINS = [
          {
            name: '2',
            distance: 2,
            price: 80,
            rusts_on: '4',
            num: 7,
          },
          {
            name: '3',
            distance: 3,
            price: 180,
            rusts_on: '6',
            num: 7,
          },
          {
            name: '4',
            distance: 4,
            price: 300,
            rusts_on: 'D',
            num: 4,
          },
          {
            name: '5',
            distance: 5,
            price: 500,
            num: 2,
            events: [{ 'type' => 'close_companies' }],
          },
          {
            name: '6',
            distance: 6,
            price: 630,
            num: 7,
          },
          {
            name: 'D',
            distance: 999,
            price: 900,
            num: 99,
            available_on: '6',
          },
        ].freeze
      end
    end
  end
end
