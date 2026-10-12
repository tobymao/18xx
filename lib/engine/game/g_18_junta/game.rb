# frozen_string_literal: true

require_relative 'entities'
require_relative 'map'
require_relative 'meta'
require_relative 'step/dividend'
require_relative '../base'
require_relative 'stock_market'

module Engine
  module Game
    module G18Junta
      class Game < Game::Base
        include_meta(G18Junta::Meta)
        include Entities
        include Map

        STATION_TOKENS = { 'E' => [0, 40, 80], 'V' => [0, 40] }.freeze

        def game_corporations
          self.class::CORPORATIONS.map do |corp|
            tokens = self.class::STATION_TOKENS[corp[:sym]]
            tokens ? corp.merge(tokens: tokens) : corp
          end
        end

        def location_name(coord)
          self.class::LOCATION_NAMES[coord]
        end

        CURRENCY_FORMAT_STR = '$%s'

        BANK_CASH = { 3 => 7_000, 4 => 7_000 }.freeze

        CERT_LIMIT = { 3 => 16, 4 => 14 }.freeze

        STARTING_CASH = { 3 => 520, 4 => 450 }.freeze

        CAPITALIZATION = :full

        MUST_SELL_IN_BLOCKS = false

        SELL_BUY_ORDER = :sell_buy_sell

        POOL_SHARE_LIMIT = 50

        SOLD_OUT_INCREASE = true

        GAME_END_CHECK = { bankrupt: :immediate, bank: :full_or, stock_market: :current_or }.freeze

        MARKET = [
          %w[75 85 95 105 115 130 145 160 180 205 230 260 290 320 350e],
          %w[70 80 90 100 110 125 140 155 175 200 225 250 275 300 330e],
          %w[65 70 80 90 100p 110 125 140 155 175 200 225 250 280],
          %w[55 65 70 80p 90p 100 110 125 140 155 175 200],
          %w[50 55 65 70p 80 90 100 110 125 140],
          %w[45 50 60 65p 70 80 90 100],
          %w[35 45 55 60 65 70],
          %w[25 35 45 55],
          %w[10 25 35],
        ].freeze

        PHASES = [
          {
            name: '2',
            train_limit: 4,
            tiles: [:yellow],
            operating_rounds: 1,
          },
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
            status: ['can_buy_companies'],
          },
          {
            name: '6',
            on: '6',
            train_limit: 2,
            tiles: %i[yellow green brown],
            operating_rounds: 3,
          },
          {
            name: '8',
            on: '8',
            train_limit: 2,
            tiles: %i[yellow green brown],
            operating_rounds: 3,
          },
          {
            name: 'D',
            on: 'D',
            train_limit: 2,
            tiles: %i[yellow green brown gray],
            operating_rounds: 3,
          },
        ].freeze

        TRAINS = [
          { name: '2', distance: 2, price: 80, rusts_on: '4', num: 6 },
          { name: '3', distance: 3, price: 180, rusts_on: '6', num: 5 },
          { name: '4', distance: 4, price: 300, rusts_on: %w[8 D], num: 4 },
          { name: '5', distance: 5, price: 450, num: 3 },
          { name: '6', distance: 6, price: 630, num: 2 },
          {
            name: '8',
            distance: 8,
            price: 900,
            num: 6,
            available_on: '6',
            discount: { '4' => 150, '5' => 150, '6' => 150 },
          },
          {
            name: 'D',
            distance: 999,
            price: 1_100,
            num: 6,
            available_on: '6',
            discount: { '4' => 300, '5' => 300, '6' => 300 },
          },
        ].freeze

        EBUY_PRES_SWAP = false
        EBUY_FROM_OTHERS = :value
        ALLOW_TRAIN_BUY_FROM_OTHER_PLAYERS = false
        HOME_TOKEN_TIMING = :float

        # Route text shown on the route selection screen: farms are shown as a single symbol.
        def revenue_str(route)
          farm_hexes = route.visited_stops.select { |stop| farm_stop?(stop) }.map(&:hex)

          route.hexes.map { |hex| farm_hexes.include?(hex) ? 'Ⓕ' : hex.name }.join('+')
        end

        def route_distance_str(route)
          used = route_distance(route)
          train_distance = route.train.distance
          exceeded = train_distance.is_a?(Numeric) && used > train_distance
          exceeded ? "#{used}*" : used.to_s
        end

        def check_other(route)
          stops = route.visited_stops
          return if stops.empty?

          raise GameError, 'A farm cannot be the start or the end of a route' if farm_stop?(stops.first) || farm_stop?(stops.last)
        end

        # Farm tiles are the ones whose label is a single space (the label only exists to tie farm
        # tiles to farm hexes).
        def farm_stop?(stop)
          stop.tile.label.to_s == ' '
        end

        def operating_round(round_num)
          Round::Operating.new(self, [
            Engine::Step::Bankrupt,
            Engine::Step::Exchange,
            Engine::Step::SpecialTrack,
            Engine::Step::BuyCompany,
            Engine::Step::Track,
            Engine::Step::Token,
            Engine::Step::Route,
            G18Junta::Step::Dividend,
            Engine::Step::DiscardTrain,
            Engine::Step::BuyTrain,
            [Engine::Step::BuyCompany, { blocks: true }],
          ], round_num: round_num)
        end

        # There are no private companies yet, so the game starts directly in a stock round.
        def init_round
          @log << "-- #{round_description('Stock', 1)} --"
          @round_counter = 1
          stock_round
        end

        # One random corporation is not available in each game.
        def setup
          removed_corporation = @corporations.min_by { rand }
          @corporations.delete(removed_corporation)
          @log << "Corporation removed in this game: #{removed_corporation.name}"
        end

        TOP_ROW_RIGHT_SYMBOL = "\u00A0\u00A0\u00A0\u00A0\u00A0\u00A0\u00A0\u00A0\u00A0\u00A0↱"

        # Top-row cells show an arrow: moving 'up' from the top row moves one cell to the right
        # instead (see stock_market.rb).
        def game_market
          market = self.class::MARKET
          top_row = market.first.each_with_index.map do |code, col|
            next code if col == market.first.size - 1 || code.match?(/[a-zA-Z]/)

            { price: code.to_i, info: self.class::TOP_ROW_RIGHT_SYMBOL }
          end
          [top_row, *market.drop(1)]
        end

        def init_stock_market
          G18Junta::StockMarket.new(game_market, self.class::CERT_LIMIT_TYPES,
                                    multiple_buy_types: self.class::MULTIPLE_BUY_TYPES,
                                    sold_out_top_row_movement: self.class::SOLD_OUT_TOP_ROW_MOVEMENT)
        end

        def game_trains
          self.class::TRAINS
        end

        # Final wealth: cash plus share values (private companies do not count).
        def player_value(player)
          return super unless player.bankrupt

          super - player.companies.sum(&:value)
        end

        # Laguna (E11): the yellow J16 may be upgraded straight to the gray J17.
        def upgrades_to_correct_color?(from, to, selected_company: nil)
          return true if from.name == 'J16' && to.name == 'J17'

          super
        end
      end
    end
  end
end
