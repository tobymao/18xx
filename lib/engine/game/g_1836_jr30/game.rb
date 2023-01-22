# frozen_string_literal: true

require_relative 'meta'
require_relative '../base'

module Engine
  module Game
    module G1836Jr30
      class Game < Game::Base
        include_meta(G1836Jr30::Meta)

        CURRENCY_FORMAT_STR = '%s F'

        BANK_CASH = 6000

        CERT_LIMIT = { 2 => 20, 3 => 13, 4 => 10 }.freeze

        STARTING_CASH = { 2 => 900, 3 => 600, 4 => 450 }.freeze

        TILES = {
          '2' => 1,
          '3' => 2,
          '4' => 2,
          '7' => 4,
          '8' => 8,
          '9' => 7,
          '14' => 3,
          '15' => 2,
          '16' => 1,
          '18' => 1,
          '19' => 1,
          '20' => 1,
          '23' => 3,
          '24' => 3,
          '25' => 1,
          '26' => 1,
          '27' => 1,
          '28' => 1,
          '29' => 1,
          '39' => 1,
          '40' => 1,
          '41' => 2,
          '42' => 2,
          '43' => 2,
          '44' => 1,
          '45' => 2,
          '46' => 2,
          '47' => 1,
          '53' => 2,
          '54' => 1,
          '56' => 1,
          '57' => 4,
          '58' => 2,
          '59' => 2,
          '61' => 2,
          '62' => 1,
          '63' => 3,
          '64' => 1,
          '65' => 1,
          '66' => 1,
          '67' => 1,
          '68' => 1,
          '70' => 1,
        }.freeze

        LOCATION_NAMES = {
          'A9' => 'Leeuwarden',
          'A13' => 'Hamburg',
          'B8' => 'Enkhuizen & Stavoren',
          'B10' => 'Groningen',
          'D6' => 'Amsterdam',
          'E5' => 'Rotterdam & Den Haag',
          'E7' => 'Utrecht',
          'E11' => 'Arnhem & Nijmegen',
          'F4' => 'Hoek van Holland',
          'F10' => 'Eindhoven',
          'G7' => 'Antwerp',
          'H2' => 'Bruges',
          'H4' => 'Gand',
          'H6' => 'Brussels',
          'H10' => 'Maastricht & Liège',
          'I3' => 'Lille',
          'I9' => 'Namur',
          'J6' => 'Charleroi',
          'J8' => 'Hainaut Coalfields',
          'E3' => 'Harwich',
          'G1' => 'Dover',
          'J2' => 'Paris',
          'E13' => 'Dortmund',
          'H12' => 'Cologne',
          'K11' => 'Arlon & Luxembourg',
          'K13' => 'Strasbourg',
        }.freeze

        MARKET = [
          %w[60y
             67
             71
             76
             82
             90
             100p
             112
             126
             142
             160
             180
             200
             225
             250
             275
             300
             325
             350],
          %w[53y
             60y
             66
             70
             76
             82
             90p
             100
             112
             126
             142
             160
             180
             200
             220
             240
             260
             280
             300],
          %w[46y
             55y
             60y
             65
             70
             76
             82p
             90
             100
             111
             125
             140
             155
             170
             185
             200],
          %w[39o
             48y
             54y
             60y
             66
             71
             76p
             82
             90
             100
             110
             120
             130],
          %w[32o 41o 48y 55y 62 67 71p 76 82 90 100],
          %w[25b 34o 42o 50y 58y 65 67p 71 75 80],
          %w[18b 27b 36o 45o 54y 63 67 69 70],
          %w[10b 20b 30b 40o 50y 60y 67 68],
          ['', '10b', '20b', '30b', '40o', '50y', '60y'],
          ['', '', '10b', '20b', '30b', '40o', '50y'],
          ['', '', '', '10b', '20b', '30b', '40o'],
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
                    tiles: %i[yellow green brown],
                    operating_rounds: 3,
                  }].freeze

        TRAINS = [{ name: '2', distance: 2, price: 80, rusts_on: '4', num: 5 },
                  { name: '3', distance: 3, price: 180, rusts_on: '6', num: 4 },
                  { name: '4', distance: 4, price: 300, rusts_on: 'D', num: 3 },
                  {
                    name: '5',
                    distance: 5,
                    price: 450,
                    num: 2,
                    events: [{ 'type' => 'close_companies' }],
                  },
                  { name: '6', distance: 6, price: 630, num: 2 },
                  {
                    name: 'D',
                    distance: 999,
                    price: 1100,
                    num: 5,
                    available_on: '6',
                    discount: { '4' => 300, '5' => 300, '6' => 300 },
                  }].freeze

        COMPANIES = [
          {
            name: 'Amsterdam Canal Company',
            value: 20,
            revenue: 5,
            desc: 'No special ability. Blocks hex D6 while owned by player.',
            sym: 'ACC',
            abilities: [{ type: 'blocks_hexes', owner_type: 'player', hexes: ['D6'] }],
          },
          {
            name: 'Enkhuizen-Stavoren Ferry',
            value: 40,
            revenue: 10,
            desc: 'Owning corporation may place a free tile on the E-SF hex B8 (the IJsselmeer Causeway) free of cost'\
                  ', in addition to its own tile placement. Blocks hex B8 while owned by player.',
            sym: 'E-SF',
            abilities: [{ type: 'blocks_hexes', owner_type: 'player', hexes: ['B8'] },
                        {
                          type: 'tile_lay',
                          owner_type: 'corporation',
                          free: true,
                          hexes: ['B8'],
                          tiles: %w[2 56],
                          when: 'owning_corp_or_turn',
                          count: 1,
                        }],
          },
          {
            name: 'Charbonnages du Hainaut',
            value: 70,
            revenue: 15,
            desc: 'Owning corporation may place a tile and station token in the CdH hex J8 for only the F60 cost of'\
                  ' the mountain. The track is not required to be connected to existing track of this corporation (or any'\
                  " corporation), and can be used as a teleport. This counts as the corporation's track lay for that turn."\
                  ' Blocks hex J8 while owned by player.',
            sym: 'CdH',
            abilities: [{ type: 'blocks_hexes', owner_type: 'player', hexes: ['J8'] },
                        {
                          type: 'teleport',
                          owner_type: 'corporation',
                          tiles: ['57'],
                          hexes: ['J8'],
                        }],
          },
          {
            name: 'Grand Central Belge',
            value: 110,
            revenue: 20,
            desc: 'Owning player may exchange the GCB for a 10% certificate of the Chemins de Fer de L’Etat Belge (B)'\
                  ' from the bank or the bank pool, subject to normal certificate limits. This closes the private company.'\
                  ' The exchange may be made a) in a stock round, during the player’s turn or between the turns of other'\
                  ' players, or b) in an operating round, between the turns of corporations. Blocks hexes G7, G9, & H10'\
                  ' while owned by player.',
            sym: 'GCB',
            abilities: [
              {
                type: 'exchange',
                corporations: ['B'],
                owner_type: 'player',
                from: %w[ipo market],
              },
              {
                type: 'blocks_hexes',
                owner_type: 'player',
                hexes: %w[G7 G9 H10],
              },
            ],
          },
          {
            name: 'Chemins de Fer Luxembourgeois',
            value: 160,
            revenue: 25,
            desc: 'Upon purchase, the owning player receives a 10% certificate of the Grande Compagnie du Luxembourg'\
                  ' (GCL). This certificate may only be sold once the GCL President’s Certificate has been purchased and a'\
                  ' par price set, subject to standard rules. Blocks hexes K11 & J12 while owned by player.',
            sym: 'CFL',
            abilities: [{ type: 'shares', shares: 'GCL_1' },
                        {
                          type: 'blocks_hexes',
                          owner_type: 'player',
                          hexes: %w[K11 J12],
                        }],
          },
          {
            name: 'Chemin de Fer de Lille à Valenciennes',
            value: 220,
            revenue: 30,
            desc: 'Upon purchase, the owning player receives the President’s Certificate of the Chemin de Fer du Nord'\
                  ' (Nord) and must immediately set the par price. This private company may not be bought by a corporation,'\
                  ' and closes when the Nord buys its first train. Blocks hexes I3 & J4 while owned by player.',
            sym: 'CFLV',
            abilities: [{ type: 'shares', shares: 'Nord_0' },
                        { type: 'close', when: 'bought_train', corporation: 'Nord' },
                        { type: 'no_buy' },
                        {
                          type: 'blocks_hexes',
                          owner_type: 'player',
                          hexes: %w[I3 J4],
                        }],
          },
        ].freeze

        CORPORATIONS = [
          {
            sym: 'B',
            name: "Chemins de Fer de L'État Belge",
            logo: '1836_jr/B',
            simple_logo: '1836_jr/B.alt',
            tokens: [0, 40, 100, 100],
            coordinates: 'H6',
            color: 'black',
          },
          {
            sym: 'GCL',
            name: 'Grande Compagnie du Luxembourg',
            logo: '1836_jr/GCL',
            simple_logo: '1836_jr/GCL.alt',
            tokens: [0, 40, 100, 100],
            coordinates: 'I9',
            color: 'green',
          },
          {
            sym: 'Nord',
            name: 'Chemin de Fer du Nord',
            logo: '1836_jr/Nord',
            simple_logo: '1836_jr/Nord.alt',
            tokens: [0, 40, 100],
            coordinates: 'I3',
            color: 'darkblue',
          },
          {
            sym: 'NBDS',
            name: 'Noord-Brabantsch-Duitsche Spoorweg-Maatschappij',
            logo: '1836_jr/NBDS',
            simple_logo: '1836_jr/NBDS.alt',
            tokens: [0, 40, 100],
            coordinates: 'E11',
            color: '#ffcd05',
            text_color: 'black',
          },
          {
            sym: 'HSM',
            name: 'Hollandsche IJzeren Spoorweg Maatschappij',
            logo: '1836_jr/HSM',
            simple_logo: '1836_jr/HSM.alt',
            tokens: [0, 40],
            coordinates: 'D6',
            color: '#f26722',
          },
          {
            sym: 'NFL',
            name: 'Noord-Friesche Locaal',
            logo: '1836_jr/NFL',
            simple_logo: '1836_jr/NFL.alt',
            tokens: [0, 40],
            coordinates: 'A9',
            color: '#90ee90',
            text_color: 'black',
          },
        ].freeze

        HEXES = {
          gray: { ['A9'] => 'city=revenue:10;path=a:0,b:_0;path=a:_0,b:5' },
          white: {
            %w[A11 B12 C11 D12 E9 H8 I5 I7 K5 J4] => 'blank',
            ['C7'] => 'border=edge:4,type:impassable,color:blue',
            ['C9'] => 'border=edge:1,type:impassable,color:blue',
            ['G3'] => 'border=edge:3,type:impassable,color:blue',
            ['G5'] => 'border=edge:2,type:impassable,color:blue;border=edge:3,type:impassable,color:blue',
            ['B8'] => 'town=revenue:0;town=revenue:0;upgrade=cost:80,terrain:water',
            %w[B10 E7 G7 H4 J6] => 'city=revenue:0',
            %w[D8 D10 F8 G9 G11] => 'upgrade=cost:40,terrain:water',
            ['F4'] =>
            'town=revenue:0;upgrade=cost:40,terrain:water;'\
            'border=edge:0,type:impassable,color:blue;border=edge:5,type:impassable,color:blue',
            ['F6'] => 'upgrade=cost:80,terrain:water;border=edge:0,type:impassable,color:blue',
            %w[F10 H2] => 'town=revenue:0',
            %w[I11 J10 J12 K7 K9] => 'upgrade=cost:60,terrain:mountain',
            ['I9'] => 'city=revenue:0;upgrade=cost:40,terrain:water',
            ['J8'] => 'city=revenue:0;upgrade=cost:60,terrain:mountain',
            ['K11'] => 'town=revenue:0;town=revenue:0;upgrade=cost:60,terrain:mountain',
          },
          red: {
            ['A13'] => 'offboard=revenue:yellow_40|brown_70;path=a:0,b:_0;path=a:1,b:_0',
            %w[E13 H12] => 'offboard=revenue:yellow_30|brown_50;path=a:1,b:_0',
            ['K13'] => 'offboard=revenue:yellow_40|brown_70;path=a:1,b:_0;path=a:2,b:_0',
          },
          yellow: {
            ['D6'] =>
                     'city=revenue:40;path=a:0,b:_0;path=a:_0,b:5;label=NY;upgrade=cost:40,terrain:water',
            ['E5'] => 'city=revenue:0;city=revenue:0;label=OO',
            %w[E11 H10] =>
            'city=revenue:0;city=revenue:0;label=OO;upgrade=cost:40,terrain:water',
            ['H6'] => 'city=revenue:30;path=a:1,b:_0;path=a:_0,b:3;label=B',
            ['I3'] => 'city=revenue:30;path=a:0,b:_0;path=a:_0,b:4;label=B',
          },
          blue: {
            %w[E3 G1] =>
            'offboard=revenue:green_20|brown_30,format:+%s,groups:port,route:never;path=a:4,b:_0;path=a:5,b:_0',
          },
          green: {
            ['J2'] =>
            'offboard=revenue:green_20|brown_30,format:+%s,groups:port,route:never;path=a:3,b:_0;path=a:4,b:_0',
          },
        }.freeze

        LAYOUT = :pointy

        SELL_BUY_ORDER = :sell_buy_sell
        TRACK_RESTRICTION = :permissive
        TILE_RESERVATION_BLOCKS_OTHERS = :always

        def operating_round(round_num)
          Round::Operating.new(self, [
            Engine::Step::Bankrupt,
            Engine::Step::Exchange,
            Engine::Step::SpecialTrack,
            Engine::Step::SpecialToken,
            Engine::Step::BuyCompany,
            Engine::Step::HomeToken,
            Engine::Step::Track,
            Engine::Step::Token,
            Engine::Step::Route,
            Engine::Step::Dividend,
            Engine::Step::DiscardTrain,
            Engine::Step::BuySingleTrainOfType,
            [Engine::Step::BuyCompany, { blocks: true }],
          ], round_num: round_num)
        end

        def revenue_for(route, stops)
          revenue = super

          port = stops.find { |stop| stop.groups.include?('port') }

          if port
            raise GameError, "#{port.tile.location_name} must contain 2 other stops" if stops.size < 3

            per_token = port.route_revenue(route.phase, route.train)
            revenue -= per_token # It's already been counted, so remove

            revenue += stops.sum do |stop|
              next per_token if stop.city? && stop.tokened_by?(route.train.owner)

              0
            end
          end

          revenue
        end

        def multiple_buy_only_from_market?
          !optional_rules&.include?(:multiple_brown_from_ipo)
        end
      end
    end
  end
end
