# frozen_string_literal: true

require_relative 'meta'
require_relative '../base'

module Engine
  module Game
    module G18OE
      class Game < Game::Base
        include_meta(G18OE::Meta)
        attr_accessor :minor_regional_order

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
        MUST_SELL_IN_BLOCKS = :false
        HOME_TOKEN_TIMING = :float
        TILE_UPGRADES_MUST_USE_MAX_EXITS = [:cities].freeze

        PHASES = [
          {
            name: '2',
            train_limit: 3,
            tiles: [:yellow],
            operating_rounds: 2,
          },
          {
            name: '3',
            train_limit: 3,
            tiles: [:yellow, :green],
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
          {
            name: '3',
            distance: [{ 'nodes' => ['town'], 'pay' => 0, 'visit' => 99 },
                       { 'nodes' => %w[city offboard town], 'pay' => 3, 'visit' => 3 }],
            price: 200,
            variants: [{
                         name: '3+3',
                         distance: [{ 'nodes' => ['town'], 'pay' => 3, 'visit' => 99 },
                                    { 'nodes' => %w[city offboard town], 'pay' => 3, 'visit' => 3 }],
                         price: 225,
                       }],
            num: 4,
          },
        ].freeze

        TILES = {}.freeze

        def setup
          super
          @minor_regional_order = []
        end

        def home_token_locations(corporation)
          # if minor, choose non-metropolis hex
          # if regional, starts on reserved hex

          hexes = @hexes.dup
          hexes.select do |hex|
            hex.tile.cities.any? { |city| city.tokenable?(corporation, free: true) }
          end
        end

        def stock_round
          Round::Stock.new(self, [
            Engine::Step::DiscardTrain,
            Engine::Step::HomeToken,
            G18OE::Step::BuySellParShares,
          ])
        end

        def new_auction_round
          Round::Auction.new(self, [
            Engine::Step::CompanyPendingPar,
            G18OE::Step::WaterfallAuction,
          ])
        end

        def operating_round(round_num)
          Round::G18OE::Operating.new(self, [
            Engine::Step::Bankrupt,
            Engine::Step::Exchange,
            Engine::Step::DiscardTrain,
            Engine::Step::HomeToken,
            Engine::Step::Track, # probably need custom track step
            Engine::Step::Token,
            Engine::Step::Route,
            Engine::Step::Dividend,
            Engine::Step::BuyTrain,
            Engine::Step::IssueShares,
          ], round_num: round_num)
        end

      end
    end
  end
end
