# frozen_string_literal: true

require_relative '../base'
require_relative 'meta'
require_relative 'entities'
require_relative 'map'

module Engine
  module Game
    module G22Mars
      class Game < Game::Base
        include_meta(G22Mars::Meta)
        include Entities
        include Map

        CURRENCY_FORMAT_STR = '%sc'
        BANK_CASH = 9999

        STARTING_CASH = { 3 => 300, 4 => 225, 5 => 180 }.freeze

        MARKET = [
          %w[90 100 110 120 130 145 160 175 195 215 235 255 275 300e],
          %w[80 90p 100 110 120 130 145 160 175 195 215 235 255],
          %w[70 80p 90 100 110 120 130 145 160 175 195 215],
          %w[60 70p 80 90 100 110 120 130 145 160 175],
          %w[50 60p 70 80 90 100 110 120 130 145],
          %w[45 50p 55 65 75 85 95 105],
          %w[40 45 50 55 65 75],
          %w[35r 40r 45r 50r],
          %w[0c],
        ].freeze

        CERT_LIMIT = { 2 => 12, 3 => 12, 4 => 9, 5 => 7 }.freeze

        PHASES = [
          {
            name: '2',
            train_limit: 3,
            tiles: [:yellow],
            operating_rounds: 2,
            status: [],
          },
          {
            name: '3',
            on: '3',
            train_limit: 3,
            tiles: %i[yellow green],
            operating_rounds: 2,
            status: [],
          },
          {
            name: '4',
            on: '4',
            train_limit: 3,
            tiles: %i[yellow green],
            operating_rounds: 2,
            status: [],
          },
          {
            name: '5',
            on: '5',
            train_limit: 3,
            tiles: %i[yellow green brown],
            operating_rounds: 2,
            status: [],
          },
          {
            name: '7',
            on: '6+S',
            train_limit: 3,
            tiles: %i[yellow green brown gray],
            operating_rounds: 2,
            status: [],
          },
          {
            name: '8',
            on: '6+SS',
            train_limit: 3,
            tiles: %i[yellow green brown gray black],
            operating_rounds: 2,
            status: [],
          },
        ].freeze

        TRAINS = [
          {
            name: '2',
            distance: 2,
            price: 100,
            rusts_on: '4',
            num: 6,
          },
          {
            name: '3',
            distance: 3,
            price: 17,
            rusts_on: '5',
            num: 4,
          },
          {
            name: '4',
            distance: 4,
            price: 250,
            rusts_on: '6+S',
            num: 3,
          },
          {
            name: '5',
            distance: 5,
            price: 340,
            rusts_on: '6+SS',
            num: 3,
          },
          {
            name: '6+S',
            distance: 6,
            price: 440,
            rusts_on: '4',
            num: 4,
          },
          {
            name: '6+SS',
            distance: 6,
            price: 560,
            rusts_on: '4',
            num: 6,
            discount: { '5' => 400 },
          },
        ].freeze

        CAPITALIZATION = :incremental

        SELL_BUY_ORDER = :sell_buy
        SELL_MOVEMENT = :down_share
        HOME_TOKEN_TIMING = :float

        CLOSED_CORP_RESERVATIONS_REMOVED = false
      end
    end
  end
end
