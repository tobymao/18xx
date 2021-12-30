# frozen_string_literal: true

require_relative 'meta'
require_relative '../base'
require_relative 'entities'
require_relative 'map'

module Engine
  module Game
    module G18NewEngland
      class Game < Game::Base
        include_meta(G18NewEngland::Meta)
        include Entities
        include Map

        register_colors(black: '#16190e',
                        blue: '#0189d1',
                        brown: '#7b352a',
                        gray: '#7c7b8c',
                        green: '#3c7b5c',
                        olive: '#808000',
                        lightGreen: '#009a54ff',
                        lightBlue: '#4cb5d2',
                        lightishBlue: '#0097df',
                        teal: '#009595',
                        orange: '#d75500',
                        magenta: '#d30869',
                        purple: '#772282',
                        red: '#ef4223',
                        rose: '#b7274c',
                        coral: '#f3716d',
                        white: '#fff36b',
                        navy: '#000080',
                        cream: '#fffdd0',
                        yellow: '#ffdea8')

        CURRENCY_FORMAT_STR = '$%d'
        BANK_CASH = 12_000
        CERT_LIMIT = { 3 => 20, 4 => 16, 5 => 13 }.freeze
        STARTING_CASH = { 3 => 400, 4 => 280, 5 => 280 }.freeze
        CAPITALIZATION = :incremental
        MUST_SELL_IN_BLOCKS = false

        MARKET = [
          %w[35
             40
             45
             50
             55
             60
             65
             70
             80
             90
             100p
             110p
             120p
             130p
             145p
             160p
             180p
             200p
             220
             240
             260
             280
             310
             340
             380
             420
             460
             500e],
           ].freeze

        PHASES = [
          {
            name: '2',
            train_limit: '4',
            tiles: %i[yellow],
            operating_rounds: 2,
          },
          {
            name: '3',
            on: '3',
            train_limit: 4,
            tiles: %i[yellow green],
            operating_rounds: 2,
          },
          {
            name: '4',
            on: '4',
            train_limit: 3,
            tiles: %i[yellow green],
            operating_rounds: 2,
          },
          {
            name: '5',
            on: '5E',
            train_limit: 3,
            tiles: %i[yellow green brown],
            operating_rounds: 2,
          },
          {
            name: '6',
            on: '6E',
            train_limit: 2,
            tiles: %i[yellow green brown],
            operating_rounds: 2,
          },
          {
            name: '8',
            on: '8E',
            train_limit: 2,
            tiles: %i[yellow green brown gray],
            operating_rounds: 2,
          },
          #    status: ['can_buy_companies'],
          #    status: %w[can_buy_companies export_train],
          #    status: %w[can_buy_companies export_train],
        ].freeze

        TRAINS = [
          {
            name: '2',
            distance: 2,
            price: 100,
            rusts_on: '4',
            num: 10,
          },
          {
            name: '3',
            distance: 3,
            price: 180,
            rusts_on: '6E',
            num: 7,
          },
          {
            name: '4',
            distance: 4,
            price: 300,
            rusts_on: '8E',
            num: 4,
          },
          {
            name: '5E',
            distance: 5,
            price: 500,
            num: 4,
          },
          {
            name: '6E',
            distance: 6,
            price: 600,
            num: 3,
          },
          {
            name: '8E',
            distance: 8,
            price: 800,
            num: 20,
          },
        ].freeze

        HOME_TOKEN_TIMING = :operating_round
        MUST_BUY_TRAIN = :always # mostly true, needs custom code
        SELL_MOVEMENT = :down_block_pres
        SELL_BUY_ORDER = :sell_buy

        YELLOW_PRICES = [50, 55, 60, 65, 70].freeze
        GREEN_PRICES = [80, 90, 100].freeze

        # Two lays or one upgrade
        TILE_LAYS = [
          { lay: true, upgrade: true },
          { lay: true, upgrade: :not_if_upgraded },
        ].freeze

        def setup
          # add yellow and green minor placeholders to stock market
          #
          @yellow_dummy = @minors.find { |d| d.name == 'Y' }
          @green_dummy = @minors.find { |d| d.name == 'G' }

          minor_yellow_prices.each do |p|
            p.corporations << @yellow_dummy
            p.corporations << @yellow_dummy
          end

          minor_green_prices.each do |p|
            p.corporations << @green_dummy
            p.corporations << @green_dummy
          end

          @minor_prices = Hash.new { |h, k| h[k] = 0 }
          @reserved = {}

          @log << '-- First Stock Round --'
        end

        def lookup_price(p)
          @stock_market.market[0].size.times do |i|
            return @stock_market.share_price(0, i) if @stock_market.share_price(0, i).price == p
          end
        end

        def init_round
          first_stock_round
        end

        def first_stock_round
          G18NewEngland::Round::FirstStock.new(self, [G18NewEngland::Step::ReserveParShares], snake_order: true)
        end

        def stock_round
          Engine::Round::Stock.new(self, [
            Engine::Step::DiscardTrain,
            G18NewEngland::Step::BuySellParShares,
          ])
        end

        def init_round_finished
          @reserved = {}
        end

        def next_round!
          @round =
            case @round
            when init_round.class
              init_round_finished
              @operating_rounds = @phase.operating_rounds
              reorder_players(:most_cash, log_player_order: true)
              new_operating_round
            when Round::Stock
              @operating_rounds = @phase.operating_rounds
              reorder_players
              new_operating_round
            when Round::Operating
              if @round.round_num < @operating_rounds
                or_round_finished
                new_operating_round(@round.round_num + 1)
              else
                @turn += 1
                or_round_finished
                or_set_finished
                new_stock_round
              end
            end
        end

        def float_corporation(corporation)
          return super unless corporation.type == :minor

          price = corporation.share_price
          index = price.corporations.find_index(@yellow_dummy) || price.corporations.find_index(@green_dummy)
          price.corporations.delete_at(index) if index

          @minor_prices[price] += 1
        end

        def place_home_token(corporation)
          buy_first_train(corporation)
          super
        end

        # minors formed in ISR auto-buy a train
        def buy_first_train(corporation)
          return if corporation.type != :minor || corporation.tokens.first&.used
          return unless @turn == 1

          train = @depot.upcoming.first
          @log << "#{corporation.name} buys a #{train.name} train from Bank"
          buy_train(corporation, train)
        end

        def minor_yellow_prices
          @minor_yellow_prices ||=
            YELLOW_PRICES.map { |p| lookup_price(p) }
        end

        def minor_green_prices
          @minor_green_prices ||=
            GREEN_PRICES.map { |p| lookup_price(p) }
        end

        def share_prices
          (minor_yellow_prices + minor_green_prices + @stock_market.par_prices).uniq
        end

        def available_minor_prices
          available = @minor_yellow_prices.reject { |p| @minor_prices[p] > 1 }
          available.concat(@minor_green_prices.reject { |p| @minor_prices[p] > 1 }) if @phase.available?('3')
          available
        end

        def status_str(corp)
          return unless corp.type == :minor
          return "Minor Company, Price = #{format_currency(corp.share_price.price)}" if corp.share_price
          return "Reserved by #{@reserved[corp].name}" if @reserved[corp]

          'Minor Company'
        end

        def corporation_show_shares?(corp)
          corp.type != :minor
        end

        def operating_order
          mins, majs = @corporations.reject(&:minor?).select(&:floated?).partition(&:type)
          mins.sort + majs.sort
        end

        def bank_sort(corporations)
          mins, majs = corporations.reject(&:minor?).partition(&:type)
          majs.sort_by(&:name) + mins.sort_by(&:name)
        end

        def player_sort(entities)
          mins, majs = entities.partition(&:type)
          (mins.sort_by(&:name) + majs.sort_by(&:name)).group_by(&:owner)
        end

        def reserve_minor(minor, entity)
          @reserved[minor] = entity
        end

        def unreserve_minor(minor, _entity)
          @reserved.delete(minor)
        end

        def ipo_name(corp = nil)
          corp&.type == :minor ? 'Bank' : 'IPO'
        end

        def ipo_verb(corp = nil)
          corp&.type == :minor ? 'forms' : 'pars'
        end

        def form_button_text(corp)
          "Reserve #{corp.name}"
        end
      end
    end
  end
end
