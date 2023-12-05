# frozen_string_literal: true

require_relative 'meta'
require_relative 'map'
require_relative 'entities'
require_relative '../base'

module Engine
  module Game
    module G18India
      class Game < Game::Base
        include_meta(G18India::Meta)
        include Map
        include Entities

        register_colors(brown: '#a05a2c',
                        purple: '#5a2ca0',
                        red: '#d1232a',
                        black: '#000',
                        white: '#ffffff'
                        )
        
        TRACK_RESTRICTION = :permissive
        SELL_BUY_ORDER = :sell_buy_sell
        CURRENCY_FORMAT_STR = 'R%sP'
        GAME_END_CHECK = { bank: :immediate }.freeze
        MARKET_SHARE_LIMIT = 100
        SELL_MOVEMENT = :none
        BANK_CASH = 9_000
        MUST_BUY_TRAIN = :never
        POOL_SHARE_DROP = :none
        SOLD_OUT_INCREASE = false
        BROWN_CITIES = %w[48].freeze
        GRAY_CITIES = %w[51].freeze
        GREEN_CITIES = %w[12 13 14 15].freeze
        YELLOW_TOWNS = %w[1a 2a 3a 4a 55a].freeze
        STOCK_PRICES = {
          'BNR' => 82,
          'BR' => 71,
        }.freeze
        
        CERT_LIMIT = { 2 => 37, 3 => 23, 4 => 18, 5 => 15 }.freeze

        STARTING_CASH = { 2 => 1100 3 => 733, 4 => 550, 5 => 440 }.freeze

        MARKET = [
          %w[0c 
             56
             58
             61
             64p
             67p
             71p
             76p
             82p
             90p
             100p
             112p
             126
             142
             160
             180
             205
             230
             255
             280
             300
             320
             340
             360
             380
             400
             420
             440
             460],
        ].freeze

        PHASES = [{ name: '2', train_limit: 4, tiles: [:yellow], operating_rounds: 1 },
        {
          name: '3',
          on: '3',
          train_limit: 4,
          tiles: %i[yellow green],
          operating_rounds: 2,
        },
        {
          name: '5',
          on: '5',
          train_limit: 3,
          tiles: %i[yellow green brown],
          operating_rounds: 3,
        },
        {
          name: '7',
          on: '7',
          train_limit: 2,
          tiles: %i[yellow green brown gray browngray],
          operating_rounds: 4,
          status: ['Private Companies are closed'],
        }].freeze
        
        TRAINS = [{ name: '2', distance: 2, price: 180, rusts_on: '5', num: 7 },
        { name: '3', distance: 3, price: 300, rusts_on: '7', num: 6 },
        { name: '4', distance: 4, price: 430, num: 5 },
        {
          name: '5',
          distance: 5,
          price: 450,
          num: 5,
        },
        {
          name: '7',
          distance: 7,
          price: 720,
          num: 4,
          events: [{ 'type' => 'close_companies' }],
        }].freeze
        
        #LAYOUT = :pointy

        def upgrades_to?(from, to, _special = false, selected_company: nil)
          return GREEN_CITIES.include?(to.name) if YELLOW_TOWNS.include? from.hex.tile.name
          return BROWN_CITIES.include?(to.name) if GREEN_CITIES.include? from.hex.tile.name
          return GRAY_CITIES.include?(to.name) if BROWN_CITIES.include? from.hex.tile.name
          super
        end
        
        def all_potential_upgrades(tile, tile_manifest: false, selected_company: nil)
          # upgrade for 1,2,3,4,55 in 12,13,14,15
          upgrades = super
          return upgrades unless tile_manifest
          upgrades |= GREEN_CITIES if YELLOW_TOWNS.include?(tile.name)
          upgrades
        end

        def setup
          STOCK_PRICES.each do |corporation, price|
            corporation = corporation_by_id(corporation)
            @stock_market.set_par(corporation, @stock_market.par_prices.find do |p|
              p.price == price
            end)
            corporation.ipoed = true
          end
        end

        def init_round
          G18India::Round::Draft.new(self, [G18India::Step::Draft], snake_order: false)
        end

        def stock_round
          Engine::Round::Stock.new(self, [Engine::Step::BuySellParShares,])
        end

        def operating_round(round_num)
          Engine::Round::Operating.new(self, [
            Engine::Step::Bankrupt,
            Engine::Step::Exchange,
            Engine::Step::HomeToken,
            Engine::Step::Track,
            Engine::Step::Token,
            Engine::Step::Route,
            Engine::Step::Dividend,
            Engine::Step::DiscardTrain,
            Engine::Step::BuyTrain,
            [Engine::Step::BuyCompany, { blocks: false }],
          ], round_num: round_num)
        end

        
        end
      end
    end
  end
end
