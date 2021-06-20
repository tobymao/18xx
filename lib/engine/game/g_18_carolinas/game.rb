# frozen_string_literal: true

require_relative 'meta'
require_relative '../base'
require_relative 'entities'
require_relative 'map'
require_relative 'step/buy_sell_par_shares_companies'

module Engine
  module Game
    module G18Carolinas
      class Game < Game::Base
        include_meta(G18Carolinas::Meta)
        include Entities
        include Map

        attr_reader :tile_groups

        register_colors(green: '#237333',
                        red: '#d81e3e',
                        blue: '#0189d1',
                        lightBlue: '#a2dced',
                        yellow: '#FFF500',
                        orange: '#f48221',
                        brown: '#7b352a')

        CERT_LIMIT = {
          2 => 24,
          3 => 20,
          4 => 16,
          5 => 13,
          6 => 11,
        }.freeze

        STARTING_CASH = {
          2 => 1200,
          3 => 800,
          4 => 600,
          5 => 480,
          6 => 400,
        }.freeze

        MARKET = [
          %w[0
             10
             20
             30
             40
             50
             60p
             70p
             80p
             90p
             100
             110
             125
             140
             160
             180
             200
             225
             250
             275
             300
             325
             350],
        ].freeze

        TRAINS = [
          {
            name: 'X',
            distance: 99,
            price: 1,
            num: 64,
          },
        ].freeze

        PHASES = [
          {
            name: '2',
            train_limit: 2,
            tiles: ['yellow'],
            operating_rounds: 1,
          },
          {
            name: '3',
            train_limit: 2,
            tiles: %w[yellow green],
            operating_rounds: 2,
          },
          {
            name: '4',
            train_limit: 2,
            tiles: %w[yellow green],
            operating_rounds: 2,
          },
          {
            name: '5',
            train_limit: 3,
            tiles: %w[yellow green brown],
            operating_rounds: 3,
          },
          {
            name: '6',
            train_limit: 4,
            tiles: %w[yellow green brown],
            operating_rounds: 3,
          },
          {
            name: '7',
            train_limit: 5,
            tiles: %w[yellow green brown gray],
            operating_rounds: 3,
          },
          {
            name: '8',
            train_limit: 6,
            tiles: %w[yellow green brown gray],
            operating_rounds: 3,
          },
          {
            name: '8a',
            train_limit: 6,
            tiles: %w[yellow green brown gray],
            operating_rounds: 3,
          },
        ].freeze

        PAR_BY_LAYER = {
          1 => 90,
          2 => 80,
          3 => 70,
          4 => 60,
        }.freeze

        TOKENS_BY_LAYER = {
          1 => 4,
          2 => 3,
          3 => 3,
          4 => 2,
        }.freeze

        NORTH_CORPORATIONS = %w[NCR SEA WNC WW].freeze
        SOUTH_CORPORATIONS = %w[CAR CSC SR WM].freeze

        CURRENCY_FORMAT_STR = '$%d'
        BANK_CASH = 6_000
        CAPITALIZATION = :full
        MUST_SELL_IN_BLOCKS = false
        MARKET_SHARE_LIMIT = 100
        SELL_BUY_ORDER = :sell_buy
        SELL_AFTER = :first
        PRESIDENT_SALES_TO_MARKET = true
        HOME_TOKEN_TIMING = :operate
        SOLD_OUT_INCREASE = false
        SELL_MOVEMENT = :none
        COMPANY_SALE_FEE = 30
        ADDED_TOKEN_PRICE = 100

        def init_tile_groups
          [
            %w[1 1s],
            %w[2 2s],
            %w[3 3s],
            %w[4 4s],
            %w[5 5s],
            %w[6 6s],
            %w[7 7s],
            %w[8 8s],
            %w[9 9s],
            %w[55 55s],
            %w[56 56s],
            %w[57 7s],
            %w[58 58s],
            %w[C1 C2],
            %w[C3 C4],
            %w[12 12s],
            %w[13 13s],
            %w[14 14s],
            %w[15 15s],
            %w[16 16s],
            %w[19 19s],
            %w[20 20s],
            %w[23 23s],
            %w[24 24s],
            %w[25 25s],
            %w[26 26s],
            %w[27 27s],
            %w[28 28s],
            %w[29 29s],
            %w[87 87s],
            %w[88 88s],
            %w[C5 C6],
            %w[38],
            %w[39],
            %w[40],
            %w[41],
            %w[42],
            %w[43],
            %w[44],
            %w[45],
            %w[46],
            %w[47],
            %w[70],
            %w[C7],
            %w[C8],
            %w[C9],
          ]
        end

        def init_share_pool
          SharePool.new(self, allow_president_sale: true)
        end

        def setup
          @tile_groups = init_tile_groups
          @highest_layer = 1

          # randomize layers (tranches) with one North and one South in each
          @layer_by_corp = {}
          @north = @corporations.select { |c| NORTH_CORPORATIONS.include?(c.name) }.sort_by { rand }
          @south = @corporations.select { |c| SOUTH_CORPORATIONS.include?(c.name) }.sort_by { rand }
          @north.zip(@south).each_with_index do |corps, idx|
            layer = idx + 1
            corps.each do |corp|
              @layer_by_corp[corp] = layer
              # add additional tokens for earlier layers
              (TOKENS_BY_LAYER[layer] - 2).times do |_t|
                corp.tokens << Token.new(corp, price: ADDED_TOKEN_PRICE)
              end
            end
          end

          # Distribute privates
          # Rules call for randomizing privates, assigning to players then reordering players
          # based on worth of private
          # Instead, just pass out privates from least to most expensive since player order is already
          # random
          sorted_companies = @companies.sort_by(&:value)
          @players.each_with_index do |player, idx|
            if idx < 4
              company = sorted_companies.shift
              @log << "#{player.name} receives #{company.name} and pays #{format_currency(company.value)}"
              player.spend(company.value, @bank)
              player.companies << company
              company.owner = player
            else
              corp = [@north[0], @south[0]][idx - 4]
              price = par_prices(corp)[0]
              @stock_market.set_par(corp, price)
              share = corp.ipo_shares.first
              @share_pool.buy_shares(player,
                                     share.to_bundle,
                                     exchange: nil,
                                     swap: nil,
                                     allow_president_change: true)
              after_par(corp)
            end
          end
        end

        def can_ipo?(corp)
          @layer_by_corp[corp] <= current_layer
        end

        def par_prices(corp)
          price = PAR_BY_LAYER[@layer_by_corp[corp]]
          stock_market.par_prices.select { |p| p.price == price }
        end

        def check_new_layer
          layer = current_layer
          @log << "-- Tranche #{layer} corporations now available --" if layer > @highest_layer
          @highest_layer = layer
        end

        def current_layer
          layers = @layer_by_corp.select do |corp, _layer|
            corp.num_ipo_shares.zero?
          end.values
          layers.empty? ? 1 : [layers.max + 1, 4].min
        end

        def init_round
          @log << "-- #{round_description('Stock', 1)} --"
          @round_counter += 1
          stock_round
        end

        def stock_round
          Engine::Round::Stock.new(self, [
            G18Carolinas::Step::BuySellParSharesCompanies,
          ])
        end

        def operating_round(round_num)
          Round::Operating.new(self, [
            Engine::Step::Bankrupt,
            Engine::Step::HomeToken,
            Engine::Step::Track,
            Engine::Step::Token,
            Engine::Step::Route,
            Engine::Step::Dividend,
            Engine::Step::BuyTrain,
          ], round_num: round_num)
        end

        def sorted_corporations
          @corporations.sort_by { |c| @layer_by_corp[c] }
        end

        def corporation_available?(entity)
          entity.corporation? && can_ipo?(entity)
        end

        def status_array(corp)
          layer_str = "Tranche #{@layer_by_corp[corp]}"
          layer_str += ' (N/A)' unless can_ipo?(corp)

          prices = par_prices(corp).map(&:price).sort
          par_str = ("Par #{prices[0]}" unless corp.ipoed)

          status = [[layer_str]]
          status << [par_str] if par_str
          status << %w[Receivership bold] if corp.receivership?

          status
        end
      end
    end
  end
end
