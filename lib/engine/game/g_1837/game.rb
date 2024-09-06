# frozen_string_literal: true

require_relative 'corporation'
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

        CURRENCY_FORMAT_STR = '%sK'

        BANK_CASH = 14_268
        STARTING_CASH = { 3 => 730, 4 => 555, 5 => 450, 6 => 380, 7 => 330 }.freeze

        CERT_LIMIT = { 3 => 28, 4 => 21, 5 => 17, 6 => 14, 7 => 12 }.freeze

        SELL_AFTER = :operate
        SELL_MOVEMENT = :down_block

        HOME_TOKEN_TIMING = :float

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
        ].freeze

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
          par_nationals
        end

        def par_nationals
          market_row = @stock_market.market[3]
          { 'KK' => 120, 'SD' => 142, 'UG' => 175 }.each do |id, par_value|
            corporation = corporation_by_id(id)
            share_price = market_row.find { |sp| sp.price == par_value }
            @stock_market.set_par(corporation, share_price)
            corporation.ipoed = true
          end
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

        def corporation_show_individual_reserved_shares?
          false
        end

        def unowned_purchasable_companies(_entity)
          @companies.reject(&:owner).reject(non_purchasable_companies)
        end

        def after_company_assigned(company)
          player = company.owner

          case company.meta[:type]
          when :minor, :coal
            float_minor!(minor_by_id(company.id), player)
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

        def float_minor!(minor, owner)
          minor.owner = owner
          minor.float!
        end

        def float_corporation(corporation)
          @log << "#{corporation.name} floats"
          @bank.spend(corporation.par_price.price * corporation.total_ipo_shares, corporation)
          @log << "#{corporation.name} receives #{format_currency(corporation.cash)}"
        end
      end
    end
  end
end
