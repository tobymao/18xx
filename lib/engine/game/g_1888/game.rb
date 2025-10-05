# frozen_string_literal: true

require_relative 'meta'
require_relative '../base'
require_relative 'entities'
require_relative 'map'
require_relative '../company_price_50_to_150_percent'

module Engine
  module Game
    module G1888
      class Game < Game::Base
        include_meta(G1888::Meta)
        include Entities
        include Map
        include CompanyPrice50To150Percent

        register_colors(green: '#237333',
                        red: '#d81e3e',
                        blue: '#0189d1',
                        lightBlue: '#a2dced',
                        yellow: '#FFF500',
                        orange: '#f48221',
                        brown: '#7b352a')

        CURRENCY_FORMAT_STR = '¥%s'

        PROTOTYPE_BANK_CASH = 10_000
        BANK_CASH = 9_000

        CERT_LIMIT = { 2 => 20, 3 => 20, 4 => 16, 5 => 13, 6 => 11 }.freeze

        STARTING_CASH = { 2 => 1200, 3 => 800, 4 => 600, 5 => 480, 6 => 400 }.freeze

        CAPITALIZATION = :full

        MUST_SELL_IN_BLOCKS = false

        MUST_BUY_TRAIN = :always

        MARKET = [
          ['', '', '95', '100', '110', '120', '130', '145', '160', '180', '200', '225', '250', '275',
           '300', '330', '360', '400'],
          ['', '85', '90', '95p', '100', '110', '120', '130', '145', '160', '180', '200', '225', '250',
           '275', '300', '330', '360'],
          %w[75 80 85 90p 95 100 110 120 130 145 160 180 200 225 250],
          %w[70 75 80 85p 90 95 100 110 120 130 145 160],
          %w[65 70 75 80p 85 90 95 100 110 120],
          %w[60y 65 70 75p 80 85 90 95],
          %w[55y 60y 65 70p 75 80 85],
          %w[50y 55y 60y 65 70 75],
          %w[40y 50y 55y 60y 65],
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
          },
          {
            name: '6',
            on: '6',
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
          {
            name: '2',
            distance: 2,
            price: 80,
            rusts_on: '4',
            num: 7,
          },
          {
            name: '3',
            distance: 3,
            price: 180,
            rusts_on: '6',
            num: 6,
          },
          {
            name: '4',
            distance: 4,
            price: 300,
            rusts_on: 'D',
            num: 5,
          },
          {
            name: '5',
            distance: 5,
            price: 500,
            num: 3,
            events: [{ 'type' => 'close_companies' }],
          },
          { name: '6', distance: 6, price: 630, num: 2 },
          {
            name: 'D',
            distance: 999,
            price: 900,
            num: 17,
            discount: { '4' => 200, '5' => 200, '6' => 200 },
          },
        ].freeze

        DESTINATION_HEX_NORTH = {
          'JHR' => ['D12'],
          'SSL' => ['C13'],
          'CDL' => ['E17'],
          'HJR' => ['G9'],
          'TJL' => ['H4'],
          'LYR' => ['H14'],
          'JZR' => ['B6'],
          'ZDR' => ['F12'],
        }.freeze

        DESTINATION_HEX_EAST = {
          'LHR' => %w[B12 C3],
          'XGY' => ['D8'],
          'HEN' => ['E15'],
          'HUN' => ['F20'],
          'WJR' => ['G11'],
          'XYR' => ['G19'],
          'YTR' => ['I19'],
          'HHR' => ['G17'],
        }.freeze

        DESTINATION_BONUS_NORTH = {
          'JHR' => 30,
          'SSL' => 20,
          'CDL' => 20,
          'HJR' => 20,
          'TJL' => 20,
          'LYR' => 20,
          'JZR' => 40,
          'ZDR' => 40,
        }.freeze

        DESTINATION_BONUS_EAST = {
          'LHR' => 20,
          'XGY' => 50,
          'HEN' => 20,
          'HUN' => 10,
          'WJR' => 30,
          'XYR' => 20,
          'YTR' => 30,
          'HHR' => 20,
        }.freeze

        MINE_HEX = 'C5'
        MINE_TILE = 'L41'
        MINE_SUBSIDY = 40

        DALIAN_HEX = 'E17'
        DALIAN_FERRY_TILE = 'L40a'
        YANTAI_HEX = 'F16'
        YANTAI_FERRY_TILE = 'L40b'

        XIAN_HEX = 'H2'
        TERRACOTTA_TILE = 'L39'

        BEIJING_HEX = 'C9'

        MUST_BID_INCREMENT_MULTIPLE = false
        ONLY_HIGHEST_BID_COMMITTED = false
        TRACK_RESTRICTION = :permissive
        SELL_BUY_ORDER = :sell_buy
        EBUY_FROM_OTHERS = :never

        def prototype?
          !@optional_rules || @optional_rules&.empty?
        end

        def north?
          @north ||= @optional_rules&.include?(:north)
        end

        def log_optional_rules
          if @optional_rules.empty?
            @log << ' * Playing with prototype (not final) rules, North map'
            return
          end

          @log << 'Optional rules used in this game:'
          self.class::OPTIONAL_RULES.each do |o_r|
            next unless @optional_rules.include?(o_r[:sym])

            @log << " * #{o_r[:short_name]}: #{o_r[:desc]}"
          end

          @log << ' * (Playing with deprecated option)' if @optional_rules.include?(:small_bank)
        end

        def game_tiles
          # When using the 1888-N variant, adjust the tile
          # counts to the alternate values specified.
          return TILES.merge(NORTH_VARIANT_TILES) if north?

          TILES
        end

        def setup
          setup_company_price_50_to_150_percent
          @corporations.each { |c| c.float_percent = 50 } if prototype?
        end

        def bank_starting_cash
          prototype? ? self.class::PROTOTYPE_BANK_CASH : self.class::BANK_CASH
        end

        def yanda
          @yanda ||= company_by_id('YRF')
        end

        def heng_shan
          @heng_shan ||= company_by_id('HS')
        end

        def terracotta
          @terracotta ||= company_by_id('TA')
        end

        def upgrades_to?(from, to, special = false, selected_company: nil)
          if special && selected_company == yanda
            return ((from.hex.id == DALIAN_HEX && to.name == DALIAN_FERRY_TILE) ||
                    (from.hex.id == YANTAI_HEX && to.name == YANTAI_FERRY_TILE))
          end

          return from.hex.id == XIAN_HEX && to.name == TERRACOTTA_TILE if special && selected_company == terracotta

          return false if selected_company != heng_shan && to.name == MINE_TILE

          super
        end

        def operating_round(round_num)
          Engine::Round::Operating.new(self, [
            Engine::Step::Bankrupt,
            G1888::Step::SpecialTrack,
            Engine::Step::SpecialToken,
            Engine::Step::BuyCompany,
            Engine::Step::Track,
            Engine::Step::Token,
            Engine::Step::Route,
            G1888::Step::Dividend,
            Engine::Step::DiscardTrain,
            Engine::Step::BuyTrain,
            [Engine::Step::BuyCompany, { blocks: true }],
          ], round_num: round_num)
        end

        def stock_round
          Engine::Round::Stock.new(self, [
            Engine::Step::DiscardTrain,
            G1888::Step::Exchange,
            Engine::Step::SpecialTrack,
            Engine::Step::BuySellParShares,
          ])
        end

        def or_set_finished
          depot.export! if %w[2 3 4].include?(@depot.upcoming.first.name)
        end

        def timeline
          @timeline = [
            'At the end of each set of ORs the next available non-permanent (2, 3 or 4) train will be exported
           (removed, triggering phase change as if purchased)',
          ]
        end

        def exchange_corporations(_exchange_ability)
          candidates = hex_by_id(BEIJING_HEX).tile.cities.flat_map(&:tokens).compact.map { |t| t&.corporation }
          candidates.reject(&:closed?)
        end

        def subsidy_for(_route, stops)
          stops.any? { |s| s.hex.id == MINE_HEX && s.hex.tile.name = MINE_TILE } ? MINE_SUBSIDY : 0
        end

        def routes_subsidy(routes)
          routes.sum(&:subsidy)
        end

        def destinated?(corp, stops, hex)
          stops.any? { |s| s.hex.id == corp.coordinates } &&
            stops.any? { |s| s.hex.id == hex }
        end

        def revenue_for(route, stops)
          corp = route.train.owner
          bonus = destination_hex[corp.name].sum { |hex| destinated?(corp, stops, hex) ? destination_bonus[corp.name] : 0 }
          super + bonus
        end

        def revenue_str(route)
          corp = route.train.owner
          destination_count = destination_hex[corp.name].count { |hex| destinated?(corp, route.stops, hex) }
          bonus = destination_count.positive? ? " (#{destination_count} dest)" : ''
          super + bonus
        end

        def destination_str(corp)
          hexes = destination_hex[corp.name].map { |hex| "#{location_name(hex)} (#{hex})" }
          "#{hexes} +#{destination_bonus[corp.name]}"
        end

        def status_array(corp)
          ["Dest: #{destination_str(corp)}"]
        end

        def game_hexes
          return self.class::EAST_HEXES if @optional_rules.include?(:east)

          self.class::NORTH_HEXES
        end

        def destination_hex
          return DESTINATION_HEX_EAST if @optional_rules.include?(:east)

          DESTINATION_HEX_NORTH
        end

        def destination_bonus
          return DESTINATION_BONUS_EAST if @optional_rules.include?(:east)

          DESTINATION_BONUS_NORTH
        end

        def game_companies
          return self.class::COMPANIES_EAST if @optional_rules.include?(:east)

          if north?
            companies_north = self.class::COMPANIES_NORTH.reject { |company| company[:sym] == 'FC' }
            companies_north << self.class::COMPANIES_NORTH_PUBLISHED.find { |company| company[:sym] == 'FC' }
            return companies_north
          end

          self.class::COMPANIES_NORTH
        end

        def game_corporations
          return self.class::CORPORATIONS_EAST if @optional_rules.include?(:east)

          self.class::CORPORATIONS_NORTH
        end

        def location_name(coord)
          return self.class::LOCATION_NAMES_EAST[coord] if @optional_rules.include?(:east)

          self.class::LOCATION_NAMES_NORTH[coord]
        end
      end
    end
  end
end
