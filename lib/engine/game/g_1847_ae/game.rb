# frozen_string_literal: true

require_relative 'meta'
require_relative '../base'
require_relative 'map'
require_relative 'entities'
require_relative 'corporation'
require_relative 'share_pool'

module Engine
  module Game
    module G1847AE
      class Game < Game::Base
        include_meta(G1847AE::Meta)
        include Map
        include Entities

        HOME_TOKEN_TIMING = :float
        TRACK_RESTRICTION = :semi_restrictive
        SELL_BUY_ORDER = :sell_buy
        SELL_AFTER = :operate
        SELL_MOVEMENT = :down_block
        TILE_RESERVATION_BLOCKS_OTHERS = :always
        CAPITALIZATION = :incremental

        BANK_CASH = 8_000
        CURRENCY_FORMAT_STR = '%sM'
        CERT_LIMIT = { 3 => 16, 4 => 12, 5 => 9 }.freeze
        STARTING_CASH = { 3 => 500, 4 => 390, 5 => 320 }.freeze

        MARKET = [
          ['', '', '', '', '130', '150', '170', '190', '210', '230', '255', '285', '315', '350', '385', '420'],
          ['', '', '98', '108', '120', '135', '150', '170', '190', '210', '235', '260', '285', '315', '350', '385'],
          %w[82 86p 92 100 110 125 140 155 170 190 210 235 260 290 320],
          %w[78 84p 88 94 104 112 125 140 155 170 190 215],
          %w[72 80p 86 90 96 104 115 125 140],
          %w[62 74p 82 88 92 98 105],
          %w[50 66p 76 84 90],
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
                  { name: '4', distance: 4, price: 300, rusts_on: 'D', num: 4 },
                  {
                    name: '5',
                    distance: 5,
                    price: 450,
                    num: 3,
                    events: [{ 'type' => 'close_companies' }],
                  },
                  { name: '6', distance: 6, price: 630, num: 2 },
                  {
                    name: 'D',
                    distance: 999,
                    price: 1100,
                    num: 20,
                    available_on: '6',
                    discount: { '4' => 300, '5' => 300, '6' => 300 },
                  }].freeze

        LAYOUT = :pointy

        def stock_round
          Engine::Round::Stock.new(self, [
            Engine::Step::DiscardTrain,
            G1847AE::Step::BuySellParShares,
          ])
        end

        def operating_round(round_num)
          Round::Operating.new(self, [
            Engine::Step::Bankrupt,
            Engine::Step::Exchange,
            Engine::Step::SpecialTrack,
            Engine::Step::SpecialToken,
            Engine::Step::BuyCompany,
            Engine::Step::HomeToken,
            Engine::Step::Track,
            Engine::Step::Token,
            Engine::Step::Route,
            Engine::Step::Dividend,
            Engine::Step::DiscardTrain,
            Engine::Step::BuyTrain,
            [Engine::Step::BuyCompany, { blocks: true }],
          ], round_num: round_num)
        end

        def saar
          corporation_by_id('Saar')
        end

        def hlb
          corporation_by_id('HLB')
        end

        def init_share_pool
          G1847AE::SharePool.new(self)
        end

        # Reserved share type used to represent investor shares
        def ipo_reserved_name(_entity = nil)
          'Investor'
        end

        def init_corporations(stock_market)
          self.class::CORPORATIONS.map do |corporation|
            par_price = stock_market.par_prices.find { |p| p.price == corporation[:required_par_price] }
            corporation[:par_price] = par_price
            G1847AE::Corporation.new(
              min_price: par_price.price,
              capitalization: self.class::CAPITALIZATION,
              **corporation.merge(corporation_opts),
            )
          end
        end

        def setup
          # Reserve investor shares and add money for them to treasury
          [saar.shares[1], saar.shares[2], hlb.shares[1]].each { |s| s.buyable = false }
          saar.cash += saar.par_price.price * 2
          hlb.cash += hlb.par_price.price
        end

        def place_home_token(corporation)
          return if corporation.tokens.first&.used == true

          return super unless corporation == hlb

          hlb.coordinates.each do |coordinate|
            hex = hex_by_id(coordinate)
            tile = hex&.tile
            tile.cities.first.place_token(hlb, hlb.next_token)
          end
          hlb.coordinates = [hlb.coordinates.first]
          ability = hlb.all_abilities.find { |a| a.description.include?('Two home stations') }
          hlb.remove_ability(ability)
        end
      end
    end
  end
end
