# frozen_string_literal: true

require_relative 'entities'
require_relative 'map'
require_relative 'meta'
require_relative '../base'

module Engine
  module Game
    module G1850Jr
      class Game < Game::Base
        include_meta(G1850Jr::Meta)
        include Entities
        include Map

        register_colors(orange: '#f58121',
                        black: '#110a0c',
                        blue: '#025aaa',
                        yellow: '#ffe600',
                        green: '#32763f')
        TRACK_RESTRICTION = :permissive
        SELL_BUY_ORDER = :sell_buy_sell
        TILE_RESERVATION_BLOCKS_OTHERS = :always
        CURRENCY_FORMAT_STR = 'L.%s'

        BANK_CASH = 6000

        CERT_LIMIT = { 3 => 10, 4 => 8, 5 => 6, 6 => 5 }.freeze

        STARTING_CASH = { 3 => 680, 4 => 510, 5 => 408, 6 => 340 }.freeze

        MARKET = [
          %w[60y 67 71 76 82 90 100p 112 126 142 160 180 200 225 250 275 300 325 350],
          %w[53y 60y 66 70 76 82 90p 100 112 126 142 160 180 200 220 240 260 280 300],
          %w[46y 55y 60y 65 70 76 82p 90 100 111 125 140 155 170 185 200],
          %w[39o 48y 54y 60y 66 71 76p 82 90 100 110 120 130],
          %w[32o 41o 48y 55y 62 67 71p 76 82 90 100],
          %w[25b 34o 42o 50y 58y 65 67p 71 75 80],
          %w[18b 27b 36o 45o 54y 63 67 69 70],
          %w[10b 20b 30b 40o 50y 60y 67 68],
          ['', '10b', '20b', '30b', '40o', '50y', '60y'],
          ['', '', '10b', '20b', '30b', '40o', '50y'],
          ['', '', '', '10b', '20b', '30b', '40o'],
        ].freeze

        PHASES = [{
          name: '2',
          train_limit: 4,
          tiles: [:yellow],
          operating_rounds: 1,
          status: ['limited_train_buy'],
        },
                  {
                    name: '3',
                    on: '3',
                    train_limit: 4,
                    tiles: %i[yellow green],
                    operating_rounds: 2,
                    status: %w[can_buy_companies limited_train_buy],
                  },
                  {
                    name: '4',
                    on: '4',
                    train_limit: 3,
                    tiles: %i[yellow green],
                    operating_rounds: 2,
                    status: %w[can_buy_companies limited_train_buy],
                  },
                  {
                    name: '5',
                    on: '5',
                    train_limit: 2,
                    tiles: %i[yellow green brown],
                    operating_rounds: 3,
                    status: ['limited_train_buy'],
                  },
                  {
                    name: '6',
                    on: '6',
                    train_limit: 2,
                    tiles: %i[yellow green brown],
                    operating_rounds: 3,
                    status: ['limited_train_buy'],
                  },
                  {
                    name: 'D',
                    on: 'D',
                    train_limit: 2,
                    tiles: %i[yellow green brown],
                    operating_rounds: 3,
                    status: ['limited_train_buy'],
                  }].freeze

        TRAINS = [{ name: '2', distance: 2, price: 80, rusts_on: '4', num: 3 },
                  { name: '3', distance: 3, price: 180, rusts_on: '6', num: 3 },
                  { name: '4', distance: 4, price: 300, rusts_on: 'D', num: 2 },
                  {
                    name: '5',
                    distance: 5,
                    price: 450,
                    num: 1,
                    events: [{ 'type' => 'close_companies' }],
                  },
                  { name: '6', distance: 6, price: 630, num: 1 },
                  {
                    name: 'D',
                    distance: 999,
                    price: 1100,
                    num: 4,
                    discount: { '4' => 300, '5' => 300, '6' => 300 },
                  }].freeze

        def operating_round(round_num)
          Round::Operating.new(self, [
            Engine::Step::Bankrupt,
            Engine::Step::Exchange,
            Engine::Step::SpecialTrack,
            Engine::Step::BuyCompany,
            Engine::Step::HomeToken,
            Engine::Step::Track,
            Engine::Step::Token,
            Engine::Step::Route,
            Engine::Step::Dividend,
            Engine::Step::DiscardTrain,
            Engine::Step::SingleDepotTrainBuy,
            [Engine::Step::BuyCompany, { blocks: true }],
          ], round_num: round_num)
        end

        STATUS_TEXT = Base::STATUS_TEXT.merge(Engine::Step::SingleDepotTrainBuy::STATUS_TEXT).freeze

        def revenue_for(route, stops)
          revenue = super

          port = stops.find { |stop| stop.groups.include?('port') }

          if port
            raise GameError, "#{port.tile.location_name} must contain 2 other stops" if stops.size < 3

            revenue += (revenue / 2).floor(-1)
          end

          revenue
        end
      end
    end
  end
end
