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
      # "rules": "https://drive.google.com/file/d/1JuaUSU6fqg6fryN7l_g_r_oFa41rz3zh/view?usp=sharing"
      GAME_DESIGNER = 'Leonhard Orgler & Helmut Ohley'
      # GAME_PUBLISHER Fox in the Box
      # GAME_INFO_URL
      # "bgg": "https://boardgamegeek.com/boardgame/277030/1824-austrian-hungarian-railway-second-edition",
      GAME_END_CHECK = { bankrupt: :immediate }.freeze

      EVENTS_TEXT = Base::EVENTS_TEXT.merge(
        'tokens_removed' => ['Tokens removed', 'Tokens for all private companies removed']
      ).freeze

      STATUS_TEXT = Base::STATUS_TEXT.merge(
        'can_buy_p5' => ['Can buy P5', 'P5 can be bought']
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

      def init_optional_rules(optional_rules)
        opt_rules = super
        validate_optional_rules(opt_rules)
        opt_rules
      end

      def bank_cash
        return super unless option_cislethania

        BANK_CASH_CISLEITHANIA[@players.size] - @players.sum(&:cash)
      end

      def init_bank
        return super unless option_cislethania

        Engine::Bank.new(BANK_CASH_CISLEITHANIA[@players.size], log: @log)
      end

      def init_starting_cash(players, bank)
        return super unless option_cislethania

        players.each do |player|
          bank.spend(CASH_CISLEITHANIA[@players.size], player)
        end
      end

      def init_corporations(stock_market)
        return super unless option_cislethania

        # Remove Coal Railway C4 (SPB) and Regional Railway BH
        CORPORATIONS.reject! { |c| %w[SPB BH].include?(c['sym']) }
        super
      end

      def init_minors
        return super unless option_cislethania

        if @players.size == 2
          # Remove Pre-Staatsbahn U1 and U2
          MINORS.reject! { |m| %w[U1 U2].include?(m['sym']) }
        else
          # Remove Pre-Staatsbahn U2, and move home location for U1
          MINORS.reject! { |m| %w[U2].include?(m['sym']) }
          MINORS.map! do |m|
            next m unless m['sym'] == 'U1'

            m['coordinates'] = 'G12'
            m['city'] = 0
            m
          end
        end
        super
      end

      def init_companies(players)
        mountain_railway_count =
          case players.size
          when 2
            2
          when 3
            option_cislethania ? 3 : 4
          when 4
            6
          when 5
            6
          when 6
            4
          end

        mountain_railway_count.times { |index| COMPANIES << mountain_railway_definition(index) }

        return super unless option_cislethania

        # Remove Pre-Staatsbahn U2 and possibly U1
        p2 = players.size == 2
        COMPANIES.reject! { |m| m['sym'] == 'U2' || (p2 && m['sym'] == 'U1') }
        super
      end

      def init_tiles
        return super unless option_goods_time

        # Goods Time increase count for some town related tiles
        TILES['3'] += 3
        TILES['4'] += 3
        TILES['56'] += 1
        TILES['58'] += 3
        TILES['87'] += 2
        TILES['630'] += 1
        TILES['631'] += 1

        # New tile for Goods Time variant
        TILES['204'] = 3

        super
      end

      def option_cislethania
        @optional_rules&.include?(:cisleithania)
      end

      def option_goods_time
        @optional_rules&.include?(:goods_time)
      end

      def optional_hexes
        return base_map unless option_cislethania

        LOCATION_NAMES['F25'] = 'Kronstadt'
        LOCATION_NAMES['G12'] = 'Budapest'
        LOCATION_NAMES['I10'] = 'Bosnien'
        cislethania_map
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
          Step::BuyTrain,
          [Step::BuyCompany, blocks: true],
        ], round_num: round_num)
      end

      def init_round
        @log << '-- First Stock Round --'
        Round::G1824::FirstStock.new(self, [
          Step::G1824::BuySellParShares,
        ])
      end

      def purchasable_companies(_entity = nil)
        []
      end

      def setup
        g_trains = @depot.upcoming.select { |t| t.name.end_with?('g') }
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

      private

      def coal_railways
        @coal_railways ||= (option_cislethania ? %w[EPP EOD MLB] : %w[EPP EOD MLB SPB])
          .map { |c| corporation_by_id(c) }
      end

      def validate_optional_rules(optional_rules)
        if optional_rules&.include?(:cisleithania)
          raise GameError 'Cisleithania optional rule is for 2-3 players' if @players.size > 3
          raise GameError 'Cannot use Cisleithania and Goods Time at the same time' if option_goods_time
        elsif @players.size < 3
          raise GameError '2 player count requires to use Cisleithania optional rule'
        end
      end

      def mountain_railway_definition(index)
        real_index = index + 1
        {
          sym: "M#{real_index}",
          name: "#{MOUNTAIN_RAILWAY_NAMES[real_index]} (M#{real_index})",
          value: 120,
          revenue: 25,
          desc: "Moutain railway (M#{real_index}). Cannot be sold but can be exchanged for a 10% share in a "\
                'regional railway during phase 3 SR, or when first 4 train is bought. '\
                'If no regional railway shares are available from IPO this private is lost without compensation.',
          abilities: [
            {
              type: 'no_buy',
              owner_type: 'player',
            },
          ],
        }
      end

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
            ['A4'] =>
              'offboard=revenue:yellow_10|green_20|brown_30|gray_40,hide:1,groups:Dresden;'\
              'path=a:4,b:_0,terminal:1;path=a:5,b:_0,terminal:1',
            ['A24'] =>
              'offboard=revenue:yellow_10|green_30|brown_40|gray_50,hide:1,groups:Kiew;'\
              'path=a:0,b:_0,terminal:1;path=a:5,b:_0,terminal:1',
            ['A26'] =>
              'offboard=revenue:yellow_10|green_30|brown_40|gray_50,groups:Kiew;'\
              'path=a:0,b:_0,terminal:1',
            ['B3'] =>
              'offboard=revenue:yellow_10|green_20|brown_30|gray_40,groups:Dresden;'\
              'path=a:4,b:_0,terminal:1',
            ['G28'] =>
              'offboard=revenue:yellow_10|green_30|brown_40|gray_50,hide:1,groups:Bukarest;path=a:1,b:_0,terminal:1',
            ['H27'] =>
              'offboard=revenue:yellow_10|green_30|brown_40|gray_50,groups:Bukarest;path=a:2,b:_0,terminal:1',
            ['H1'] =>
              'offboard=revenue:yellow_10|green_30|brown_50|gray_70,hide:1,groups:Mainland;'\
              'path=a:3,b:_0,terminal:1;path=a:4,b:_0,terminal:1',
            ['I2'] =>
              'offboard=revenue:yellow_10|green_30|brown_50|gray_70,groups:Mainland;path=a:3,b:_0,terminal:1',
            ['J11'] =>
              'offboard=revenue:yellow_10|green_10|brown_50|gray_50,hide:1,groups:Sarajevo;'\
              'path=a:2,b:_0,terminal:1;path=a:3,b:_0,terminal:1',
            ['J13'] =>
              'city=revenue:yellow_10|green_10|brown_50|gray_50,hide:1,groups:Sarajevo;'\
              'path=a:2,b:_0,terminal:1;path=a:3,b:_0,terminal:1',
            ['J15'] =>
              'offboard=revenue:yellow_10|green_10|brown_50|gray_50,groups:Mainland;'\
              'path=a:2,b:_0,terminal:1;path=a:3,b:_0,terminal:1',
          },
          gray: {
            ['A12'] =>
              'city=revenue:yellow_10|brown_40;path=a:1,b:_0,terminal:1;path=a:5,b:_0,terminal:1',
            ['A22'] =>
              'city=revenue:yellow_20|brown_60;path=a:1,b:_0,terminal:1;path=a:5,b:_0,terminal:1',
            ['C6'] =>
              'city=revenue:yellow_10|brown_40;path=a:2,b:_0,terminal:1;path=a:3,b:_0,terminal:1',
            ['H25'] =>
              'city=revenue:yellow_10|brown_40;path=a:1,b:_0,terminal:1;path=a:3,b:_0,terminal:1',
          },
          white: {
            one_town =>
              'town=revenue:0',
            %w[A6 A10] =>
              'town=revenue:0;upgrade=cost:40,terrain:mountain',
            two_towns =>
              'town=revenue:0;town=revenue:0',
            %w[D19 H3] =>
              'city=revenue:0;upgrade=cost:40,terrain:mountain',
            %w[A18 C26 E26 I8] =>
              'city=revenue:0;label=T',
            %w[B5 B9 B15 B23 C12 E8 F7 F23 G4 G10 G26 H15 H23] =>
              'city=revenue:0',
            plain_hexes =>
              '',
            %w[C18 D21 D23 G8 H5 H7] =>
              'upgrade=cost:40,terrain:mountain',
            %w[E10 G16] =>
              'upgrade=cost:20,terrain:water',
            ['E12'] =>
              'city=revenue:30;path=a:0,b:_0;city=revenue:30;'\
              'path=a:1,b:_1;city=revenue:30;path=a:2,b:_2;upgrade=cost:20,terrain:water;label=W',
            ['F17'] =>
              'city=revenue:20;path=a:0,b:_0;city=revenue:20;path=a:3,b:_1;upgrade=cost:20,terrain:water;label=Bu',
            %w[E14 G18] =>
              'city=revenue:0;upgrade=cost:20,terrain:water',
            %w[H17 I18] =>
              'town=revenue:0;upgrade=cost:20,terrain:water',
            ['E16'] =>
              'town=revenue:0;town=revenue:0;upgrade=cost:20,terrain:water',
          },
        }
      end

      def cislethania_map
        # For 3 players Budapest is a city for Pre-staatsbahn U1
        budapest = @players.size == 3 ? 'city' : 'offboard'
        {
          red: {
            ['A4'] =>
              'offboard=revenue:yellow_10|green_20|brown_30|gray_40,hide:1,groups:Dresden;'\
              'path=a:4,b:_0,terminal:1;path=a:5,b:_0,terminal:1',
            ['A24'] =>
              'offboard=revenue:yellow_10|green_30|brown_40|gray_50,hide:1,groups:Kiew;'\
              'path=a:0,b:_0,terminal:1;path=a:5,b:_0,terminal:1',
            ['A26'] =>
              'offboard=revenue:yellow_10|green_30|brown_40|gray_50,groups:Kiew;'\
              'path=a:0,b:_0,terminal:1',
            ['B3'] =>
              'offboard=revenue:yellow_10|green_20|brown_30|gray_40,groups:Dresden;'\
              'path=a:4,b:_0,terminal:1',
            ['E14'] =>
              'offboard=revenue:yellow_20|green_30|brown_40|gray_40;path=a:0,b:_0,terminal:1;path=a:1,b:_0,terminal:1;'\
              'path=a:2,b:_0,terminal:1;path=a:3,b:_0,terminal:1',
            ['G12'] =>
              "#{budapest}=revenue:yellow_20|green_40|brown_60|gray_70;"\
              'path=a:0,b:_0,terminal:1;path=a:1,b:_0,terminal:1;path=a:2,b:_0,terminal:1;path=a:3,b:_0,terminal:1',
            ['F25'] =>
              'offboard=revenue:yellow_20|green_30|brown_40|gray_40;path=a:2,b:_0,terminal:1;path=a:3,b:_0,terminal:1',
            ['H1'] =>
              'offboard=revenue:yellow_10|green_30|brown_50|gray_70,hide:1,groups:Mainland;'\
              'path=a:3,b:_0,terminal:1;path=a:4,b:_0,terminal:1',
            ['I2'] =>
              'offboard=revenue:yellow_10|green_30|brown_50|gray_70,groups:Mainland;path=a:3,b:_0,terminal:1',
            ['I10'] =>
              'offboard=revenue:yellow_10|green_10|brown_50|gray_50;path=a:1,b:_0,terminal:1;'\
              'path=a:2,b:_0,terminal:1;path=a:3,b:_0,terminal:1',
          },
          gray: {
            ['A12'] =>
              'city=revenue:yellow_10|brown_40;path=a:1,b:_0,terminal:1;path=a:5,b:_0,terminal:1',
            ['A22'] =>
              'city=revenue:yellow_20|brown_60;path=a:1,b:_0,terminal:1;path=a:5,b:_0,terminal:1',
            ['C6'] =>
              'city=revenue:yellow_10|brown_40;path=a:2,b:_0,terminal:1;path=a:3,b:_0,terminal:1',
            ['B17'] =>
              'path=a:0,b:3;path=a:1,b:4;path=a:1,b:3;path=a:0,b:4',
          },
          white: {
            %w[A8 A20 C10 C16 D25 E24 G2] =>
              'town=revenue:0',
            %w[A6 A10] =>
              'town=revenue:0;upgrade=cost:40,terrain:mountain',
            %w[B13 B25 F11] =>
              'town=revenue:0;town=revenue:0',
            %w[H3] =>
              'city=revenue:0;upgrade=cost:40,terrain:mountain',
            %w[A18 C26 E26 I8] =>
              'city=revenue:0;label=T',
            %w[B5 B9 B15 B23 C12 E8 F7 G4 G10] =>
              'city=revenue:0',
            %w[B7 B11 B19 B21 C8 C14 C20 C22 C24 D9 D11 D13 D15 E6
               F9 F13 G6 H9 H11] =>
              '',
            %w[D23 G8 H5 H7] =>
              'upgrade=cost:40,terrain:mountain',
            %w[E10] =>
              'upgrade=cost:20,terrain:water',
            ['E12'] =>
              'city=revenue:30;path=a:0,b:_0;city=revenue:30;'\
              'path=a:1,b:_1;city=revenue:30;path=a:2,b:_2;upgrade=cost:20,terrain:water;label=W',
          },
        }
      end
    end
  end
end
