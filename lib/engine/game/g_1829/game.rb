# frozen_string_literal: true

require_relative 'meta'
require_relative '../base'
require_relative 'entities'
require_relative 'map'

module Engine
  module Game
    module G1829
      class Game < Game::Base
        include_meta(G1829::Meta)
        include G1829::Entities
        include G1829::Map

        register_colors(red: '#d1232a',
                        orange: '#f58121',
                        black: '#110a0c',
                        blue: '#025aaa',
                        lightBlue: '#8dd7f6',
                        yellow: '#ffe600',
                        green: '#32763f',
                        brightGreen: '#6ec037')
        TRACK_RESTRICTION = :permissive
        SELL_BUY_ORDER = :sell_buy_sell
        CURRENCY_FORMAT_STR = '$%dP'
        GAME_END_CHECK = { bank: :immediate }.freeze
        MARKET_SHARE_LIMIT = 100
        SELL_MOVEMENT = :none
        BANK_CASH = 20_000
        MUST_BUY_TRAIN = :never
        POOL_SHARE_DROP = :none
        SOLD_OUT_INCREASE = false
        BROWN_CITIES = %w[48].freeze
        GRAY_CITIES = %w[51].freeze
        GREEN_CITIES = %w[12 13 14 15].freeze
        YELLOW_TOWNS = %w[1a 2a 3a 4a 55a].freeze

        CERT_LIMIT = { 3 => 18, 4 => 18, 5 => 17, 6 => 14, 7 => 12, 8 => 10, 9 => 9 }.freeze

        STARTING_CASH = { 3 => 840, 4 => 630, 5 => 504, 6 => 420, 7 => 360, 8 => 315, 9 => 280 }.freeze

        LOCATION_NAMES = {
        }.freeze

        MARKET = [
          %w[0c 10y
             20y
             29y
             38
             47
             53
             56p
             58p
             61p
             64p
             67p
             71p
             76p
             82p
             90p
             100p
             112
             126
             142
             160
             180
             200
             225
             250
             275
             300
             320
             335
             345
             350],
        ].freeze
        STOCKMARKET_COLORS = Base::STOCKMARKET_COLORS.merge(
          init1: :red,
          init2: :green,
          init3: :orange,
          init4: :brightgreen,
          init5: :lightblue,
          init6: :yellow,
          init7: :orange,
          init8: :red,
          init9: :blue,
          init10: :orange,
        ).freeze

        MARKET_TEXT = {
          init1: 'Startkurs LNWR',
          init2: 'Startkurs GWR',
          init3: 'Startkurs Midland',
          init4: 'Startkurs LSWR',
          init5: 'Startkurs GNR',
          init6: 'Startkurs LBSC',
          init7: 'Startkurs GER',
          init8: 'Startkurs GCR',
          init9: 'Startkurs L&YR',
          init10: 'Startkurs SECR',
        }.freeze

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

        LAYOUT = :pointy

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
          @lnw = @corporations.find { |c| c.id == 'LNWR' }
          @gwr = @corporations.find { |c| c.id == 'GWR' }
          @mid = @corporations.find { |c| c.id == 'Mid' }
          @lsw = @corporations.find { |c| c.id == 'LSWR' }
          @gnr = @corporations.find { |c| c.id == 'GNR' }
          @lbs = @corporations.find { |c| c.id == 'LBSC' }
          @ger = @corporations.find { |c| c.id == 'GER' }
          @gcr = @corporations.find { |c| c.id == 'GCR' }
          @lyr = @corporations.find { |c| c.id == 'LYR' }
          @sec = @corporations.find { |c| c.id == 'SECR' }

          @stock_market.set_par(@lnw, @stock_market.par_prices.find { |p| p.price == 100 })
          @stock_market.set_par(@gwr, @stock_market.par_prices.find { |p| p.price == 90 })
          @stock_market.set_par(@mid, @stock_market.par_prices.find { |p| p.price == 82 })
          @stock_market.set_par(@lsw, @stock_market.par_prices.find { |p| p.price == 76 })
          @stock_market.set_par(@gnr, @stock_market.par_prices.find { |p| p.price == 71 })
          @stock_market.set_par(@lbs, @stock_market.par_prices.find { |p| p.price == 67 })
          @stock_market.set_par(@ger, @stock_market.par_prices.find { |p| p.price == 64 })
          @stock_market.set_par(@gcr, @stock_market.par_prices.find { |p| p.price == 61 })
          @stock_market.set_par(@lyr, @stock_market.par_prices.find { |p| p.price == 58 })
          @stock_market.set_par(@sec, @stock_market.par_prices.find { |p| p.price == 56 })
          @lnw.ipoed = true
          @gwr.ipoed = true
          @mid.ipoed = true
          @lsw.ipoed = true
          @gnr.ipoed = true
          @lbs.ipoed = true
          @ger.ipoed = true
          @gcr.ipoed = true
          @lyr.ipoed = true
          @sec.ipoed = true

          @corporations ||= corporations + companies
        end

        def init_round
          G1829::Round::Draft.new(self,
                                  [G1829::Step::Draft],
                                  snake_order: false)
        end

        def stock_round
          Engine::Round::Stock.new(self, [
            Engine::Step::BuySellParShares,
          ])
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
