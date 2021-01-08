# frozen_string_literal: true

require_relative '../config/game/g_1824'
require_relative 'base'
require_relative '../corporation'
module Engine
  module Game
    class G1824 < Base
      register_colors(
        gray70: '#B3B3B3',
        gray50: '#7F7F7F'
      )

      load_from_json(Config::Game::G1824::JSON)
      AXES = { x: :number, y: :letter }.freeze

      GAME_LOCATION = 'Austria-Hungary'
      GAME_RULES_URL = 'https://boardgamegeek.com/filepage/188242/1824-english-rules'
      GAME_DESIGNER = 'Leonhard Orgler & Helmut Ohley'
      GAME_PUBLISHER = :lonny_games
      GAME_INFO_URL = 'https://github.com/tobymao/18xx/wiki/1824'

      GAME_END_CHECK = { bank: :full_or }.freeze

      # Move down one step for a whole block, not per share
      SELL_MOVEMENT = :down_block

      EVENTS_TEXT = Base::EVENTS_TEXT.merge(
        'close_mountain_railways' => ['Mountain railways closed', 'Any still open Montain railways are exchanged'],
        'sd_formation' => ['SD formation', 'The Suedbahn is founded at the end of the OR'],
        'close_coal_railways' => ['Coal railways closed', 'Any still open Coal railways are exchanged'],
        'ug_formation' => ['UG formation', 'The Ungarische Staatsbahn is founded at the end of the OR'],
        'kk_formation' => ['k&k formation', 'k&k Staatsbahn is founded at the end of the OR']
      ).freeze

      STATUS_TEXT = Base::STATUS_TEXT.merge(
        'may_exchange_coal_railways' => ['Coal Railway exchange', 'May exchange Coal Railways during SR'],
        'may_exchange_mountain_railways' => ['Mountain Railway exchange', 'May exchange Mountain Railways during SR']
      ).freeze

      OPTIONAL_RULES = [
        { sym: :cisleithania,
          short_name: 'Cisleithania',
          desc: 'Use the smaller Cislethania map, with some reduction of components - 2-3 players' },
        { sym: :goods_time,
          short_name: 'Goods Time',
          desc: 'Use the Goods Time Variant (3-6 players) - pre-set scenario' },
      ].freeze

      CERT_LIMIT_CISLEITHANIA = { 2 => 14, 3 => 16 }.freeze

      BANK_CASH_CISLEITHANIA = { 2 => 4000, 3 => 9000 }.freeze

      CASH_CISLEITHANIA = { 2 => 830, 3 => 680 }.freeze

      MOUNTAIN_RAILWAY_NAMES = {
        1 => 'Semmeringbahn',
        2 => 'Kastbahn',
        3 => 'Brennerbahn',
        4 => 'Arlbergbahn',
        5 => 'Karawankenbahn',
        6 => 'Wocheinerbahn',
      }.freeze

      MINE_HEX_NAMES = %w[C6 A12 A22 H25].freeze
      MINE_HEX_NAMES_CISLEITHANIA = %w[C6 A12 A22 H25].freeze

      def init_optional_rules(optional_rules)
        opt_rules = super

        # 2 player variant always use the Cisleithania map
        opt_rules << :cisleithania if @players.size == 2 && !opt_rules.include?(:cisleithania)

        # Good Time variant is not applicable if Cisleithania is used
        opt_rules -= [:goods_time] if opt_rules.include?(:cisleithania)

        opt_rules
      end

      def init_bank
        return super unless option_cisleithania

        Engine::Bank.new(BANK_CASH_CISLEITHANIA[@players.size], log: @log)
      end

      def init_starting_cash(players, bank)
        return super unless option_cisleithania

        players.each do |player|
          bank.spend(CASH_CISLEITHANIA[@players.size], player)
        end
      end

      def init_corporations(stock_market)
        corporations = CORPORATIONS.dup

        # Remove Coal Railway C4 (SPB), Regional Railway BH and SB
        corporations.reject! { |c| %w[SPB SB BH].include?(c[:sym]) } if option_cisleithania

        corporations.map do |corporation|
          Corporation.new(
            min_price: stock_market.par_prices.map(&:price).min,
            capitalization: self.class::CAPITALIZATION,
            **corporation.merge(corporation_opts),
          )
        end
      end

      def init_minors
        minors = MINORS.dup

        if option_cisleithania
          if @players.size == 2
            # Remove Pre-Staatsbahn U1 and U2
            minors.reject! { |m| %w[U1 U2].include?(m[:sym]) }
          else
            # Remove Pre-Staatsbahn U2, and move home location for U1
            minors.reject! { |m| %w[U2].include?(m[:sym]) }
            minors.map! do |m|
              next m unless m['sym'] == 'U1'

              m['coordinates'] = 'G12'
              m['city'] = 0
              m
            end
          end
        end

        minors.map { |minor| Minor.new(**minor) }
      end

      def init_companies(players)
        companies = COMPANIES.dup

        mountain_railway_count =
          case players.size
          when 2
            2
          when 3
            option_cisleithania ? 3 : 4
          when 4
            6
          when 5
            6
          when 6
            4
          end
        mountain_railway_count.times { |index| companies << mountain_railway_definition(index) }

        if option_cisleithania
          # Remove Pre-Staatsbahn U2 and possibly U1
          p2 = players.size == 2
          companies.reject! { |m| m['sym'] == 'U2' || (p2 && m['sym'] == 'U1') }
        end

        companies.map { |company| Company.new(**company) }
      end

      def init_tiles
        tiles = TILES.dup

        if option_goods_time
          # Goods Time increase count for some town related tiles
          tiles['3'] += 3
          tiles['4'] += 3
          tiles['56'] += 1
          tiles['58'] += 3
          tiles['87'] += 2
          tiles['630'] += 1
          tiles['631'] += 1

          # New tile for Goods Time variant
          tiles['204'] = 3
        end

        tiles.flat_map do |name, val|
          init_tile(name, val)
        end
      end

      def option_cisleithania
        @optional_rules&.include?(:cisleithania)
      end

      def option_goods_time
        @optional_rules&.include?(:goods_time)
      end

      def location_name(coord)
        return super unless option_cisleithania

        unless @location_names
          @location_names = LOCATION_NAMES.dup
          @location_names['F25'] = 'Kronstadt'
          @location_names['G12'] = 'Budapest'
          @location_names['I10'] = 'Bosnien'
        end
        @location_names[coord]
      end

      def optional_hexes
        option_cisleithania ? cisleithania_map : base_map
      end

      def operating_round(round_num)
        Round::Operating.new(self, [
          Step::Bankrupt,
          Step::DiscardTrain,
          Step::BuyCompany,
          Step::HomeToken,
          Step::SpecialTrack,
          Step::Track,
          Step::Token,
          Step::Route,
          Step::Dividend,
          Step::G1824::BuyTrain,
          [Step::BuyCompany, blocks: true],
        ], round_num: round_num)
      end

      def init_round
        @log << '-- First Stock Round --'
        @log << 'Player order is reversed the first turn'
        Round::G1824::Stock.new(self, [
          Step::G1824::BuySellParShares,
        ])
      end

      def purchasable_companies(_entity = nil)
        []
      end

      def setup
        g_trains = @depot.upcoming.select { |t| g_train?(t) }
        coal_railways.each do |coalcorp|
          train = g_trains.shift
          buy_train(coalcorp, train, :free)
          coalcorp.spend(120, @bank, check_cash: false)
        end

        @minors.each do |minor|
          hex = hex_by_id(minor.coordinates)
          hex.tile.cities[minor.city].place_token(minor, minor.next_token)
        end
      end

      def ipo_name(entity)
        return 'Treasury' if coal_railways.include?(entity)

        'IPO'
      end

      def can_par?(corporation, parrer)
        super && !corporation.all_abilities.find { |a| a.type == :no_buy }
      end

      def g_train?(train)
        train.name.end_with?('g')
      end

      def coal_railways
        @coal_railways ||= (option_cisleithania ? %w[EPP EOD MLB] : %w[EPP EOD MLB SPB])
          .map { |c| corporation_by_id(c) }
      end

      def revenue_for(route, stops)
        # Ensure only g-trains visit mines, and that g-trains visit exactly one mine
        mine_visits = route.hexes.count { |h| mine_hex?(h) }

        raise GameError, 'Exactly one mine need to be visited' if g_train?(route.train) && mine_visits != 1
        raise GameError, 'Only g-trains may visit mines' if !g_train?(route.train) && mine_visits.positive?

        super
      end

      private

      def mine_hex?(hex)
        option_cisleithania ? MINE_HEX_NAMES_CISLEITHANIA.include?(hex.name) : MINE_HEX_NAMES.include?(hex.name)
      end

      MOUNTAIN_RAILWAY_DEFINITION = {
        sym: 'B%1$d',
        name: '%2$s (B%1$d)',
        value: 120,
        revenue: 25,
        desc: 'Moutain railway (B%1$d). Cannot be sold but can be exchanged for a 10 percent share in a '\
              'regional railway during phase 3 SR, or when first 4 train is bought. '\
              'If no regional railway shares are available from IPO this private is lost without compensation.',
        abilities: [
          {
            type: 'no_buy',
            owner_type: 'player',
          },
        ],
      }.freeze

      def mountain_railway_definition(index)
        real_index = index + 1
        definition = MOUNTAIN_RAILWAY_DEFINITION.dup
        definition[:sym] = format(definition[:sym], real_index)
        definition[:name] = format(definition[:name], real_index, MOUNTAIN_RAILWAY_NAMES[real_index])
        definition[:desc] = format(definition[:desc], real_index)
        definition
      end

      DRESDEN_1 = 'offboard=revenue:yellow_10|green_20|brown_30|gray_40,hide:1,groups:Dresden;'\
                      'path=a:4,b:_0,terminal:1;path=a:5,b:_0,terminal:1'
      DRESDEN_2 = 'offboard=revenue:yellow_10|green_20|brown_30|gray_40,groups:Dresden;'\
                      'path=a:4,b:_0,terminal:1'
      KIEW_1 = 'offboard=revenue:yellow_10|green_30|brown_40|gray_50,hide:1,groups:Kiew;'\
                       'path=a:0,b:_0,terminal:1;path=a:5,b:_0,terminal:1'
      KIEW_2 = 'offboard=revenue:yellow_10|green_30|brown_40|gray_50,groups:Kiew;'\
                       'path=a:0,b:_0,terminal:1'
      MAINLAND_1 = 'offboard=revenue:yellow_10|green_30|brown_50|gray_70,hide:1,groups:Mainland;'\
                      'path=a:3,b:_0,terminal:1;path=a:4,b:_0,terminal:1'
      MAINLAND_2 = 'offboard=revenue:yellow_10|green_30|brown_50|gray_70,groups:Mainland;path=a:3,b:_0,terminal:1'
      BUKAREST_1 = 'offboard=revenue:yellow_10|green_30|brown_40|gray_50,hide:1,groups:Bukarest;'\
                   'path=a:1,b:_0,terminal:1'
      BUKAREST_2 = 'offboard=revenue:yellow_10|green_30|brown_40|gray_50,groups:Bukarest;path=a:2,b:_0,terminal:1'
      SARAJEVO_1 = 'offboard=revenue:yellow_10|green_10|brown_50|gray_50,hide:1,groups:Sarajevo;'\
                   'path=a:2,b:_0,terminal:1;path=a:3,b:_0,terminal:1'
      SARAJEVO_2 = 'city=revenue:yellow_10|green_10|brown_50|gray_50,hide:1,groups:Sarajevo;'\
                   'path=a:2,b:_0,terminal:1;path=a:3,b:_0,terminal:1'
      SARAJEVO_3 = 'offboard=revenue:yellow_10|green_10|brown_50|gray_50,groups:Sarajevo;'\
                   'path=a:2,b:_0,terminal:1;path=a:3,b:_0,terminal:1'
      WIEN = 'city=revenue:30;path=a:0,b:_0;city=revenue:30;'\
             'path=a:1,b:_1;city=revenue:30;path=a:2,b:_2;upgrade=cost:20,terrain:water;label=W'

      MINE_1 = 'city=revenue:yellow_10|brown_40;path=a:2,b:_0,terminal:1;path=a:3,b:_0,terminal:1'
      MINE_2 = 'city=revenue:yellow_10|brown_40;path=a:1,b:_0,terminal:1;path=a:5,b:_0,terminal:1'
      MINE_3 = 'city=revenue:yellow_20|brown_60;path=a:1,b:_0,terminal:1;path=a:5,b:_0,terminal:1'
      MINE_4 = 'city=revenue:yellow_10|brown_40;path=a:1,b:_0,terminal:1;path=a:3,b:_0,terminal:1'

      TOWN = 'town=revenue:0'
      TOWN_WITH_WATER = 'town=revenue:0;upgrade=cost:20,terrain:water'
      TOWN_WITH_MOUNTAIN = 'town=revenue:0;upgrade=cost:40,terrain:mountain'
      DOUBLE_TOWN = 'town=revenue:0;town=revenue:0'
      DOUBLE_TOWN_WITH_WATER = 'town=revenue:0;town=revenue:0;upgrade=cost:20,terrain:water'
      CITY = 'city=revenue:0'
      CITY_WITH_WATER = 'city=revenue:0;upgrade=cost:20,terrain:water'
      CITY_WITH_MOUNTAIN = 'city=revenue:0;upgrade=cost:40,terrain:mountain'
      CITY_LABEL_T = 'city=revenue:0;label=T'
      PLAIN = ''
      PLAIN_WITH_MOUNTAIN = 'upgrade=cost:40,terrain:mountain'
      PLAIN_WITH_WATER = 'upgrade=cost:20,terrain:water'

      def base_map
        plain_hexes = %w[B7 B11 B17 B19 B21 C8 C14 C20 C22 C24 D9 D11 D13 D15 D17 E6 E18 E22
                         F9 F13 F15 F21 F25 G6 G12 G14 G22 G24 H9 H13 H19 H21 I10 I12 I14]
        one_town = %w[A8 A20 C10 C16 D25 E20 E24 F19 G2 G20 H11 I20 I22]
        two_towns = %w[B13 B25 F11 I16]
        if option_goods_time
          # Variant Goods Time transform some plain hexes to town(s) hexes
          added_one_town = %w[B7 C8 C20 C22 H21]
          added_two_towns = %w[F25 G24]
          plain_hexes -= added_one_town
          one_town += added_one_town
          plain_hexes -= added_two_towns
          two_towns += added_two_towns
        end
        {
          red: {
            ['A4'] => DRESDEN_1,
            ['A24'] => KIEW_1,
            ['A26'] => KIEW_2,
            ['B3'] => DRESDEN_2,
            ['G28'] => BUKAREST_1,
            ['H27'] => BUKAREST_2,
            ['H1'] => MAINLAND_1,
            ['I2'] => MAINLAND_2,
            ['J11'] => SARAJEVO_1,
            ['J13'] => SARAJEVO_2,
            ['J15'] => SARAJEVO_3,
          },
          gray: {
            ['A12'] => MINE_2,
            ['A22'] => MINE_3,
            ['C6'] => MINE_1,
            ['H25'] => MINE_4,
          },
          white: {
            one_town => TOWN,
            %w[A6 A10] => TOWN_WITH_MOUNTAIN,
            two_towns => DOUBLE_TOWN,
            %w[D19 H3] => CITY_WITH_MOUNTAIN,
            %w[A18 C26 E26 I8] => CITY_LABEL_T,
            %w[B5 B9 B15 B23 C12 E8 F7 F23 G4 G10 G26 H15 H23] => CITY,
            plain_hexes => PLAIN,
            %w[C18 D21 D23 G8 H5 H7] => PLAIN_WITH_MOUNTAIN,
            %w[E10 G16] => PLAIN_WITH_WATER,
            ['E12'] => WIEN,
            ['F17'] => 'city=revenue:20;path=a:0,b:_0;city=revenue:20;path=a:3,b:_1;upgrade=cost:20,terrain:water;'\
                       'label=Bu',
            %w[E14 G18] => CITY_WITH_WATER,
            %w[H17 I18] => TOWN_WITH_WATER,
            ['E16'] => DOUBLE_TOWN_WITH_WATER,
          },
        }
      end

      def cisleithania_map
        # For 3 players Budapest is a city for Pre-staatsbahn U1
        budapest = @players.size == 3 ? 'city' : 'offboard'
        {
          red: {
            ['A4'] => DRESDEN_1,
            ['A24'] => KIEW_1,
            ['A26'] => KIEW_2,
            ['B3'] => DRESDEN_2,
            ['E14'] =>
              'offboard=revenue:yellow_20|green_30|brown_40|gray_40;path=a:0,b:_0,terminal:1;path=a:1,b:_0,terminal:1;'\
              'path=a:2,b:_0,terminal:1;path=a:3,b:_0,terminal:1',
            ['G12'] =>
              "#{budapest}=revenue:yellow_20|green_40|brown_60|gray_70;"\
              'path=a:0,b:_0,terminal:1;path=a:1,b:_0,terminal:1;path=a:2,b:_0,terminal:1;path=a:3,b:_0,terminal:1',
            ['F25'] =>
              'offboard=revenue:yellow_20|green_30|brown_40|gray_40;path=a:2,b:_0,terminal:1;path=a:3,b:_0,terminal:1',
            ['H1'] => MAINLAND_1,
            ['I2'] => MAINLAND_2,
            ['I10'] =>
              'offboard=revenue:yellow_10|green_10|brown_50|gray_50;path=a:1,b:_0,terminal:1;'\
              'path=a:2,b:_0,terminal:1;path=a:3,b:_0,terminal:1',
          },
          gray: {
            ['A12'] => MINE_2,
            ['A22'] => MINE_3,
            ['B17'] => 'path=a:0,b:3;path=a:1,b:4;path=a:1,b:3;path=a:0,b:4',
            ['C6'] => MINE_1,
          },
          white: {
            %w[A8 A20 C10 C16 D25 E24 G2] => TOWN,
            %w[A6 A10] => TOWN_WITH_MOUNTAIN,
            %w[B13 B25 F11] => DOUBLE_TOWN_WITH_WATER,
            %w[H3] => CITY_WITH_MOUNTAIN,
            %w[A18 C26 E26 I8] => CITY_WITH_MOUNTAIN,
            %w[B5 B9 B15 B23 C12 E8 F7 G4 G10] => CITY,
            %w[B7 B11 B19 B21 C8 C14 C20 C22 C24 D9 D11 D13 D15 E6
               F9 F13 G6 H9 H11] => PLAIN,
            %w[D23 G8 H5 H7] => PLAIN_WITH_MOUNTAIN,
            %w[E10] => PLAIN_WITH_WATER,
            ['E12'] => WIEN,
          },
        }
      end
    end
  end
end
