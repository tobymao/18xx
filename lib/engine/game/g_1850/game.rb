# frozen_string_literal: true

require_relative '../g_1870/game'
require_relative 'meta'
require_relative 'map'
require_relative 'entities'
require_relative '../base'

module Engine
  module Game
    module G1850
      class Game < Game::Base
        include_meta(G1850::Meta)
        include G1850::Entities
        include G1850::Map

        attr_accessor :sell_queue, :connection_run, :reissued, :mesabi_token_counter, :mesabi_compnay_sold_or_closed

        CORPORATION_CLASS = G1850::Corporation
        COMPANY_CLASS = G1850::Company
        CORPORATE_BUY_SHARE_ALLOW_BUY_FROM_PRESIDENT = true
        MULTIPLE_BUY_ONLY_FROM_MARKET = true

        CERT_LIMIT = {
          2 => { 9 => 24, 8 => 21 },
          3 => { 9 => 17, 8 => 15 },
          4 => { 9 => 14, 8 => 12 },
          5 => { 9 => 11, 8 => 9 },
          6 => { 9 => 9, 8 => 8 },
        }.freeze

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
            status: %w[can_buy_companies],
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
            tiles: %i[yellow green brown gray],
            operating_rounds: 3,
          },
          {
            name: '10',
            on: '10',
            train_limit: 2,
            tiles: %i[yellow green brown gray],
            operating_rounds: 3,
          },
          {
            name: '12',
            on: '12',
            train_limit: 2,
            tiles: %i[yellow green brown gray],
            operating_rounds: 3,
          },
        ].freeze

        TRAINS = [
          { name: '2', distance: 2, price: 80, rusts_on: '4', num: 6 },
          {
            name: '3',
            distance: 3,
            price: 180,
            rusts_on: '6',
            num: 6,
            events: [{ 'type' => 'companies_buyable' }],
          },
          { name: '4', distance: 4, price: 300, rusts_on: '8', num: 4 },
          {
            name: '5',
            distance: 5,
            price: 450,
            rusts_on: '12',
            num: 3,
            events: [{ 'type' => 'close_companies' }],
          },
          {
            name: '6',
            distance: 6,
            price: 630,
            num: 3,
            events: [{ 'type' => 'close_remaining_companies' }],
          },
          { name: '8', distance: 8, price: 800, num: 3 },
          { name: '10', distance: 10, price: 950, num: 2 },
          { name: '12', distance: 12, price: 1100, num: 12 },
        ].freeze

        EVENTS_TEXT = Base::EVENTS_TEXT.merge(
          'companies_buyable' => ['Companies become buyable', 'All companies may now be bought in by corporation'],
          'close_remaining_companies' => ['All Companies Close', 'Companies that did not close in phase 5 are now closed']
        ).freeze

        TILE_LAYS = [{ lay: true, upgrade: true, cost: 0 }].freeze

        def setup
          @sell_queue = []
          @connection_run = {}
          @reissued = {}
          @recently_floated = []
          @mesabi_token_counter = 4

          phase_2_companies.each { |c| c.max_price = c.value }

          @corporations.each do |corporation|
            ability = abilities(corporation, :assign_hexes)
            next unless ability

            hex = hex_by_id(ability.hexes.first)
            ability.description = "Edge Token (#{format_currency(ability.cost)}): #{hex.location_name} (#{hex.name})"
          end
        end

        def event_companies_buyable!
          phase_2_companies.each { |c| c.max_price = 2 * c.value }
        end

        # Everything below this line is also included in 1870's game.rb file

        CURRENCY_FORMAT_STR = '$%s'

        BANK_CASH = 12_000

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
          %w[20b 30b 40o 50o 55y 60 64 68 72 76i 82i],
          %w[10b 20b 30b 40o 50y 55y 60 64 68i 72i],
          %w[0c 10b 20b 30b 40o 50y 55y 60i 64i],
          %w[0c 0c 10b 20b 30b 40o 50y],
          %w[0c 0c 0c 10b 20b 30b 40o],
        ].freeze

        def operating_round(round_num)
          Engine::Round::Operating.new(self, [
            Engine::Step::Bankrupt,
            Engine::Step::Exchange,
            G1850::Step::BuyCompany,
            Engine::Step::HomeToken,
            Engine::Step::Assign,
            G1850::Step::SpecialTrack,
            G1850::Step::Track,
            G1850::Step::Token,
            Engine::Step::Route,
            G1870::Step::Dividend,
            Engine::Step::DiscardTrain,
            G1850::Step::BuyTrain,
            [G1870::Step::BuyCompany, { blocks: true }],
            G1870::Step::PriceProtection,
          ], round_num: round_num)
        end

        def stock_round
          G1870::Round::Stock.new(self, [
            Engine::Step::DiscardTrain,
            G1870::Step::BuySellParShares,
            G1870::Step::PriceProtection,
          ])
        end

        def init_stock_market
          G1870::StockMarket.new(self.class::MARKET, self.class::CERT_LIMIT_TYPES,
                                 multiple_buy_types: self.class::MULTIPLE_BUY_TYPES)
        end

        def float_corporation(corporation)
          @recently_floated << corporation
          super
        end

        def tile_lays(entity)
          return super unless @recently_floated.include?(entity)

          [{ lay: true, upgrade: true }, { lay: :not_if_upgraded, upgrade: false }]
        end

        def track_action_processed(entity)
          @recently_floated.delete(entity)
        end

        def phase_2_companies
          @phase_2_companies ||= [mesabi_company, river_company]
        end

        def mesabi_company
          @mesabi_company ||= company_by_id('MRC')
        end

        def mesabi_hex
          @mesabi_hex ||= hex_by_id('A10')
        end

        def river_company
          @river_company ||= company_by_id('MRB')
        end

        def cm_company
          @cm_company ||= company_by_id('CM')
        end

        def wlg_company
          @wlg_compnay ||= company_by_id('WLG')
        end

        def gbc_company
          @gbc_company ||= company_by_id('GBC')
        end

        def cbq_corp
          @cbq_corp ||= corporation_by_id('CBQ')
        end

        def western_hex?(hex)
          WEST_RIVER_HEXES.include?(hex.id)
        end

        def event_close_companies!
          @log << '-- Event: Private companies close --'
          @companies.each do |company|
            if company == gbc_company ||
              (company == wlg_company && wlg_company.abilities&.first&.count == 3) ||
              (company == cm_company && cm_company.abilities&.first)
              company.revenue = 0
              next
            end

            company.close!
          end
          @mesabi_compnay_sold_or_closed = true
        end

        def event_close_remaining_companies!
          @log << '-- Event: All remaining private companies close --'
          @companies.each(&:close!)
        end

        def purchasable_companies(entity = nil)
          entity ||= current_entity
          return super unless @phase.name == '2'

          phase_2_companies.select { |c| c.owner.player? }
        end

        def check_distance(route, visits, _train = nil)
          return super if visits.none? { |v| v.hex == mesabi_hex } || route.train.owner.mesabi_token

          raise GameError, 'Corporation must own mesabi token to enter Mesabi Range'
        end

        def after_sell_company(buyer, company, _price, _seller)
          return unless company == mesabi_company

          buyer.mesabi_token = true
          @mesabi_token_counter -= 1
          @mesabi_compnay_sold_or_closed = true
          log << "#{buyer.name} receives Mesabi token. #{@mesabi_token_counter} Mesabi tokens left in the game."
          log << '-- Corporations can now buy Mesabi tokens --'
        end

        def status_array(corporation)
          return unless corporation.mesabi_token

          ['Mesabi Token']
        end

        def payout_companies
          super(ignore: [cm_company.id])

          return if cm_company.closed?

          cm_owner = cm_company.owner
          owner = cm_owner.player? ? cm_owner : cm_owner.owner

          revenue = cm_company.revenue
          return unless revenue.positive?

          @bank.spend(revenue, owner)
          @log << "#{owner.name} collects #{format_currency(revenue)} from #{cm_company.name}"
        end

        def revenue_for(route, stops)
          revenue = super
          edge_token_stop = stops.find { |st| st.hex.assigned?(route.corporation) }
          revenue += edge_token_stop.route_revenue(route.phase, route.train) if edge_token_stop

          revenue
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

        def can_hold_above_corp_limit?(_entity)
          true
        end

        def reissued?(corporation)
          @reissued[corporation]
        end

        def revenue_str(route)
          revenue_str = super
          revenue_str += ' + Edge Token' if route.stops.any? { |st| st.hex.assigned?(route.corporation) }
          revenue_str
        end

        def graph_skip_paths(entity)
          return nil if entity.mesabi_token

          @skip_paths ||= {}

          return @skip_paths unless @skip_paths.empty?

          mesabi_hex.tile.paths.each do |path|
            @skip_paths[path] = true
          end

          @skip_paths
        end
      end
    end
  end
end
