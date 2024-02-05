# frozen_string_literal: true

require_relative 'meta'
require_relative '../base'
require_relative 'entities'
require_relative 'map'

module Engine
  module Game
    module G18Neb
      class Game < Game::Base
        include_meta(G18Neb::Meta)
        include Entities
        include Map

        BANK_CASH = 6000

        CERT_LIMIT = { 2 => 26, 3 => 17, 4 => 13 }.freeze

        STARTING_CASH = { 2 => 650, 3 => 450, 4 => 350 }.freeze

        ONLY_HIGHEST_BID_COMMITTED = true

        CAPITALIZATION = :incremental
        # However 10-share corps that start in round 5: if their 5th share purchase
        #  - get 5x starting value
        #  - the remaining 5 shares are placed in bank pool

        MUST_SELL_IN_BLOCKS = true

        # TODO: end of SR movement down and right if at top
        # TODO OR movement must pay stock price to move right

        SELL_BUY_ORDER = :sell_buy
        # is this first to pass: first, second: second.. yes
        NEXT_SR_PLAYER_ORDER = :first_to_pass
        MIN_BID_INCREMENT = 5

        MARKET = [
          %w[82 90 100 110 122 135 150 165 180 200 220 245 270 300 330 360 400],
          %w[75 82 90 100p 110 122 135 150 165 180 200 220 245 270 300 330 360],
          %w[70 75 82 90p 100 110 122 135 150 165 180 200 220],
          %w[65 70 75 82p 90 100 110 122 135 150 165],
          %w[60 65 70 75p 82 90 100 110],
          %w[50 60 65 70p 75 82],
          %w[40 50 60 65 70],
          %w[30 40 50 60],
        ].freeze

        PHASES = [
          {
            name: '2',
            train_limit: 4,
            tiles: [:yellow],
            operating_rounds: 2,
            status: ['can_buy_morison'],
          },
          {
            name: '3',
            on: '3+3',
            train_limit: 4,
            tiles: %i[yellow green],
            operating_rounds: 2,
            status: ['can_buy_companies'],
          },
          {
            name: '4',
            on: '4+4',
            train_limit: 3,
            tiles: %i[yellow green],
            operating_rounds: 2,
            status: ['can_buy_companies'],
          },
          {
            name: '5',
            on: '5/7',
            train_limit: 3,
            tiles: %i[yellow green brown],
            operating_rounds: 2,
          },
          {
            name: '6',
            on: '6/8',
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
            name: '2+2',
            distance: [{ 'nodes' => %w[town], 'pay' => 2 },
                       { 'nodes' => %w[town city offboard], 'pay' => 2 }],
            price: 100,
            rusts_on: '4+4',
            num: 5,
          },
          {
            name: '3+3',
            distance: [{ 'nodes' => %w[town], 'pay' => 3 },
                       { 'nodes' => %w[town city offboard], 'pay' => 3 }],
            price: 200,
            rusts_on: '6/8',
            num: 4,
          },
          {
            name: '4+4',
            distance: [{ 'nodes' => %w[town], 'pay' => 4 },
                       { 'nodes' => %w[town city offboard], 'pay' => 4 }],
            price: 300,
            rusts_on: '4D',
            num: 3,
          },
          {
            name: '5/7',
            distance: [{ 'nodes' => %w[city offboard town], 'pay' => 5, 'visit' => 7 }],
            price: 450,
            num: 2,
            events: [{ 'type' => 'close_companies' },
                     { 'type' => 'local_railroads_available' }],
          },
          {
            name: '6/8',
            distance: [{ 'pay' => 6, 'visit' => 8 }],
            price: 600,
            num: 2,
          },
          {
            name: '4D',
            # Can pick 4 best city or offboards, skipping smaller cities.
            distance: [{ 'nodes' => %w[city offboard], 'pay' => 4, 'visit' => 99, 'multiplier' => 2 },
                       { 'nodes' => %w[town], 'pay' => 0, 'visit' => 99 }],
            price: 900,
            num: 20,
            available_on: '6',
            discount: { '4' => 300, '5' => 300, '6' => 300 },
          },
        ].freeze

        EBUY_PRES_SWAP = false # allow presidential swaps of other corps when ebuying
        EBUY_OTHER_VALUE = false # allow ebuying other corp trains for up to face
        HOME_TOKEN_TIMING = :float # not :operating_round
        # Two tiles can be laid, only one upgrade
        TILE_LAYS = [{ lay: true, upgrade: true }, { lay: true, cost: 20, upgrade: :not_if_upgraded }].freeze

        def setup
          @corporations, @future_corporations = @corporations.partition { |corporation| corporation.type != :local }
        end

        def event_local_railroads_available!
          @log << 'Local railroads are now available!'

          @corporations += @future_corporations
          @future_corporations = []
        end

        def reorder_players(order = nil, log_player_order: false)
          @round == Round::Auction ? super(:most_cash, log_player_order: true) : super
        end

        def init_round
          Round::Auction.new(self, [
            Engine::Step::CompanyPendingPar,
            G18Neb::Step::BidAuction,
          ])
        end

        def stock_round
          Round::Stock.new(self, [
            Engine::Step::DiscardTrain,
            Engine::Step::Exchange,
            Engine::Step::HomeToken,
            Engine::Step::SpecialTrack,
            Engine::Step::BuySellParShares,
          ])
        end

        def operating_round(round_num)
          Round::Operating.new(self, [
            Engine::Step::Bankrupt,
            Engine::Step::Exchange,
            Engine::Step::BuyCompany,
            Engine::Step::Track,
            Engine::Step::Token,
            Engine::Step::Route,
            Engine::Step::Dividend,
            Engine::Step::DiscardTrain,
            Engine::Step::BuyTrain,
            [Engine::Step::BuyCompany, { blocks: true }],
          ], round_num: round_num)
        end

        def ipo_name(_entity = nil)
          'Treasury'
        end

        def upgrades_to?(from, to, special = false, selected_company: nil)
          return true if town_to_city_upgrade?(from, to)

          super
        end

        def town_to_city_upgrade?(from, to)
          %w[3 4 58].include?(from.name) && %w[X01 X02 X03].include?(to.name)
        end
      end
    end
  end
end
