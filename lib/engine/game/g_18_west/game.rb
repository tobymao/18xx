# frozen_string_literal: true

require_relative '../base'
require_relative 'entities'
require_relative 'map'
require_relative 'meta'

module Engine
  module Game
    module G18West
      class Game < Game::Base
        include_meta(G18West::Meta)
        include Entities
        include Map

        BANK_CASH = 12_000
        CURRENCY_FORMAT_STR = '$%d'
        STARTING_CASH = { 2 => 750, 3 => 500, 4 => 375, 5 => 300, 6 => 250 }.freeze
        CERT_LIMIT = { 2 => 28, 3 => 20, 4 => 16, 5 => 13, 6 => 11 }.freeze

        MARKET = [
          %w[0c 50 60 70p 80p 90p 100p 110 125 140 160 180 200 225 250 275 300 330 360 400],
        ].freeze

        PHASES = [
          {
            name: '2',
            train_limit: 4,
            tiles: [:yellow],
            operating_rounds: 2,
          },
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
            operating_rounds: 2,
          },
          {
            name: '6',
            on: '6',
            train_limit: 2,
            tiles: %i[yellow green brown],
            operating_rounds: 2,
          },
          {
            name: '4D',
            on: '4D',
            train_limit: 2,
            tiles: %i[yellow green brown gray],
            operating_rounds: 2,
          },
        ].freeze

        TRAINS = [
          {
            name: '2',
            distance: 2,
            price: 100,
            rusts_on: '4',
            num: 15,
          },
          {
            name: '3',
            distance: 3,
            price: 200,
            rusts_on: '6',
            num: 7,
          },
          {
            name: '4',
            distance: 4,
            price: 300,
            rusts_on: '4D',
            num: 5,
          },
          {
            name: '5',
            distance: 5,
            price: 500,
            events: [{ 'type' => 'close_companies' }],
            num: 3,
          },
          {
            name: '6',
            distance: 6,
            price: 600,
            num: 20,
          },
          {
            name: '4D',
            distance: 999,
            price: 1100,
            num: 20,
          },
        ].freeze

        def setup
          super
        end

        def stock_round; end

        def operating_round(round_num); end
      end
    end
  end
end
