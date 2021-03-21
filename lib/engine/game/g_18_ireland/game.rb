# frozen_string_literal: true

require_relative '../g_1849/map'
require_relative 'meta'
require_relative 'entities'

module Engine
  module Game
    module G18Ireland
      class Game < Game::Base
        include_meta(G18Ireland::Meta)
        include G18Ireland::Entities
        include G1849::Map

        CAPITALIZATION = :incremental
        HOME_TOKEN_TIMING = :float

        CURRENCY_FORMAT_STR = '£%d'

        BANK_CASH = 4000

        CERT_LIMIT = { 3 => 16, 4 => 12, 5 => 10, 6 => 8 }.freeze

        STARTING_CASH = { 3 => 330, 4 => 250, 5 => 200, 6 => 160 }.freeze

        MARKET = [
          ['', '62', '68', '76', '84', '92', '100p', '110', '122', '134', '148', '170', '196', '225', '260e'],
          ['', '58', '64', '70', '78', '85p', '94', '102', '112', '124', '136', '150', '172', '198'],
          ['', '55', '60', '65', '70p', '78', '86', '95', '104', '114', '125', '138'],
          ['', '50', '55', '60p', '66', '72', '80', '88', '96', '106'],
          ['', '38y', '50p', '55', '60', '66', '72', '80'],
          ['', '30y', '38y', '50', '55', '60'],
          ['', '24y', '30y', '38y', '50'],
          %w[0c 20y 24y 30y 38y],
        ].freeze

        # @todo: these are wrong
        PHASES = [
          {
            name: '4H',
            train_limit: 4,
            tiles: [:yellow],
            operating_rounds: 1,
            status: ['gray_uses_white'],
          },
          {
            name: '6H',
            on: '6H',
            train_limit: 4,
            tiles: %i[yellow green],
            operating_rounds: 2,
            status: %w[gray_uses_white can_buy_companies],
          },
          {
            name: '8H',
            on: '8H',
            train_limit: 3,
            tiles: %i[yellow green],
            operating_rounds: 2,
            status: %w[gray_uses_gray can_buy_companies],
          },
          {
            name: '10H',
            on: '10H',
            train_limit: 2,
            tiles: %i[yellow green brown],
            operating_rounds: 3,
            status: %w[gray_uses_gray can_buy_companies],
          },
          {
            name: '12H',
            on: '12H',
            train_limit: 2,
            tiles: %i[yellow green brown],
            operating_rounds: 3,
            status: ['gray_uses_black'],
          },
          {
            name: '16H',
            on: '16H',
            train_limit: 2,
            tiles: %i[yellow green brown],
            operating_rounds: 3,
            status: %w[gray_uses_black blue_zone],
          },
        ].freeze

        # @todo: these are wrong
        TRAINS = [{ name: '2H', num: 7, distance: 2, price: 100, rusts_on: '6H' },
                  { name: '4H', num: 5, distance: 4, price: 100, rusts_on: '8H' },
                  {
                    name: '6H',
                    num: 2,
                    distance: 6,
                    price: 200,
                    rusts_on: '10H',
                  },
                  { name: '8H', num: 2, distance: 8, price: 350, rusts_on: '16H' },
                  {
                    name: '10H',
                    num: 2,
                    distance: 10,
                    price: 550,
                    events: [{ 'type' => 'brown_par' }],
                  },
                  {
                    name: '12H',
                    num: 1,
                    distance: 12,
                    price: 800,
                    events: [{ 'type' => 'close_companies' }, { 'type' => 'earthquake' }],
                  },
                  { name: '16H', num: 2, distance: 16, price: 1100 }].freeze

        def home_token_locations(corporation)
          hexes.select do |hex|
            hex.tile.cities.any? { |city| city.tokenable?(corporation, free: true) }
          end
        end

        def stock_round
          Round::Stock.new(self, [
            Engine::Step::DiscardTrain,
            Engine::Step::Exchange,
            Engine::Step::HomeToken,
            Engine::Step::BuySellParShares,
          ])
        end
      end
    end
  end
end
