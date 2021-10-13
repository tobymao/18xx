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

        CORPORATIONS = [
          {
            float_percent: 50,
            sym: 'PRR',
            name: 'Pennsylvania Railroad',
            logo: '18_chesapeake/PRR',
            tokens: [0, 40, 60, 80],
            coordinates: 'F2',
            color: '#237333',
            reservation_color: nil,
          },
          {
            float_percent: 50,
            sym: 'PLE',
            name: 'Pittsburgh and Lake Erie Railroad',
            logo: '18_chesapeake/PLE',
            tokens: [0, 40, 60],
            coordinates: 'A3',
            color: :black,
            reservation_color: nil,
          },
          {
            float_percent: 50,
            sym: 'SRR',
            name: 'Strasburg Rail Road',
            logo: '18_chesapeake/SRR',
            tokens: [0, 40],
            coordinates: 'H4',
            color: '#d81e3e',
            reservation_color: nil,
          },
          {
            float_percent: 50,
            sym: 'B&O',
            name: 'Baltimore & Ohio Railroad',
            logo: '18_chesapeake/BO',
            tokens: [0, 40, 60],
            coordinates: 'H6',
            city: 0,
            color: '#0189d1',
            reservation_color: nil,
          },
          {
            float_percent: 50,
            sym: 'C&O',
            name: 'Chesapeake & Ohio Railroad',
            logo: '18_chesapeake/CO',
            tokens: [0, 40, 60, 80],
            coordinates: 'G13',
            color: '#a2dced',
            text_color: 'black',
            reservation_color: nil,
          },
          {
            float_percent: 50,
            sym: 'LV',
            name: 'Lehigh Valley Railroad',
            logo: '18_chesapeake/LV',
            tokens: [0, 40],
            coordinates: 'J2',
            color: '#FFF500',
            text_color: 'black',
            reservation_color: nil,
          },
          {
            float_percent: 50,
            sym: 'C&A',
            name: 'Camden & Amboy Railroad',
            logo: '18_chesapeake/CA',
            tokens: [0, 40],
            coordinates: 'J6',
            color: '#f48221',
            reservation_color: nil,
          },
          {
            float_percent: 50,
            sym: 'N&W',
            name: 'Norfolk & Western Railway',
            logo: '18_chesapeake/NW',
            tokens: [0, 40, 60],
            coordinates: 'C13',
            color: '#7b352a',
            reservation_color: nil,
          },
        ].freeze

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
