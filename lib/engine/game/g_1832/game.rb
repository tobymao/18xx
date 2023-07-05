# frozen_string_literal: true

require_relative 'meta'
require_relative '../base'
require_relative 'map'
require_relative '../g_1870'

module Engine
  module Game
    module G1832
      class Game < Game::Base
        include_meta(G1832::Meta)
        include Entities
        include Map

        attr_accessor :sell_queue, :connection_run, :reissued

        CURRENCY_FORMAT_STR = '$%s'

        BANK_CASH = 12_000

        CERT_LIMIT = {
          2 => { '10' => 28, '9' => 24, '8' => 21, '7' => 17, '6' => 14 },
          3 => { '10' => 20, '9' => 17, '8' => 15, '7' => 12, '6' => 10 },
          4 => { '10' => 16, '9' => 14, '8' => 12, '7' => 10, '6' => 8 },
          5 => { '10' => 13, '9' => 11, '8' => 9, '7' => 8, '6' => 6 },
          6 => { '10' => 11, '9' => 9, '8' => 8, '7' => 6, '6' => 5 },
          7 => { '10' => 9, '9' => 7, '8' => 6, '7' => 5, '6' => 4 },
        }.freeze

        STARTING_CASH = { 2 => 1050, 3 => 700, 4 => 525, 5 => 420, 6 => 350, 7 => 300 }.freeze

        CAPITALIZATION = :full

        MUST_SELL_IN_BLOCKS = true

        MARKET = [
          %w[64y 68 72 76 82 90 100p 110 120 140 160 180 200 225 250 275 300 325 350 375 400],
          %w[60y 64y 68 72 76 82 90p 100 110 120 140 160 180 200 225 250 275 300 325 350 375],
          %w[55y 60y 64y 68 72 76 82p 90 100 110 120 140 160 180 200 225 250i 275i 300i 325i 350i],
          %w[50o 55y 60y 64y 68 72 76p 82 90 100 110 120 140 160i 180i 200i 225i 250i 275i 300i 325i],
          %w[40b 50o 55y 60y 64 68 72p 76 82 90 100 110i 120i 140i 160i 180i],
          %w[30b 40o 50o 55y 60y 64 68p 72 76 82 90i 100i 110i],
          %w[20b 30b 40o 50o 55y 60y 64 68 72 76i 82i],
          %w[10b 20b 30b 40o 50y 55y 60y 64 68i 72i],
          %w[0c 10b 20b 30b 40o 50y 55y 60i 64i],
          %w[0c 0c 10b 20b 30b 40o 50y],
          %w[0c 0c 0c 10b 20b 30b 40o],
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
                    status: %w[can_buy_companies],
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
                    name: '8',
                    on: '8',
                    train_limit: 2,
                    tiles: %i[yellow green brown],
                    operating_rounds: 3,
                  },
                  {
                    name: '10',
                    on: '10',
                    train_limit: 2,
                    tiles: %i[yellow green brown],
                    operating_rounds: 3,
                  },
                  {
                    name: '23',
                    on: '12',
                    train_limit: 2,
                    tiles: %i[yellow green brown],
                    operating_rounds: 3,
                  }].freeze

        TRAINS = [
          { name: '2', distance: 2, price: 80, rusts_on: '4', num: 7 },
          {
            name: '3',
            distance: 3,
            price: 180,
            rusts_on: '6',
            num: 6,
            events: [{ 'type' => 'companies_buyable' }],
          },
          { name: '4', distance: 4, price: 300, rusts_on: '8', num: 5 },
          {
            name: '5',
            distance: 5,
            price: 450,
            rusts_on: '12',
            num: 4,
            events: [{ 'type' => 'close_companies' }],
          },
          {
            name: '6',
            distance: 6,
            price: 630,
            num: 3,
            events: [{ 'type' => 'remove_tokens' }],
          },
          { name: '8', distance: 8, price: 800, num: 3 },
          { name: '10', distance: 10, price: 950, num: 2 },
          { name: '12', distance: 12, price: 1100, num: 99 },
        ].freeze

        LAYOUT = :pointy

        EBUY_OTHER_VALUE = false

        CLOSED_CORP_TRAINS_REMOVED = false

        CORPORATE_BUY_SHARE_ALLOW_BUY_FROM_PRESIDENT = true
        IPO_RESERVED_NAME = 'Treasury'

        TILE_LAYS = [{ lay: true, upgrade: true, cost: 0, cannot_reuse_same_hex: true },
                     { lay: :not_if_upgraded, upgrade: false, cost: 0 }].freeze

        STOCKMARKET_COLORS = Base::STOCKMARKET_COLORS.merge(unlimited: :green, par: :white,
                                                            ignore_one_sale: :red).freeze

        MULTIPLE_BUY_ONLY_FROM_MARKET = true

        EVENTS_TEXT = Base::EVENTS_TEXT.merge(
          'companies_buyable' => ['Companies become buyable', 'All companies may now be bought in by corporation'],
          'remove_tokens' => ['Remove Tokens', 'Remove private company tokens']
        ).freeze

        MARKET_TEXT = Base::MARKET_TEXT.merge(
          ignore_one_sale: 'Can only enter when 2 shares sold at the same time'
        ).freeze

        STATUS_TEXT = Base::STATUS_TEXT.merge(
          'can_buy_companies_from_other_players' => ['Interplayer Company Buy',
                                                     'Companies can be bought between players']
        ).merge(
          'companies_buyable' => ['Companies become buyable', 'All companies may now be bought in by corporation'],
        )

        def new_auction_round
          Engine::Round::Auction.new(self, [
            Engine::Step::CompanyPendingPar,
            Engine::Step::WaterfallAuction,
          ])
        end

        def stock_round
          G1870::Round::Stock.new(self, [
            Engine::Step::DiscardTrain,
            G1870::Step::BuySellParShares,
            G1870::Step::PriceProtection,
          ])
        end

        def operating_round(round_num)
          G1870::Round::Operating.new(self, [
            Engine::Step::Bankrupt,
            Engine::Step::Exchange,
            G1870::Step::BuyCompany,
            G1870::Step::Assign,
            G1870::Step::SpecialTrack,
            G1870::Step::Track,
            Engine::Step::Token,
            Engine::Step::Route,
            G1870::Step::Dividend,
            Engine::Step::DiscardTrain,
            G1870::Step::BuyTrain,
            [G1870::Step::BuyCompany, { blocks: true }],
            G1870::Step::PriceProtection,
          ], round_num: round_num)
        end

        def init_stock_market
          G1870::StockMarket.new(self.class::MARKET, self.class::CERT_LIMIT_TYPES,
                                 multiple_buy_types: self.class::MULTIPLE_BUY_TYPES)
        end

        def ipo_reserved_name(_entity = nil)
          'Treasury'
        end

        def setup
          @sell_queue = []
          @connection_run = {}
          @reissued = {}

          coal_company.max_price = coal_company.value
        end

        def event_companies_buyable!
          coal_company.max_price = 2 * coal_company.value
        end

        def event_remove_tokens!
          removals = Hash.new { |h, k| h[k] = {} }

          @corporations.each do |corp|
            corp.assignments.dup.each do |company, _|
              if ASSIGNMENT_TOKENS[company]
                removals[company][:corporation] = corp.name
                corp.remove_assignment!(company)
              end
            end
          end

          @hexes.each do |hex|
            hex.assignments.dup.each do |company, _|
              if ASSIGNMENT_TOKENS[company]
                removals[company][:hex] = hex.name
                hex.remove_assignment!(company)
              end
            end
          end

          removals.each do |company, removal|
            hex = removal[:hex]
            corp = removal[:corporation]
            @log << "-- Event: #{corp}'s #{company_by_id(company).name} token removed from #{hex} --"
          end
        end

        def coal_company
          @river_company ||= company_by_id('P5')
        end

        def port_company
          @port_company ||= company_by_id('P2')
        end

        def cotton_company
          @cotton_company ||= company_by_id('P3')
        end

        def can_hold_above_corp_limit?(_entity)
          true
        end

        def revenue_for(route, stops)
          revenue = super

          cotton = 'P2'
          revenue += 10 if route.corporation.assigned?(cotton) && stops.any? { |stop| stop.hex.assigned?(cotton) }

          revenue += (route.corporation.assigned?('P3') ? 20 : 10) if stops.any? { |stop| stop.hex.assigned?('P3') }

          revenue
        end

        def sell_shares_and_change_price(bundle, allow_president_change: true, swap: nil, movement: nil)
          @sell_queue << [bundle, bundle.corporation.owner]

          @share_pool.sell_shares(bundle)
        end

        def num_certs(entity)
          entity.shares.sum do |s|
            next 0 unless s.corporation.counts_for_limit
            next 0 unless s.counts_for_limit
            # Don't count shares that have been sold and will go to yellow unless protected
            next 0 if @sell_queue.any? do |bundle, _|
              bundle.corporation == s.corporation &&
                !stock_market.find_share_price(s.corporation, Array.new(bundle.num_shares, :down)).counts_for_limit
            end

            s.cert_size
          end + entity.companies.size
        end

        def legal_tile_rotation?(_entity, _hex, _tile)
          true
        end

        # CHECK IF THIS WORKS, IF NOT TRY IMPLEMENTING THIS OVER HERE VVVVV
        # def upgrades_to?(from, to, _special = false, selected_company: nil)
        #   return false if to.name == '171K' && from.hex.name != 'B11'
        #   return false if to.name == '172L' && from.hex.name != 'C18'

        #   super
        # end

        # def upgrades_to_correct_label?(from, to)
        #   return true if to.color != :brown

        #   super
        # end

        def reissued?(corporation)
          @reissued[corporation]
        end

        # TODO: LIST:
        # Implement the bonuses for P2 and P3
        # Implement Share Count issues (1856)
        #

        ASSIGNMENT_TOKENS = {
          'P2' => '/icons/1846/sc_token.svg',
          'P3' => '/icons/1832/cotton_token.svg',
        }.freeze
      end
    end
  end
end
