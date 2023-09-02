# frozen_string_literal: true

require_relative 'meta'
require_relative '../g_18_chesapeake/game'

module Engine
  module Game
    module G18ChesapeakeOffTheRails
      class Game < G18Chesapeake::Game
        include_meta(G18ChesapeakeOffTheRails::Meta)

        BANK_CASH = 12_000

        MARKET = [
          %w[76 82 90 100p 112 126 142 160 180 200 225 250 275 300e],
          %w[70 76 82 90p 100 112 126 142 160 180 200 220 240 260],
          %w[65 70 76 82p 90 100 111 125 140 155 170 185],
          %w[60y 66 71 76p 82 90 100 110 120 130],
          %w[55y 62 67 71p 76 82 90 100],
          %w[50y 58y 65 67p 71 75 80],
          %w[45o 54y 63 67 69 70],
          %w[40o 50y 60y 67 68],
          %w[30b 40o 50y 60y],
          %w[20b 30b 40o 50y],
          %w[10b 20b 30b 40o],
        ].freeze

        TRAINS = [
          {
            name: '2',
            distance: 2,
            price: 80,
            rusts_on: '4',
            num: 5,
          },
          {
            name: '3',
            distance: 3,
            price: 180,
            rusts_on: '6',
            num: 4,
          },
          {
            name: '4',
            distance: 4,
            price: 300,
            rusts_on: 'D',
            num: 3,
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
            num: 2,
          },
          {
            name: 'D',
            distance: 999,
            price: 1100,
            num: 20,
            available_on: '6',
            discount: { '4' => 300, '5' => 300, '6' => 300 },
          },
        ].freeze

        def corporation_opts
          { float_percent: 50 }
        end

        SELL_BUY_ORDER = :sell_buy_sell

        GAME_END_CHECK = { bankrupt: :immediate, stock_market: :current_round, bank: :full_or }.freeze

        def or_set_finished; end

        def timeline
          []
        end
      end
    end
  end
end
