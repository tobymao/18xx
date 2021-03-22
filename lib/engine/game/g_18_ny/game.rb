# frozen_string_literal: true

require_relative 'map'
require_relative 'meta'
require_relative 'entities'

module Engine
  module Game
    module G18NY
      class Game < Game::Base
        include_meta(G18NY::Meta)
        include G18NY::Entities
        include G18NY::Map

        CAPITALIZATION = :incremental
        HOME_TOKEN_TIMING = :operate

        CURRENCY_FORMAT_STR = '$%d'

        BANK_CASH = 12000

        CERT_LIMIT = { 2 => 28, 3 => 20, 4 => 16, 5 => 13, 6 => 11 }.freeze

        STARTING_CASH = { 2 => 900, 3 => 600, 4 => 450, 5 => 360, 6 => 300 }.freeze
        
        SELL_BUY_ORDER = :sell_buy

        MARKET = [
          ['70', '75', '80', '90', '100p', '110', '125', '150', '175', '200', '230', '260', '300', '350', '400', '450', '500'],
          ['65', '70', '75', '80x', '90p', '100', '110', '125', '150', '175', '200', '230', '260', '300', '350', '400', '450'],
          ['60', '65', '70', '75x', '80p', '90', '100', '110', '125', '150', '175', '200', '230', '260', '300', '350', '400'],
          ['55', '60', '65', '70x', '75p', '80', '90', '100', '110', '125', '150', '175'],
          ['50', '55', '60', '65x', '70p', '75', '80', '90', '100', '110', '125'],
          ['40', '50', '55', '60x', '65p', '70', '75', '80', '90', '100'],
          ['30', '40', '50', '55x', '60', '65', '70', '75', '80'],
          ['20', '30', '40', '50x', '55', '60', '65', '70'],
          ['10', '20', '30', '40', '50', '55', '60'],
          ['0c', '10', '20', '30', '40', '50'],
          ['0c', '0c', '10', '20', '30'],
        ].freeze

        MARKET_TEXT = Base::MARKET_TEXT.merge(par_1: 'Minor Corporation Par',
                                              par: 'Major Corporation Par')
        STOCKMARKET_COLORS = Base::STOCKMARKET_COLORS.merge(par_1: :gray, par: :red).freeze

        PHASES = [
          {
            name: '2H',
            train_limit: { minor: 2, major: 4 },
            tiles: [:yellow],
            operating_rounds: 1,
            status: %w[float_20],
          },
          {
            name: '4H',
            on: '4H',
            train_limit: { minor: 2, major: 4 },
            tiles: %i[yellow green],
            operating_rounds: 2,
            status: %w[float_30 can_buy_companies],
          },
          {
            name: '6H',
            on: '6H',
            train_limit: { minor: 1, major: 3 },
            tiles: %i[yellow green],
            operating_rounds: 2,
            status: %w[float_40 can_buy_companies],
          },
          {
            name: '12H',
            on: '12H',
            train_limit: { minor: 1, major: 2 },
            tiles: %i[yellow green brown],
            operating_rounds: 3,
            status: %w[float_50],
          },
          {
            name: '5DE',
            on: '5DE',
            train_limit: { major: 2 },
            tiles: %i[yellow green brown],
            operating_rounds: 3,
            status: %w[fullcap float_60],
          },
          {
            name: 'D',
            on: 'D',
            train_limit: { major: 2 },
            tiles: %i[yellow green brown gray],
            operating_rounds: 3,
            status: %w[fullcap float_60],
          },
        ].freeze

        TRAINS = [{ name: '2H', num: 11, distance: 2, price: 100, rusts_on: '6H' },
                  { name: '4H', num: 6, distance: 4, price: 200, rusts_on: '5DE' },
                  { name: '6H', num: 4, distance: 6, price: 300, rusts_on: 'D' },
                  { name: '12H', num: 2, distance: 12, price: 600, events: [{ type: 'remove_corporations' }, { type: 'nyc_formation' }] },
                  { name: '12H', num: 1, distance: 12, price: 600, events: [{ type: 'capitalization_round' }] },
                  { name: '5DE', num: 2, distance: [{ nodes: %w[city offboard town], pay: 5, visit: 99, multiplier: 2 }], price: 800 },
                  { name: 'D', num: 20, distance: 99, price: 1000 },].freeze

        def stock_round
          Round::Stock.new(self, [
            Engine::Step::BuySellParShares,
          ])
        end
      end
    end
  end
end
