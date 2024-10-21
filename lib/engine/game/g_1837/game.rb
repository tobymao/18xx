# frozen_string_literal: true

require_relative 'corporation'
require_relative 'depot'
require_relative 'entities'
require_relative 'map'
require_relative 'meta'
require_relative '../base'

module Engine
  module Game
    module G1837
      class Game < Game::Base
        include_meta(G1837::Meta)
        include Entities
        include Map

        CORPORATION_CLASS = G1837::Corporation
        DEPOT_CLASS = G1837::Depot

        CURRENCY_FORMAT_STR = '%sK'

        BANK_CASH = 14_268
        STARTING_CASH = { 3 => 730, 4 => 555, 5 => 450, 6 => 380, 7 => 330 }.freeze

        CERT_LIMIT = { 3 => 28, 4 => 21, 5 => 17, 6 => 14, 7 => 12 }.freeze

        SELL_AFTER = :operate
        SELL_MOVEMENT = :down_block

        HOME_TOKEN_TIMING = :float

        EBUY_DEPOT_TRAIN_MUST_BE_CHEAPEST = false
        MUST_BUY_TRAIN = :always

        MARKET = [
          %w[95 99 104p 114 121 132 145 162 181 205 240 280 350 400 460],
          %w[89 93 97p 102 111 118 128 140 154 173 195 225 260 300 360],
          %w[84 87 91p 95 100 108 115 124 135 148 165 185 210 240 280],
          %w[79 82 85p 89 93 98 105 112 120 130 142 157 175],
          %w[74 77 80p 83 87 91 96 102 109 116 125],
          %w[69y 72 75p 78 81 85 89 94 99 106],
          %w[64y 67y 70p 73 76 79 83 87],
          %w[59y 62y 65y 68 71 74 77],
          %w[54y 57y 60y 63y 66 69 72],
        ].freeze

        MARKET_TEXT = Base::MARKET_TEXT.merge(par: 'Major Corporation Par')

        STOCKMARKET_COLORS = Base::STOCKMARKET_COLORS.merge(par_1: :brown, par_2: :orange, par_3: :pink).freeze

        PHASES = [
          {
            name: '2',
            train_limit: { coal: 2, minor: 2, major: 4 },
            tiles: [:yellow],
            operating_rounds: 1,
          },
          {
            name: '3',
            on: '3',
            train_limit: { coal: 2, minor: 2, major: 3 },
            tiles: %i[yellow green],
            operating_rounds: 2,
          },
          {
            name: '3+1',
            on: '3+1',
            train_limit: { coal: 1, minor: 1, major: 3 },
            tiles: %i[yellow green],
            operating_rounds: 2,
          },
          {
            name: '4',
            on: '4',
            train_limit: { coal: 1, minor: 1, major: 3, national: 4 },
            tiles: %i[yellow green],
            operating_rounds: 2,
          },
          {
            name: '5',
            on: '5',
            train_limit: { major: 2, national: 3 },
            tiles: %i[yellow green brown],
            operating_rounds: 3,
          },
        ].freeze

        TRAINS = [
          {
            name: '2',
            num: 14,
            distance: 2,
            price: 90,
            rusts_on: '4',
          },
          {
            name: '3',
            num: 5,
            distance: 3,
            price: 180,
            rusts_on: '5',
            events: [{ 'type' => 'buy_across' }],
          },
          {
            name: '3+1',
            num: 2,
            distance: [
              { 'nodes' => %w[city offboard], 'pay' => 3, 'visit' => 3 },
              { 'nodes' => %w[town], 'pay' => 1, 'visit' => 1 },
            ],
            price: 280,
            rusts_on: '5+2',
          },
          {
            name: '4',
            num: 4,
            distance: 4,
            price: 470,
          },
          {
            name: '4E',
            num: 1,
            distance: [
              { 'nodes' => %w[city offboard], 'pay' => 4, 'visit' => 4 },
              { 'nodes' => %w[town], 'pay' => 0, 'visit' => 99 },
            ],
            price: 500,
          },
          {
            name: '4+1',
            num: 1,
            distance: [
              { 'nodes' => %w[city offboard], 'pay' => 4, 'visit' => 4 },
              { 'nodes' => %w[town], 'pay' => 1, 'visit' => 1 },
            ],
            price: 530,
          },
          {
            name: '4+2',
            num: 1,
            distance: [
              { 'nodes' => %w[city offboard], 'pay' => 4, 'visit' => 4 },
              { 'nodes' => %w[town], 'pay' => 2, 'visit' => 2 },
            ],
            price: 560,
          },
          {
            name: '5',
            num: 2,
            distance: 5,
            price: 800,
          },
          {
            name: '5E',
            num: 1,
            distance: [
              { 'nodes' => %w[city offboard], 'pay' => 5, 'visit' => 5 },
              { 'nodes' => %w[town], 'pay' => 0, 'visit' => 99 },
            ],
            price: 830,
          },
          {
            name: '5+2',
            num: 1,
            distance: [
              { 'nodes' => %w[city offboard], 'pay' => 5, 'visit' => 5 },
              { 'nodes' => %w[town], 'pay' => 2, 'visit' => 2 },
            ],
            price: 860,
          },
          {
            name: '5+3',
            num: 1,
            distance: [
              { 'nodes' => %w[city offboard], 'pay' => 5, 'visit' => 5 },
              { 'nodes' => %w[town], 'pay' => 3, 'visit' => 3 },
            ],
            price: 900,
          },
          {
            name: '5+4',
            num: 20,
            distance: [
              { 'nodes' => %w[city offboard], 'pay' => 5, 'visit' => 5 },
              { 'nodes' => %w[town], 'pay' => 4, 'visit' => 4 },
            ],
            price: 960,
          },
          {
            name: '1G',
            num: 10,
            distance: [
              { 'nodes' => %w[city offboard], 'pay' => 2, 'visit' => 2 },
              { 'nodes' => %w[town], 'pay' => 99, 'visit' => 99 },
            ],
            available_on: '2',
            rusts_on: %w[3G 4G],
            price: 100,
          },
          {
            name: '2G',
            num: 6,
            distance: [
              { 'nodes' => %w[city offboard], 'pay' => 3, 'visit' => 3 },
              { 'nodes' => %w[town], 'pay' => 99, 'visit' => 99 },
            ],
            available_on: '3',
            rusts_on: '4G',
            price: 230,
          },
          {
            name: '3G',
            num: 2,
            distance: [
              { 'nodes' => %w[city offboard], 'pay' => 4, 'visit' => 4 },
              { 'nodes' => %w[town], 'pay' => 99, 'visit' => 99 },
            ],
            available_on: '4',
            price: 590,
          },
          {
            name: '4G',
            num: 20,
            distance: [
              { 'nodes' => %w[city offboard], 'pay' => 5, 'visit' => 5 },
              { 'nodes' => %w[town], 'pay' => 99, 'visit' => 99 },
            ],
            available_on: '5',
            price: 1000,
          },
        ].freeze

        EVENTS_TEXT = Base::EVENTS_TEXT.merge(
          'buy_across' => ['Buy Across', 'Trains can be bought between companies'],
        ).freeze

        ASSIGNMENT_TOKENS = {
          'coal' => '/icons/1837/coalcar.svg',
        }.freeze

        def company_header(company)
          return 'COAL COMPANY' if company.color == :black
          return 'MOUNTAIN RAILWAY' if company.color == :gray
          return 'MINOR SHARE' if company.sym.end_with?('_share')

          'MINOR COMPANY'
        end

        def par_chart
          @par_chart ||=
            share_prices.select { |sp| sp.type == :par }.sort_by { |sp| -sp.price }.to_h { |sp| [sp, [nil, nil]] }
        end

        def set_par(corporation, share_price, slot)
          par_chart[share_price][slot] = corporation
        end

        def init_stock_market
          StockMarket.new(game_market, self.class::CERT_LIMIT_TYPES, hex_market: true)
        end

        def initial_auction_companies
          @companies.select { |company| company.meta[:start_packet] }
        end

        def setup
          non_purchasable = @companies.flat_map { |c| c.meta['additional_companies'] }.compact
          @companies.each { |company| company.owner = @bank unless non_purchasable.include?(company.id) }
          setup_mines
          setup_minors
          setup_nationals
        end

        def setup_mines
          self.class::MINE_HEXES.each do |hex_id|
            hex_by_id(hex_id).assign!(:coal)
          end
        end

        def setup_minors
          @minors.each { |minor| reserve_minor_home(minor) }
        end

        def reserve_minor_home(minor)
          Array(minor.coordinates).zip(Array(minor.city)).each do |coords, city|
            hex_by_id(coords).tile.cities[city || 0].add_reservation!(minor)
          end
        end

        def minor_initial_cash(minor)
          case minor.id
          when 'SD1', 'SD2', 'SD3', 'SD4', 'SD5', 'KK1', 'KK3', 'UG2'
            90
          when 'KK2'
            140
          when 'UG1', 'UG3'
            180
          else
            100
          end
        end

        def setup_nationals
          market_row = @stock_market.market[3]
          { 'KK' => 120, 'SD' => 142, 'UG' => 175 }.each do |id, par_value|
            corporation = corporation_by_id(id)
            share_price = market_row.find { |sp| sp.price == par_value }
            @stock_market.set_par(corporation, share_price)
            corporation.ipoed = true
          end
        end

        def event_buy_across!
          @log << "-- Event: #{EVENTS_TEXT['buy_across'][1]} --"
        end

        def new_auction_round
          Engine::Round::Auction.new(self, [
            G1837::Step::SelectionAuction,
          ])
        end

        def stock_round
          G1837::Round::Stock.new(self, [
            G1837::Step::BuySellParShares,
          ])
        end

        def operating_round(round_num)
          Engine::Round::Operating.new(self, [
            Engine::Step::Bankrupt,
            Engine::Step::DiscardTrain,
            G1837::Step::SpecialTrack,
            Engine::Step::Track,
            G1837::Step::Token,
            Engine::Step::Route,
            G1837::Step::Dividend,
            G1837::Step::BuyTrain,
          ], round_num: round_num)
        end

        def corporation_show_individual_reserved_shares?
          false
        end

        def unowned_purchasable_companies(_entity)
          @companies.select { |c| c.owner == @bank }
        end

        def after_company_acquisition(company)
          player = company.owner

          case company.meta[:type]
          when :minor, :coal
            minor = minor_by_id(company.id)
            minor.owner = player
            float_minor!(minor)
          when :minor_share
            # todo
            puts 'todo'
          end

          Array(company.meta[:additional_companies]).each do |c_id|
            additional_company = company_by_id(c_id)
            additional_company.owner = player
            player.companies << additional_company
          end
        end

        def float_str(entity)
          return 'Not floatable' if entity.corporation? && !entity.floatable

          super
        end

        def float_minor!(minor)
          cash = minor_initial_cash(minor)
          @bank.spend(cash, minor)
          @log << "#{minor.name} receives #{format_currency(cash)}"
          unless minor.coordinates.is_a?(Array)
            hex = hex_by_id(minor.coordinates)
            hex.tile.cities[minor.city || 0].place_token(minor, minor.next_token, free: true)
            @log << "#{minor.name} places a token on #{hex.name}"
          end
          minor.float!
        end

        def float_corporation(corporation)
          @log << "#{corporation.name} floats"
          @bank.spend(corporation.par_price.price * corporation.total_ipo_shares, corporation)
          @log << "#{corporation.name} receives #{format_currency(corporation.cash)}"
        end

        def must_buy_train?(entity)
          %i[major national].include?(entity.type) && super
        end

        def goods_train?(train_name)
          train_name.end_with?('G')
        end

        def can_buy_train_from_others?
          @phase.name.to_i >= 3
        end

        def revenue_for(route, stops)
          super - mine_revenue(route, stops)
        end

        def check_other(route)
          mine_stops = route.stops.count { |s| s.hex.assigned?(:coal) }
          if goods_train?(route.train.name)
            raise GameError, 'Must visit one mine' if mine_stops.zero?
            raise GameError, 'Cannot visit more than one mine' if mine_stops > 1
          elsif mine_stops.positive?
            raise GameError, 'Only goods trains can visit a mine'
          end
        end

        def routes_subsidy(routes)
          routes.sum { |route| mine_revenue(route, route.stops) }
        end

        def mine_revenue(route, stops)
          stops.select { |s| s.hex.assigned?(:coal) }.sum { |s| s.route_revenue(route.phase, route.train) }
        end

        def subsidy_name
          'mine revenue'
        end
      end
    end
  end
end
