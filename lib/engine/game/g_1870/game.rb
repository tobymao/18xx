# frozen_string_literal: true

require_relative 'meta'
require_relative '../base'
require_relative 'entities'
require_relative 'map'
require_relative 'stock_market'

module Engine
  module Game
    module G1870
      class Game < Game::Base
        include_meta(G1870::Meta)
        include Entities
        include Map

        attr_accessor :sell_queue, :connection_run, :reissued

        register_colors(black: '#37383a',
                        orange: '#f48221',
                        brightGreen: '#76a042',
                        red: '#d81e3e',
                        turquoise: '#00a993',
                        blue: '#0189d1',
                        brown: '#7b352a')

        CURRENCY_FORMAT_STR = '$%s'

        BANK_CASH = 12_000

        CERT_LIMIT = {
          2 => { 10 => 28, 9 => 24 },
          3 => { 10 => 20, 9 => 17 },
          4 => { 10 => 16, 9 => 14 },
          5 => { 10 => 13, 9 => 11 },
          6 => { 10 => 11, 9 => 9 },
        }.freeze

        STARTING_CASH = { 2 => 1050, 3 => 700, 4 => 525, 5 => 420, 6 => 350 }.freeze

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

        STANDARD_PHASES = [
          {
            name: '1',
            train_limit: 4,
            tiles: [:yellow],
            operating_rounds: 1,
            status: ['can_buy_companies_from_other_players'],
          },
          {
            name: '2',
            on: '3',
            train_limit: 4,
            tiles: %i[yellow green],
            operating_rounds: 2,
            status: %w[can_buy_companies can_buy_companies_from_other_players],
          },
          {
            name: '3',
            on: '4',
            train_limit: 3,
            tiles: %i[yellow green],
            operating_rounds: 2,
            status: %w[can_buy_companies can_buy_companies_from_other_players],
          },
          {
            name: '4',
            on: '5',
            train_limit: 2,
            tiles: %i[yellow green brown],
            operating_rounds: 3,
          },
          {
            name: '5',
            on: '6',
            train_limit: 2,
            tiles: %i[yellow green brown gray],
            operating_rounds: 3,
          },
          {
            name: '6',
            on: '8',
            train_limit: 2,
            tiles: %i[yellow green brown gray blue],
            operating_rounds: 3,
          },
          {
            name: '7',
            on: '10',
            train_limit: 2,
            tiles: %i[yellow green brown gray blue],
            operating_rounds: 3,
          },
          {
            name: '8',
            on: '12',
            train_limit: 2,
            tiles: %i[yellow green brown gray blue],
            operating_rounds: 3,
          },
        ].freeze

        DIESEL_VARIANT_PHASES = [
          {
            name: '1',
            train_limit: 4,
            tiles: [:yellow],
            operating_rounds: 1,
            status: ['can_buy_companies_from_other_players'],
          },
          {
            name: '2',
            on: '3',
            train_limit: 4,
            tiles: %i[yellow green],
            operating_rounds: 2,
            status: %w[can_buy_companies can_buy_companies_from_other_players],
          },
          {
            name: '3',
            on: '4',
            train_limit: 3,
            tiles: %i[yellow green],
            operating_rounds: 2,
            status: %w[can_buy_companies can_buy_companies_from_other_players],
          },
          {
            name: '4',
            on: '5',
            train_limit: 2,
            tiles: %i[yellow green brown],
            operating_rounds: 3,
          },
          {
            name: '5',
            on: '6',
            train_limit: 2,
            tiles: %i[yellow green brown gray],
            operating_rounds: 3,
          },
          {
            name: 'D',
            on: 'D',
            train_limit: 2,
            tiles: %i[yellow green brown gray blue],
            operating_rounds: 3,
          },
        ].freeze

        STANDARD_TRAINS = [
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
          { name: '12', distance: 12, price: 1100, num: 12 },
        ].freeze

        DIESEL_VARIANT_TRAINS = [
          { name: '2', distance: 2, price: 80, rusts_on: '4', num: 7 },
          {
            name: '3',
            distance: 3,
            price: 180,
            rusts_on: '6',
            num: 6,
            events: [{ 'type' => 'companies_buyable' }],
          },
          { name: '4', distance: 4, price: 300, rusts_on: 'D', num: 5 },
          {
            name: '5',
            distance: 5,
            price: 450,
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
          {
            name: 'D',
            distance: 999,
            price: 1100,
            num: 20,
            available_on: '5',
            discount: { '4' => 300, '5' => 300, '6' => 300 },
          },
        ].freeze

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

        ASSIGNMENT_TOKENS = {
          'GSC' => '/icons/1870/GSC.svg',
          'GSCᶜ' => '/icons/1870/GSC_closed.svg',
          'SCC' => '/icons/1870/SCC.svg',
        }.freeze

        def new_auction_round
          Engine::Round::Auction.new(self, [
            G1870::Step::CompanyPendingPar,
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
            G1870::Step::ConnectionToken,
            G1870::Step::ConnectionRoute,
            G1870::Step::ConnectionDividend,
            G1870::Step::CheckConnection,
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
            G1870::Step::CheckConnection,
          ], round_num: round_num)
        end

        def init_stock_market
          G1870::StockMarket.new(self.class::MARKET, self.class::CERT_LIMIT_TYPES,
                                 multiple_buy_types: self.class::MULTIPLE_BUY_TYPES)
        end

        def ipo_reserved_name(_entity = nil)
          'Treasury'
        end

        def init_hexes(companies, corporations)
          hexes = super

          @corporations.each do |corporation|
            ability = abilities(corporation, :assign_hexes)
            hex = hexes.find { |h| h.name == ability.hexes.first }

            hex.assign!(corporation)
            ability.description = "Destination: #{hex.location_name} (#{hex.name})"
          end

          hexes
        end

        def setup
          @sell_queue = []
          @connection_run = {}
          @reissued = {}

          river_company.max_price = river_company.value
        end

        def event_companies_buyable!
          river_company.max_price = 2 * river_company.value
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
            company = 'GSC' if company == 'GSCᶜ'
            @log << "-- Event: #{corp}'s #{company_by_id(company).name} token removed from #{hex} --"
          end
        end

        def river_company
          @river_company ||= company_by_id('MRBC')
        end

        def port_company
          @port_company ||= company_by_id('GSC')
        end

        def mp_corporation
          @mp_corporation ||= corporation_by_id('MP')
        end

        def ssw_corporation
          @ssw_corporation ||= corporation_by_id('SSW')
        end

        def river_corporations
          [ssw_corporation, mp_corporation]
        end

        def purchasable_companies(entity = nil)
          entity ||= current_entity
          return super unless @phase.name == '1'
          return [river_company] if [mp_corporation, ssw_corporation].include?(entity)

          []
        end

        def can_hold_above_corp_limit?(_entity)
          true
        end

        def home_hex(corporation)
          corporation.tokens.first.city&.hex
        end

        def destination_hex(corporation)
          ability = corporation.abilities.first
          hexes.find { |h| h.name == ability.hexes.first } if ability
        end

        def revenue_for(route, stops)
          revenue = super

          cattle = 'SCC'
          revenue += 10 if route.corporation.assigned?(cattle) && stops.any? { |stop| stop.hex.assigned?(cattle) }

          revenue += 20 if route.corporation.assigned?('GSCᶜ') && stops.any? { |stop| stop.hex.assigned?('GSCᶜ') }

          revenue += (route.corporation.assigned?('GSC') ? 20 : 10) if stops.any? { |stop| stop.hex.assigned?('GSC') }

          revenue += destination_revenue(route, stops)

          revenue
        end

        def destination_revenue(route, stops)
          return 0 if stops.size < 2
          return 0 unless (destination = destination_hex(route.corporation))
          return 0 if destination.assigned?(route.corporation)

          destination_stop = stops.values_at(0, -1).find { |s| s.hex == destination }
          return 0 unless destination_stop

          destination_stop.route_revenue(route.phase, route.train)
        end

        def sell_shares_and_change_price(bundle, allow_president_change: true, swap: nil)
          @sell_queue << [bundle, bundle.corporation.owner]

          @share_pool.sell_shares(bundle)
        end

        def num_certs(entity, price_protecting: false)
          entity.shares.sum do |s|
            next 0 unless s.corporation.counts_for_limit
            next 0 unless s.counts_for_limit
            # Don't count shares that have been sold and will go to yellow unless protected.
            # But if this entity is in process of price protecting, DO count shares sold from white to yellow,
            # because protecting will keep them white.
            next 0 if !price_protecting && @sell_queue.any? do |bundle, _|
                        bundle.corporation == s.corporation &&
                          !stock_market.find_share_price(s.corporation, Array.new(bundle.num_shares, :down)).counts_for_limit
                      end

            s.cert_size
          end + entity.companies.size
        end

        def legal_tile_rotation?(_entity, hex, tile)
          return true unless abilities(river_company, :blocks_partition)

          (tile.exits & hex.tile.borders.select { |b| b.type == :water }.map(&:edge)).empty? &&
            hex.tile.partitions.all? do |partition|
              if partition.restrict != ''
                # city and town river tiles restrict all paths to one partition
                tile.paths.all? { |path| (path.exits - partition.inner).empty? || (path.exits - partition.outer).empty? }
              else
                # non-city tile; no paths cross the partition, but there can be paths on both sides
                tile.paths.empty? { |path| (path.exits - partition.inner).empty? != (path.exits - partition.outer).empty? }
              end
            end
        end

        def border_impassable?(border)
          border.type == :water
        end

        def check_other(route)
          return unless (destination = @round.connection_runs[route.corporation])

          home = home_hex(route.corporation)
          return if route.routes.any? do |r|
            next if r.visited_stops.size < 2

            (r.visited_stops.values_at(0, -1).map(&:hex) - [home, destination]).none?
          end

          raise GameError, 'At least one train has to run from the home station to the destination'
        end

        def reissued?(corporation)
          @reissued[corporation]
        end

        # allows implementation of diesels variant
        def game_trains
          @optional_rules&.include?(:diesels) ? self.class::DIESEL_VARIANT_TRAINS : self.class::STANDARD_TRAINS
        end

        def game_phases
          @optional_rules&.include?(:diesels) ? self.class::DIESEL_VARIANT_PHASES : self.class::STANDARD_PHASES
        end
      end
    end
  end
end
