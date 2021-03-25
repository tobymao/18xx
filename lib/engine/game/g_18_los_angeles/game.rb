# frozen_string_literal: true

# rubocop:disable Layout/LineLength

require_relative '../g_1846/game'
require_relative 'meta'
require_relative 'step/draft_distribution'
require_relative 'step/special_token'
require_relative '../stubs_are_restricted'

module Engine
  module Game
    module G18LosAngeles
      class Game < G1846::Game
        include_meta(G18LosAngeles::Meta)

        register_colors(red: '#ff0000',
                        pink: '#ff7fed',
                        orange: '#ff6a00',
                        green: '#00830e',
                        blue: '#0026ff',
                        black: '#727272',
                        lightBlue: '#b8ffff',
                        brown: '#644c00',
                        purple: '#832e9a')

        CERT_LIMIT = {
          2 => { 5 => 19, 4 => 16 },
          3 => { 5 => 14, 4 => 11 },
          4 => { 6 => 12, 5 => 10, 4 => 8 },
          5 => { 7 => 11, 6 => 10, 5 => 8, 4 => 6 },
        }.freeze

        TILES = {
          '5' => 3,
          '6' => 4,
          '7' => 4,
          '8' => 4,
          '9' => 4,
          '14' => 4,
          '15' => 5,
          '16' => 2,
          '17' => 1,
          '18' => 1,
          '19' => 2,
          '20' => 2,
          '21' => 1,
          '22' => 1,
          '23' => 4,
          '24' => 4,
          '25' => 2,
          '26' => 1,
          '27' => 1,
          '28' => 1,
          '29' => 1,
          '30' => 1,
          '31' => 1,
          '39' => 1,
          '40' => 1,
          '41' => 2,
          '42' => 2,
          '43' => 2,
          '44' => 1,
          '45' => 2,
          '46' => 2,
          '47' => 2,
          '51' => 2,
          '57' => 4,
          '70' => 1,
          '290' => 1,
          '291' => 1,
          '292' => 1,
          '293' => 1,
          '294' => 2,
          '295' => 2,
          '296' => 1,
          '297' => 2,
          '298LA' => 1,
          '299LA' => 1,
          '300LA' => 1,
          '611' => 4,
          '619' => 3,
        }.freeze

        LOCATION_NAMES = {
          'A2' => 'Reseda',
          'A4' => 'Van Nuys',
          'A6' => 'Burbank',
          'A8' => 'Pasadena',
          'A10' => 'Lancaster',
          'A12' => 'Victorville',
          'A14' => 'San Bernardino',
          'B1' => 'Oxnard',
          'B3' => 'Beverly Hills',
          'B5' => 'Hollywood',
          'B7' => 'South Pasadena',
          'B9' => 'Alhambra',
          'B11' => 'Azusa',
          'B13' => 'San Dimas',
          'B15' => 'Pomona',
          'C2' => 'Santa Monica',
          'C4' => 'Culver City',
          'C6' => 'Los Angeles',
          'C8' => 'Montebello',
          'C10' => 'Puente',
          'C12' => 'Walnut',
          'C14' => 'Riverside',
          'D3' => 'El Segundo',
          'D5' => 'Gardena',
          'D7' => 'Compton',
          'D9' => 'Norwalk',
          'D11' => 'La Habra',
          'D13' => 'Yorba Linda',
          'D15' => 'Palm Springs',
          'E4' => 'Redondo Beach',
          'E6' => 'Torrance',
          'E8' => 'Long Beach',
          'E10' => 'Cypress',
          'E12' => 'Anaheim',
          'E14' => 'Alta Vista',
          'E16' => 'Corona',
          'F5' => 'San Pedro',
          'F7' => 'Port of Long Beach',
          'F9' => 'Westminster',
          'F11' => 'Garden Grove',
          'F13' => 'Santa Ana',
          'F15' => 'Irvine',
        }.freeze

        COMPANIES = [
          {
            name: 'Gardena Tramway',
            value: 140,
            treasury: 60,
            revenue: 0,
            desc: 'Starts with $60 in treasury, a 2 train, and a token in Gardena (D5). In ORs, this is the first minor to operate. May only lay or upgrade 1 tile per OR. Splits revenue evenly with owner. May be sold to a corporation for up to $140.',
            sym: 'GT',
            color: nil,
          },
          {
            name: 'Orange County Railroad',
            value: 100,
            treasury: 40,
            revenue: 0,
            desc: 'Starts with $40 in treasury, a 2 train, and a token in Cypress (E10). In ORs, this is the second minor to operate. May only lay or upgrade 1 tile per OR. Splits revenue evenly with owner. May be sold to a corporation for up to $100.',
            sym: 'OCR',
            color: nil,
          },
          {
            name: 'Pacific Maritime',
            value: 60,
            revenue: 10,
            desc: 'Reserves a token slot in Long Beach (E8), in the city next to Norwalk (D9). The owning corporation may place an extra token there at no cost, with no connection needed. Once this company is purchased by a corporation, the slot that was reserved may be used by other corporations.',
            sym: 'PMC',
            abilities: [
              {
                type: 'token',
                when: 'owning_corp_or_turn',
                owner_type: 'corporation',
                hexes: ['E8'],
                city: 2,
                price: 0,
                teleport_price: 0,
                count: 1,
                extra: true,
              },
              { type: 'reservation', remove: 'sold', hex: 'E8', city: 2 },
            ],
            color: nil,
          },
          {
            name: 'United States Mail Contract',
            value: 80,
            revenue: 0,
            desc: 'Adds $10 per location visited by any one train of the owning corporation. Never closes once purchased by a corporation.',
            sym: 'MAIL',
            abilities: [
              {
                type: 'close',
                on_phase: 'never',
                owner_type: 'corporation',
              },
            ],
            color: nil,
          },
          {
            name: 'Chino Hills Excavation',
            value: 60,
            revenue: 20,
            desc: 'Reduces, for the owning corporation, the cost of laying all hill tiles and tunnel/pass hexsides by $20.',
            sym: 'CHE',
            abilities: [
              {
                type: 'tile_discount',
                discount: 20,
                terrain: 'mountain',
                owner_type: 'corporation',
              },
            ],
            color: nil,
          },
          {
            name: 'Los Angeles Citrus',
            value: 60,
            revenue: 15,
            desc: 'The owning corporation may assign Los Angeles Citrus to either Riverside (C14) or Port of Long Beach (F7), to add $30 to all routes it runs to this location.',
            sym: 'LAC',
            abilities: [
              {
                type: 'assign_hexes',
                when: 'owning_corp_or_turn',
                hexes: %w[C14 F7],
                count: 1,
                owner_type: 'corporation',
              },
              {
                type: 'assign_corporation',
                when: 'sold',
                count: 1,
                owner_type: 'corporation',
              },
            ],
            color: nil,
          },
          {
            name: 'Los Angeles Steamship',
            value: 40,
            revenue: 10,
            desc: 'The owning corporation may assign the Los Angeles Steamship to one of Oxnard (B1), Santa Monica (C2), Port of Long Beach (F7), or Westminster (F9), to add $20 per port symbol to all routes it runs to this location.',
            sym: 'LAS',
            abilities: [
              {
                type: 'assign_hexes',
                when: 'owning_corp_or_turn',
                hexes: %w[B1 C2 F7 F9],
                count_per_or: 1,
                owner_type: 'corporation',
              },
              {
                type: 'assign_corporation',
                when: 'sold',
                count: 1,
                owner_type: 'corporation',
              },
            ],
            color: nil,
          },
          {
            name: 'South Bay Line',
            value: 40,
            revenue: 15,
            desc: 'The owning corporation may make an extra $0 cost tile upgrade of either Redondo Beach (E4) or Torrance (E6), but not both.',
            sym: 'SBL',
            abilities: [
              {
                type: 'tile_lay',
                when: 'owning_corp_or_turn',
                owner_type: 'corporation',
                free: true,
                hexes: %w[E4 E6],
                tiles: %w[14 15 619],
                special: false,
                count: 1,
              },
            ],
            color: nil,
          },
          {
            name: 'Puente Trolley',
            value: 40,
            revenue: 15,
            desc: 'The owning corporation may lay an extra $0 cost yellow tile in Puente (C10), even if they are not connected to Puente.',
            sym: 'PT',
            abilities: [{ type: 'blocks_hexes', owner_type: 'player', hexes: ['C10'] },
                        {
                          type: 'tile_lay',
                          when: 'owning_corp_or_turn',
                          owner_type: 'corporation',
                          free: true,
                          hexes: ['C10'],
                          tiles: %w[7 8 9],
                          count: 1,
                        }],
            color: nil,
          },
          {
            name: 'Beverly Hills Carriage',
            value: 40,
            revenue: 15,
            desc: 'The owning corporation may lay an extra $0 cost yellow tile in Beverly Hills (B3), even if they are not connected to Beverly Hills. Any terrain costs are ignored.',
            sym: 'BHC',
            abilities: [{ type: 'blocks_hexes', owner_type: 'player', hexes: ['B3'] },
                        {
                          type: 'tile_lay',
                          when: 'owning_corp_or_turn',
                          owner_type: 'corporation',
                          free: true,
                          hexes: ['B3'],
                          tiles: %w[7 8 9],
                          count: 1,
                        }],
            color: nil,
          },
          {
            name: 'Dewey, Cheatham, and Howe',
            value: 40,
            revenue: 10,
            desc: 'The owning corporation may place a token (from their charter, paying the normal cost) in a city they are connected to that does not have any open token slots. If a later tile placement adds a new slot, this token fills that slot. This ability may not be used in Long Beach (E8).',
            sym: 'DC&H',
            min_players: 3,
            abilities: [
              {
                type: 'token',
                when: 'owning_corp_or_turn',
                owner_type: 'corporation',
                count: 1,
                extra: true,
                from_owner: true,
                cheater: 0,
                special_only: true,
                discount: 0,
                hexes: %w[A2
                          A4
                          A6
                          A8
                          B5
                          B7
                          B9
                          B11
                          B13
                          C2
                          C4
                          C6
                          C8
                          C12
                          D5
                          D7
                          D9
                          D11
                          D13
                          E4
                          E6
                          E10
                          E12
                          F7
                          F9
                          F11
                          F13],
              },
            ],
            color: nil,
          },
          {
            name: 'Los Angeles Title',
            value: 40,
            revenue: 10,
            desc: 'The owning corporation may place an Open City token in any unreserved slot except for Long Beach (E8). The owning corporation need not be connected to the city where the token is placed.',
            sym: 'LAT',
            min_players: 3,
            abilities: [
              {
                type: 'token',
                when: 'owning_corp_or_turn',
                owner_type: 'corporation',
                price: 0,
                teleport_price: 0,
                count: 1,
                extra: true,
                special_only: true,
                neutral: true,
                hexes: %w[A4
                          A6
                          A8
                          B5
                          B7
                          B9
                          B11
                          B13
                          C4
                          C6
                          C8
                          C12
                          D5
                          D7
                          D9
                          D11
                          D13
                          E4
                          E6
                          E10
                          E12
                          F7
                          F9
                          F11
                          F13],
              },
            ],
            color: nil,
          },
        ].freeze

        CORPORATIONS = [
          {
            float_percent: 20,
            sym: 'ELA',
            name: 'East Los Angeles & San Pedro Railroad',
            logo: '18_los_angeles/ELA',
            simple_logo: '18_los_angeles/ELA.alt',
            tokens: [0, 80, 80, 80, 80, 80],
            abilities: [
            {
              type: 'token',
              description: 'Reserved $40/$60 Culver City (C4) token',
              hexes: ['C4'],
              price: 40,
              teleport_price: 60,
            },
            { type: 'reservation', hex: 'C4', remove: 'IV' },
          ],
            coordinates: 'C12',
            color: '#ff0000',
            always_market_price: true,
            reservation_color: nil,
          },
          {
            float_percent: 20,
            sym: 'LA',
            name: 'Los Angeles Railway',
            logo: '18_los_angeles/LA',
            simple_logo: '18_los_angeles/LA.alt',
            tokens: [0, 80, 80, 80, 80],
            abilities: [
              {
                type: 'token',
                description: 'Reserved $40 Alhambra (B9) token',
                hexes: ['B9'],
                count: 1,
                price: 40,
              },
              { type: 'reservation', hex: 'B9', remove: 'IV' },
            ],
            coordinates: 'A8',
            color: '#00830e',
            always_market_price: true,
            reservation_color: nil,
          },
          {
            float_percent: 20,
            sym: 'LAIR',
            name: 'Los Angeles and Independence Railroad',
            logo: '18_los_angeles/LAIR',
            simple_logo: '18_los_angeles/LAIR.alt',
            tokens: [0, 80, 80, 80, 80],
            coordinates: 'A2',
            color: '#b8ffff',
            text_color: 'black',
            always_market_price: true,
            reservation_color: nil,
          },
          {
            float_percent: 20,
            sym: 'PER',
            name: 'Pacific Electric Railroad',
            logo: '18_los_angeles/PER',
            simple_logo: '18_los_angeles/PER.alt',
            tokens: [0, 80, 80, 80],
            coordinates: 'F13',
            color: '#ff6a00',
            text_color: 'black',
            always_market_price: true,
            reservation_color: nil,
          },
          {
            float_percent: 20,
            sym: 'SF',
            name: 'Santa Fe Railroad',
            logo: '18_los_angeles/SF',
            simple_logo: '18_los_angeles/SF.alt',
            tokens: [0, 80, 80, 80, 80],
            abilities: [
              {
                type: 'token',
                description: 'Reserved $40 Montebello (C8) token',
                hexes: ['C8'],
                count: 1,
                price: 40,
              },
              { type: 'reservation', hex: 'C8', remove: 'IV' },
            ],
            coordinates: 'D13',
            color: '#ff7fed',
            text_color: 'black',
            always_market_price: true,
            reservation_color: nil,
          },
          {
            float_percent: 20,
            sym: 'SP',
            name: 'Southern Pacific Railroad',
            logo: '18_los_angeles/SP',
            simple_logo: '18_los_angeles/SP.alt',
            tokens: [0, 80, 80, 80, 80],
            abilities: [
              {
                type: 'token',
                description: 'Reserved $40/$100 Los Angeles (C6) token',
                hexes: ['C6'],
                price: 40,
                count: 1,
                teleport_price: 100,
              },
              { type: 'reservation', hex: 'C6', remove: 'IV' },
            ],
            coordinates: 'C2',
            color: '#0026ff',
            always_market_price: true,
            reservation_color: nil,
          },
          {
            float_percent: 20,
            sym: 'UP',
            name: 'Union Pacific Railroad',
            logo: '18_los_angeles/UP',
            simple_logo: '18_los_angeles/UP.alt',
            tokens: [0, 80, 80, 80, 80],
            coordinates: 'B11',
            color: '#727272',
            always_market_price: true,
            reservation_color: nil,
          },
        ].freeze

        MINORS = [
          {
            sym: 'GT',
            name: 'Gardena Tramway',
            logo: '18_los_angeles/GT',
            simple_logo: '18_los_angeles/GT.alt',
            tokens: [0],
            coordinates: 'D5',
            color: '#644c00',
            text_color: 'white',
          },
          {
            sym: 'OCR',
            name: 'Orange County Railroad',
            logo: '18_los_angeles/OCR',
            simple_logo: '18_los_angeles/OCR.alt',
            tokens: [0],
            coordinates: 'E10',
            color: '#832e9a',
            text_color: 'white',
          },
        ].freeze

        HEXES = {
          white: {
            ['C10'] => '',
            ['D3'] => 'upgrade=cost:40,terrain:water',
            ['A4'] => 'city=revenue:0;border=edge:0,type:mountain,cost:20',
            ['B3'] =>
                   'border=edge:3,type:mountain,cost:20;border=edge:4,type:mountain,cost:20',
            ['B9'] =>
                   'city=revenue:0;border=edge:3,type:mountain,cost:20;border=edge:1,type:water,cost:40',
            ['B13'] =>
                   'city=revenue:0;border=edge:2,type:mountain,cost:20;border=edge:3,type:mountain,cost:20;label=Z',
            ['B7'] =>
                   'city=revenue:0;border=edge:4,type:water,cost:40;border=edge:5,type:water,cost:40',
            ['C8'] => 'city=revenue:0;border=edge:2,type:water,cost:40',
            ['D5'] => 'city=revenue:0;border=edge:3,type:water,cost:40',
            ['C12'] => 'city=revenue:0;upgrade=cost:40,terrain:mountain',
            ['D9'] => 'city=revenue:0;border=edge:4,type:water,cost:40;stub=edge:0',
            ['D11'] => 'city=revenue:0;border=edge:1,type:water,cost:40',
            ['E4'] => 'city=revenue:0;icon=image:18_los_angeles/sbl,sticky:1',
            ['E6'] => 'city=revenue:0;icon=image:18_los_angeles/sbl,sticky:1;stub=edge:4',
            ['E10'] => 'city=revenue:0;border=edge:0,type:water,cost:40;stub=edge:1',
            ['E12'] => 'city=revenue:0;label=Z',
            ['E14'] =>
                   'upgrade=cost:40,terrain:mountain;border=edge:5,type:mountain,cost:20',
            %w[A6 C4 F11] => 'city=revenue:0',
            ['D7'] => 'city=revenue:0;stub=edge:5',
          },
          gray: {
            ['B5'] =>
                     'city=revenue:20;path=a:1,b:_0;path=a:2,b:_0;path=a:4,b:_0;path=a:5,b:_0;border=edge:1,type:mountain,cost:20',
            ['C2'] =>
            'city=revenue:10;icon=image:port;icon=image:port;path=a:2,b:_0;path=a:4,b:_0;path=a:5,b:_0;',
            ['D13'] =>
            'city=revenue:20,slots:2;path=a:1,b:_0;path=a:2,b:_0;path=a:4,b:_0;path=a:5,b:_0;',
            ['F9'] =>
            'city=revenue:10;border=edge:3,type:water,cost:40;icon=image:port;icon=image:port;path=a:3,b:_0;path=a:4,b:_0',
            ['F5'] => 'path=a:2,b:3',
            ['a9'] => 'offboard=revenue:0,visit_cost:100;path=a:0,b:_0',
            ['G14'] => 'offboard=revenue:0,visit_cost:100;path=a:2,b:_0',
          },
          red: {
            ['A2'] =>
                     'city=revenue:yellow_30|brown_50,groups:NW;label=N/W;icon=image:1846/20;path=a:4,b:_0,terminal:1;path=a:5,b:_0,terminal:1',
            ['A10'] =>
            'offboard=revenue:yellow_20|brown_40,groups:N|NW|NE;label=N;border=edge:0,type:mountain,cost:20;border=edge:1,type:mountain,cost:20;border=edge:5,type:mountain,cost:20;icon=image:1846/30;path=a:0,b:_0;path=a:1,b:_0;path=a:5,b:_0',
            ['A12'] =>
            'offboard=revenue:yellow_20|brown_40,groups:N|NW|NE;label=N;border=edge:0,type:mountain,cost:20;border=edge:5,type:mountain,cost:20;icon=image:1846/20;path=a:0,b:_0;path=a:5,b:_0',
            ['A14'] =>
            'offboard=revenue:yellow_20|brown_40,groups:NE;label=N/E;border=edge:0,type:mountain,cost:20;icon=image:1846/20;path=a:0,b:_0',
            ['B1'] =>
            'offboard=revenue:yellow_40|brown_10,groups:W|NW|SW;label=W;icon=image:port;icon=image:1846/30;path=a:4,b:_0;path=a:5,b:_0',
            ['B15'] =>
            'offboard=revenue:yellow_20|brown_50,groups:E|NE|SE;label=E;icon=image:1846/30;path=a:1,b:_0',
            ['C14'] =>
            'offboard=revenue:yellow_30|brown_70,groups:E|NE|SE;label=E;icon=image:1846/30;icon=image:18_los_angeles/meat;path=a:1,b:_0;path=a:2,b:_0',
            ['D15'] =>
            'offboard=revenue:yellow_20|brown_40,groups:E|NE|SE;label=E;icon=image:1846/30;path=a:0,b:_0;path=a:1,b:_0',
            ['E16'] =>
            'offboard=revenue:yellow_20|brown_40,groups:SE;label=S/E;icon=image:1846/20;path=a:1,b:_0',
            ['F15'] =>
            'offboard=revenue:yellow_20|brown_50,groups:SE;label=S/E;border=edge:2,type:mountain,cost:20;path=a:1,b:_0;path=a:2,b:_0;icon=image:1846/20',
            ['F7'] =>
            'offboard=revenue:yellow_20|brown_40,groups:S|SE|SW;label=S;path=a:3,b:_0;icon=image:1846/50;icon=image:18_los_angeles/meat;icon=image:port',
          },
          yellow: {
            ['A8'] =>
                     'city=revenue:20;path=a:1,b:_0;path=a:5,b:_0;border=edge:4,type:mountain,cost:20',
            ['B11'] =>
            'city=revenue:20;border=edge:2,type:mountain,cost:20;border=edge:3,type:mountain,cost:20;path=a:1,b:_0;path=a:4,b:_0',
            ['C6'] =>
            'city=revenue:40,slots:2;path=a:0,b:_0;path=a:4,b:_0;label=Z;border=edge:0,type:water,cost:40',
            ['E8'] =>
            'city=revenue:10,groups:LongBeach;city=revenue:10,groups:LongBeach;city=revenue:10,groups:LongBeach;city=revenue:10,groups:LongBeach;path=a:1,b:_0;path=a:2,b:_1;path=a:3,b:_2;path=a:4,b:_3;stub=edge:0;label=LB',
            ['F13'] => 'city=revenue:20,slots:2;path=a:1,b:_0;path=a:3,b:_0',
          },
        }.freeze

        ASSIGNMENT_TOKENS = {
          'LAC' => '/icons/18_los_angeles/lac_token.svg',
          'LAS' => '/icons/1846/sc_token.svg',
        }.freeze

        ORANGE_GROUP = [
          'Beverly Hills Carriage',
          'South Bay Line',
        ].freeze

        BLUE_GROUP = [
          'Chino Hills Excavation',
          'Los Angeles Citrus',
          'Los Angeles Steamship',
        ].freeze

        GREEN_GROUP = %w[LA SF SP].freeze

        REMOVED_CORP_SECOND_TOKEN = {
          'LA' => 'B9',
          'SF' => 'C8',
          'SP' => 'C6',
        }.freeze

        LSL_HEXES = %w[E4 E6].freeze
        LSL_ICON = 'sbl'

        MEAT_HEXES = %w[C14 F7].freeze
        STEAMBOAT_HEXES = %w[B1 C2 F7 F9].freeze

        MEAT_REVENUE_DESC = 'Citrus'

        EVENTS_TEXT = G1846::Game::EVENTS_TEXT.merge(
          'remove_markers' => ['Remove Markers', 'Remove LA Steamship and LA Citrus markers']
        ).freeze

        include StubsAreRestricted

        def setup_turn
          1
        end

        def init_companies(_players)
          companies = super
          companies.reject! { |c| c.sym == 'DC&H' } unless @optional_rules.include?(:dch)
          companies.reject! { |c| c.sym == 'LAT' } unless @optional_rules.include?(:la_title)
          companies
        end

        def init_hexes(_companies, _corporations)
          hexes = super

          hexes.each do |hex|
            hex.ignore_for_axes = true if %w[a9 G14].include?(hex.id)
          end

          hexes
        end

        def num_removals(group)
          return 0 if @players.size == 5
          return 1 if @players.size == 4

          case group
          when ORANGE_GROUP, BLUE_GROUP
            1
          when GREEN_GROUP
            2
          end
        end

        def corporation_removal_groups
          [GREEN_GROUP]
        end

        def place_second_token(corporation, **_kwargs)
          super(corporation, two_player_only: false, cheater: false)
        end

        def init_round
          Round::Draft.new(self,
                           [G18LosAngeles::Step::DraftDistribution],
                           snake_order: true)
        end

        def init_round_finished
          @minors.reject(&:owned_by_player?).each { |m| close_corporation(m) }
          @companies.reject(&:owned_by_player?).sort_by(&:name).each do |company|
            company.close!
            @log << "#{company.name} is removed" unless company.value >= 100
          end
          @draft_finished = true
        end

        def operating_round(round_num)
          @round_num = round_num
          G1846::Round::Operating.new(self, [
            G1846::Step::Bankrupt,
            Engine::Step::Assign,
            G18LosAngeles::Step::SpecialToken,
            Engine::Step::SpecialTrack,
            G1846::Step::BuyCompany,
            G1846::Step::IssueShares,
            G1846::Step::TrackAndToken,
            Engine::Step::Route,
            G1846::Step::Dividend,
            Engine::Step::DiscardTrain,
            G1846::Step::BuyTrain,
            [G1846::Step::BuyCompany, { blocks: true }],
          ], round_num: round_num)
        end

        def num_pass_companies(_players)
          0
        end

        def priority_deal_player
          players = @players.reject(&:bankrupt)
          case @round
          when Round::Draft, Round::Operating
            players.min_by { |p| [p.cash, players.index(p)] }
          when Round::Stock
            players.first
          end
        end

        def reorder_players
          current_order = @players.dup
          @players.sort_by! { |p| [p.cash, current_order.index(p)] }
          @log << "Priority order: #{@players.reject(&:bankrupt).map(&:name).join(', ')}"
        end

        def new_stock_round
          @log << "-- #{round_description('Stock')} --"
          reorder_players
          stock_round
        end

        def meat_packing
          @meat_packing ||= company_by_id('LAC')
        end

        def steamboat
          @steamboat ||= company_by_id('LAS')
        end

        def lake_shore_line
          @lake_shore_line ||= company_by_id('SBL')
        end

        def dch
          @dch ||= company_by_id('DC&H')
        end

        def block_for_steamboat?
          false
        end

        def tile_lays(entity)
          entity.minor? ? [{ lay: true, upgrade: true }] : super
        end

        # unlike in 1846, none of the private companies get 2 tile lays
        def check_special_tile_lay(_action); end

        def east_west_bonus(stops)
          bonus = { revenue: 0 }

          east = stops.find { |stop| stop.tile.label.to_s.include?('E') }
          west = stops.find { |stop| stop.tile.label.to_s.include?('W') }
          north = stops.find { |stop| stop.tile.label.to_s.include?('N') }
          south = stops.find { |stop| stop.tile.label.to_s.include?('S') }
          if east && west
            bonus[:revenue] += east.tile.icons.sum { |icon| icon.name.to_i }
            bonus[:revenue] += west.tile.icons.sum { |icon| icon.name.to_i }
            bonus[:description] = 'E/W'
          elsif north && south
            bonus[:revenue] += north.tile.icons.sum { |icon| icon.name.to_i }
            bonus[:revenue] += south.tile.icons.sum { |icon| icon.name.to_i }
            bonus[:description] = 'N/S'
          end

          bonus
        end

        def compute_other_paths(routes, route)
          routes
            .reject { |r| r == route }
            .select { |r| train_type(route.train) == train_type(r.train) }
            .flat_map(&:paths)
        end

        def train_type(train)
          train.name.include?('/') ? :freight : :passenger
        end

        def check_overlap(routes)
          tracks_by_type = Hash.new { |h, k| h[k] = [] }

          routes.each do |route|
            route.paths.each do |path|
              a = path.a
              b = path.b

              tracks = tracks_by_type[train_type(route.train)]
              tracks << [path.hex, a.num, path.lanes[0][1]] if a.edge?
              tracks << [path.hex, b.num, path.lanes[1][1]] if b.edge?
            end
          end

          tracks_by_type.each do |_type, tracks|
            tracks.group_by(&:itself).each do |k, v|
              raise GameError, "Route cannot reuse track on #{k[0].id}" if v.size > 1
            end
          end
        end

        def next_round!
          @round =
            case @round
            when Round::Stock
              @operating_rounds = @phase.operating_rounds
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
            when init_round.class
              init_round_finished
              new_stock_round
            end
        end

        def train_help(_entity, runnable_trains, _routes)
          trains = runnable_trains.group_by { |t| train_type(t) }

          help = []

          if trains.keys.size > 1
            passenger_trains = trains[:passenger].map(&:name).uniq.sort.join(', ')
            freight_trains = trains[:freight].map(&:name).uniq.sort.join(', ')
            help << "The routes of N trains (#{passenger_trains}) may overlap "\
                    "with the routes of N/M trains (#{freight_trains})."
          end

          super + help
        end

        def east_west_desc
          'E/W or N/S'
        end
      end
    end
  end

  # rubocop:enable Layout/LineLength
end
