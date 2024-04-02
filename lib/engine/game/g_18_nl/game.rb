# frozen_string_literal: true

require_relative 'entities'
require_relative 'map'
require_relative 'meta'
require_relative '../base'

module Engine
  module Game
    module G18NL
      class Game < Game::Base
        include_meta(G18NL::Meta)
        include Entities
        include Map

        TRACK_RESTRICTION = :permissive
        SELL_BUY_ORDER = :sell_buy_sell
        TILE_RESERVATION_BLOCKS_OTHERS = :always
        CURRENCY_FORMAT_STR = 'ƒ%s'

        BANK_CASH = 12_000

        CERT_LIMIT = { 3 => 22, 4 => 18, 5 => 14, 6 => 12 }.freeze

        STARTING_CASH = { 3 => 800, 4 => 600, 5 => 480, 6 => 400 }.freeze

        NZO_HOME_HEX = 'H13'

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

        TRAINS = [{ name: '2', distance: 2, price: 80, rusts_on: '4', num: 6 },
                  { name: '3', distance: 3, price: 180, rusts_on: '6', num: 5 },
                  { name: '4', distance: 4, price: 300, rusts_on: 'D', num: 5 },
                  {
                    name: '5',
                    distance: 5,
                    price: 450,
                    num: 3,
                    events: [{ 'type' => 'close_companies' }],
                  },
                  { name: '6', distance: 6, price: 630, num: 3 },
                  {
                    name: 'D',
                    distance: 999,
                    price: 1100,
                    num: 20,
                    available_on: '6',
                    discount: { '4' => 300, '5' => 300, '6' => 300 },
                  }].freeze

        def new_auction_round
          Engine::Round::Auction.new(self, [
            Engine::Step::CompanyPendingPar,
            G18NL::Step::WaterfallAuction,
          ])
        end

        def operating_round(round_num)
          Round::Operating.new(self, [
            Engine::Step::Bankrupt,
            Engine::Step::Exchange,
            Engine::Step::SpecialTrack,
            G18NL::Step::SpecialToken,
            Engine::Step::BuyCompany,
            Engine::Step::HomeToken,
            G18NL::Step::Track,
            G18NL::Step::Token,
            Engine::Step::Route,
            Engine::Step::Dividend,
            Engine::Step::DiscardTrain,
            Engine::Step::BuyTrain,
            [Engine::Step::BuyCompany, { blocks: true }],
          ], round_num: round_num)
        end

        def p2_company
          @p2_company ||= company_by_id('P2')
        end

        def nzo_has_placed_home?
          corporation_by_id('NZO').tokens.first&.used
        end
      end
    end
  end
end
