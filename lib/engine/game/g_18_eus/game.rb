# frozen_string_literal: true

require_relative '../base'
require_relative 'meta'
require_relative 'map'
# require_relative 'entities'

module Engine
  module Game
    module G18EUS
      class Game < Game::Base
        include_meta(G18EUS::Meta)
        include G18EUS::Entities
        include G18EUS::Map

        CERT_LIMIT = { 3 => 25, 4 => 20, 5 => 16 }.freeze

        STARTING_CASH = { 3 => 400, 4 => 300, 5 => 250 }.freeze

        MARKET = [
          %w[40 44 47 50p 53p 57p 61p 65p 70p 75p 80p 86p 92p 98p 105x 112x 120x 128x 137x 147x 157x 168z 180z 193z
             206z 221 236 253 270 289 310 331 354 379 406k 434k 465k 497k 532k 569k 609k 652k 700k 750e 800e],
        ].freeze

        MARKET_TEXT = Base::MARKET_TEXT.merge(
          par: 'Par available SR1+',
          par_1: 'Par available SR2+',
          par_2: 'Par available SR3+',
          ignore_sale_unless_pres: 'Stock price does not change on sale, unless by president',
          endgame: 'End game trigger'
        ).freeze

        STOCKMARKET_COLORS = Base::STOCKMARKET_COLORS.merge(
          par: :yellow,
          par_1: :lightblue,
          par_2: :blue,
          ignore_sale_unless_pres: :violet,
          endgame: :red
        ).freeze

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
            train_limit: 3,
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
            name: '7',
            on: '7',
            train_limit: 2,
            tiles: %i[yellow green brown gray],
            operating_rounds: 2,
          },
          {
            name: '8',
            on: '4D',
            train_limit: 2,
            tiles: %i[yellow green brown gray],
            operating_rounds: 2,
          },
        ].freeze

        TRAINS = [
          { name: '2', distance: 2, price: 100, rusts_on: '4', num: 20 },
          { name: '2+', distance: 2, price: 100, obsolete_on: '4', num: 10 },
          { name: '3', distance: 3, price: 250, rusts_on: '6', num: 10 },
          { name: '3+', distance: 3, price: 250, obsolete_on: '6', num: 1 },
          { name: '4', distance: 4, price: 400, rusts_on: '8', num: 5 },
          { name: '4+', distance: 4, price: 400, obsolete_on: '8', num: 1 },
          { name: '5', distance: 5, price: 600, num: 3 },
          { name: '6', distance: 6, price: 750, num: 3 },
          {
            name: '7',
            distance: 7,
            price: 850,
            num: 2,
            variants: [
              name: '3D',
              distance: [{ 'nodes' => %w[city offboard], 'pay' => 3, 'visit' => 3, 'multiplier' => 2 }],
              price: 850,
            ],
          },
          {
            name: '4D',
            distance: [{ 'nodes' => %w[city offboard], 'pay' => 4, 'visit' => 4, 'multiplier' => 2 }],
            price: 1100,
            num: 40,
            events: [{ 'type' => 'signal_end_game' }],
          },
        ].freeze

        def setup; end

        def init_stock_market
          StockMarket.new(self.class::MARKET, [], zigzag: true)
        end
      end
    end
  end
end
