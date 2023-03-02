# frozen_string_literal: true

require_relative 'meta'
require_relative '../base'

module Engine
  module Game
    module G18OE
      class Game < Game::Base
        include_meta(G18OE::Meta)

        MARKET = [
          ['', '110', '120p', '135', '150', '165', '180', '200', '225', '250', '280', '310', '350', '390', '440', '490', '550'],
          %w[90 100 110p 120 135 150 165 180 200 225 250 280 310 350 390 440 490],
          %w[80 90 100p 110 120 135 150 165 180 200 225 250 280 310],
          %w[75 80 90p 100 110 120 135 150 165 180 200],
          %w[70 75 80p 90 100 110 120 135 150],
          %w[65 70 75p 80 90 100 110],
          %w[60 65 70 75 80],
          %w[50 60 65 70],
        ].freeze
        CERT_LIMIT = { 3 => 48, 4 => 36, 5 => 29, 6 => 24, 7 => 20 }.freeze
        STARTING_CASH = { 3 => 1735, 4 => 1300, 5 => 1040, 6 => 870, 7 => 745 }.freeze
        BANK_CASH = 54_000
        CAPITALIZATION = :incremental
        SELL_BUY_ORDER = :sell_buy
        HOME_TOKEN_TIMING = :float

        PHASES = [
          {
            name: '2',
            train_limit: 3,
            tiles: [:yellow],
            operating_rounds: 2,
          },
        ].freeze

        TRAINS = [
          {
            name: '2+2',
            distance: [{ 'nodes' => ['town'], 'pay' => 2, 'visit' => 99 },
                       { 'nodes' => %w[city offboard town], 'pay' => 2, 'visit' => 2 }],
            price: 100,
            num: 5,
          },
        ].freeze

        TILES = {}.freeze
      end
    end
  end
end
