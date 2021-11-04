# frozen_string_literal: true

require_relative '../g_1822/game'
require_relative 'meta'

module Engine
  module Game
    module G1822NRS
      class Game < G1822::Game
        include_meta(G1822NRS::Meta)

        BIDDING_BOX_START_MINOR = nil

        CERT_LIMIT = { 3 => 16, 4 => 13, 5 => 10, 6 => 9, 7 => 8 }.freeze

        EXCHANGE_TOKENS = {
          'LNWR' => 4,
          'CR' => 3,
          'MR' => 3,
          'LYR' => 3,
          'NBR' => 3,
          'NER' => 3,
        }.freeze

        MINOR_14_ID = nil

        STARTING_CASH = { 3 => 500, 4 => 375, 5 => 300, 6 => 250, 7 => 215 }.freeze

        STARTING_COMPANIES = %w[P1 P2 P3 P4 P6 P7 P8 P9 P11 P12 P13 P14 P15 P16 P18 P19 P20 P21
                                C1 C5 C6 C7 C8 C10 M1 M2 M3 M4 M5 M6 M7 M8 M9 M10 M15
                                M16 M26 M27 M28 M29].freeze

        STARTING_CORPORATIONS = %w[1 2 3 4 5 6 7 8 9 10 15 16 26 27 28 29
                                   LNWR CR MR LYR NBR NER].freeze

        STARTING_COMPANIES_OVERRIDE = {
          'M15' => { desc: 'A 50% director’s certificate in the associated minor company. Starting location is N29.' },
          'M16' => { desc: 'A 50% director’s certificate in the associated minor company. Starting location is M30.' },
          'M29' => { desc: 'A 50% director’s certificate in the associated minor company. Starting location is E26.' },
        }.freeze

        STARTING_CORPORATIONS_OVERRIDE = {
          '15' => { coordinates: 'N29', city: 1 },
          '16' => { coordinates: 'M30', city: 0 },
          '29' => { coordinates: 'E26' },
          'LNWR' => { coordinates: 'N29', city: 0 },
        }.freeze

        LOCATION_NAMES = {
          'D11' => 'Stranraer',
          'E2' => 'Highlands',
          'E6' => 'Glasgow',
          'E26' => 'Mid Wales',
          'F3' => 'Stirling',
          'F5' => 'Castlecary',
          'F7' => 'Hamilton & Coatbridge',
          'F11' => 'Dumfries',
          'F23' => 'Holyhead',
          'G4' => 'Falkirk',
          'G12' => 'Carlisle',
          'G16' => 'Barrow',
          'G20' => 'Blackpool',
          'G22' => 'Liverpool',
          'G24' => 'Chester',
          'G28' => 'Shrewbury',
          'H1' => 'Aberdeen',
          'H3' => 'Dunfermline',
          'H5' => 'Edinburgh',
          'H13' => 'Penrith',
          'H17' => 'Lancaster',
          'H19' => 'Preston',
          'H21' => 'Wigan & Bolton',
          'H23' => 'Warrington',
          'H25' => 'Crewe',
          'I22' => 'Manchester',
          'I26' => 'Stoke-on-Trent',
          'I30' => 'Birmingham',
          'J15' => 'Darlington',
          'J21' => 'Bradford',
          'J29' => 'Derby',
          'K10' => 'Newcastle',
          'K12' => 'Durham',
          'K14' => 'Middlesbrough',
          'K20' => 'Leeds',
          'K24' => 'Sheffield',
          'K28' => 'Nottingham',
          'L19' => 'York',
          'L33' => 'Northampton',
          'M16' => 'Scarborough',
          'M26' => 'Lincoln',
          'M30' => 'London',
          'N21' => 'Hull',
          'N23' => 'Grimsby',
          'N29' => 'London',
        }.freeze

        HEXES = {
          white: {
            %w[C10 D9 E8 E12 G2 G6 G26 H11 H27 H29 I6 I28 J9 J11 J13 J17 J27
               K8 K16 K18 K22 K26 K30 L15 L17 L23 L25 L27 L29 M18 M20 M24 N19
               N25 N27] =>
              '',
            ['G10'] =>
              'border=edge:0,type:water,cost:40',
            %w[L21 M28] =>
              'upgrade=cost:20,terrain:swamp',
            %w[M22] =>
              'upgrade=cost:40,terrain:swamp',
            %w[G14 I12 I24] =>
              'upgrade=cost:40,terrain:hill',
            %w[E10 F9 G8 H7 H9 H15 I8 I10 J7 J23 J25] =>
              'upgrade=cost:60,terrain:hill',
            %w[I14 I16 I18 I20 J19] =>
              'upgrade=cost:80,terrain:mountain',
            %w[D11 F3 F5 G20 G28 H13 H25 I26 K12 M16 M26] =>
              'town=revenue:0',
            ['H17'] =>
              'town=revenue:0;border=edge:2,type:impassable',
            ['H3'] =>
              'town=revenue:0;border=edge:1,type:impassable;border=edge:0,type:water,cost:40',
            ['F11'] =>
              'town=revenue:0;border=edge:5,type:impassable',
            %w[F7 H21] =>
              'town=revenue:0;town=revenue:0',
            ['G24'] =>
              'town=revenue:0;upgrade=cost:40,terrain:swamp',
            ['J21'] =>
              'town=revenue:0;upgrade=cost:60,terrain:hill',
            %w[H19 J15 J29 K10 K14 K20 K24 K28] =>
              'city=revenue:0',
            ['G4'] =>
              'city=revenue:0;border=edge:4,type:impassable',
            ['G16'] =>
              'city=revenue:0;border=edge:5,type:impassable',
            ['G12'] =>
              'city=revenue:0;border=edge:2,type:impassable;border=edge:3,type:water,cost:40',
            ['L19'] =>
              'city=revenue:0;upgrade=cost:20,terrain:swamp',
            ['H23'] =>
              'city=revenue:0;upgrade=cost:40,terrain:swamp',
            ['N21'] =>
              'city=revenue:0;upgrade=cost:20,terrain:swamp;border=edge:0,type:water,cost:40',
            ['N23'] =>
              'city=revenue:0;upgrade=cost:20,terrain:swamp;border=edge:3,type:water,cost:40',
          },
          yellow: {
            ['G22'] =>
              'city=revenue:30,slots:2;path=a:0,b:_0;path=a:3,b:_0;path=a:5,b:_0;label=Y',
            ['H5'] =>
              'city=revenue:30,slots:2;path=a:1,b:_0;path=a:2,b:_0;path=a:5,b:_0;border=edge:3,type:water,cost:40;'\
              'label=Y',
            ['I22'] =>
              'city=revenue:40,slots:2;path=a:0,b:_0;path=a:1,b:_0;path=a:4,b:_0;upgrade=cost:60,terrain:hill;'\
              'label=BM',
          },
          gray: {
            ['E2'] =>
              'city=revenue:yellow_10|green_10|brown_20|gray_20,slots:2;path=a:0,b:_0,terminal:1;'\
              'path=a:5,b:_0,terminal:1',
            ['E4'] =>
              'path=a:0,b:3',
            ['E6'] =>
              'city=revenue:yellow_40|green_50|brown_60|gray_70,slots:3,loc:1;path=a:0,b:_0;path=a:3,b:_0;'\
              'path=a:4,b:_0;path=a:5,b:_0',
            ['E26'] =>
              'city=revenue:yellow_10|green_20|brown_20|gray_30,slots:3,loc:1.5;'\
              'path=a:4,b:_0,lanes:2,terminal:1;path=a:5,b:_0,lanes:2,terminal:1',
            ['F23'] =>
              'city=revenue:yellow_20|green_20|brown_30|gray_40,slots:2;path=a:5,b:_0,terminal:1',
            ['F25'] =>
              'path=a:1,b:4,a_lane:2.0;path=a:1,b:5,a_lane:2.1',
            ['F27'] =>
              'path=a:2,b:4,a_lane:2.0;path=a:2,b:5,a_lane:2.1',
            ['H1'] =>
              'city=revenue:yellow_30|green_40|brown_50|gray_60,slots:2;path=a:0,b:_0,terminal:1;'\
              'path=a:1,b:_0,terminal:1',
            ['I30'] =>
              'city=revenue:yellow_40|green_50|brown_60|gray_80,slots:2;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0',
            ['M30'] =>
              'city=revenue:yellow_40|green_60|brown_80|gray_100,slots:1,groups:London;path=a:2,b:_0',
            ['N29'] =>
              'city=revenue:yellow_40|green_60|brown_80|gray_100,slots:1,loc:1.5,groups:London;path=a:2,b:_0;'\
              'city=revenue:yellow_40|green_60|brown_80|gray_100,slots:1,loc:4,groups:London;path=a:3,b:_1',
          },
          blue: {
            %w[L11 R31] =>
              'junction;path=a:2,b:_0,terminal:1',
            ['F17'] =>
              'junction;path=a:4,b:_0,terminal:1',
            %w[F15 F21] =>
              'junction;path=a:5,b:_0,terminal:1',
          },
        }.freeze

        MARKET = [
          ['', '', '', '', '', '', '', '', '', '', '', '', '',
           '330', '360', '400', '450', '500e', '550e', '600e'],
          ['', '', '', '', '', '', '', '', '',
           '200', '220', '245', '270', '300', '330', '360', '400', '450', '500e', '550e'],
          %w[70 80 90 100 110 120 135 150 165 180 200 220 245 270 300 330 360 400 450 500e],
          %w[60 70 80 90 100px 110 120 135 150 165 180 200 220 245 270 300 330 360 400 450],
          %w[50 60 70 80 90px 100 110 120 135 150 165 180 200 220 245 270 300 330],
          %w[45y 50 60 70 80px 90 100 110 120 135 150 165 180 200 220 245],
          %w[40y 45y 50 60 70px 80 90 100 110 120 135 150 165 180],
          %w[35y 40y 45y 50 60px 70 80 90 100 110 120 135],
          %w[30y 35y 40y 45y 50p 60 70 80 90 100],
          %w[25y 30y 35y 40y 45y 50 60 70 80],
          %w[20y 25y 30y 35y 40y 45y 50y 60y],
          %w[15y 20y 25y 30y 35y 40y 45y],
          %w[10y 15y 20y 25y 30y 35y],
          %w[5y 10y 15y 20y 25y],
        ].freeze

        TILES = {
          '1' => 1,
          '2' => 1,
          '3' => 5,
          '4' => 5,
          '5' => 5,
          '6' => 6,
          '7' => 'unlimited',
          '8' => 'unlimited',
          '9' => 'unlimited',
          '55' => 1,
          '56' => 1,
          '57' => 5,
          '58' => 5,
          '69' => 1,
          '14' => 5,
          '15' => 5,
          '80' => 5,
          '81' => 5,
          '82' => 6,
          '83' => 6,
          '141' => 3,
          '142' => 3,
          '143' => 3,
          '144' => 3,
          '207' => 2,
          '208' => 1,
          '619' => 5,
          '63' => 6,
          '544' => 6,
          '545' => 6,
          '546' => 8,
          '611' => 3,
          '60' => 2,
          'X2' =>
            {
              'count' => 1,
              'color' => 'green',
              'code' =>
                'city=revenue:50,slots:3;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;'\
                'path=a:4,b:_0;label=BM',
            },
          '768' =>
            {
              'count' => 3,
              'color' => 'brown',
              'code' =>
                'town=revenue:10;path=a:0,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:5,b:_0',
            },
          '767' =>
            {
              'count' => 3,
              'color' => 'brown',
              'code' =>
                'town=revenue:10;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0',
            },
          '769' =>
            {
              'count' => 4,
              'color' => 'brown',
              'code' =>
                'town=revenue:10;path=a:0,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0',
            },
          'X5' =>
            {
              'count' => 2,
              'color' => 'brown',
              'code' =>
                'city=revenue:50,slots:3;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;'\
                'path=a:4,b:_0;label=Y',
            },
          'X7' =>
            {
              'count' => 1,
              'color' => 'brown',
              'code' =>
                'city=revenue:60,slots:4;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;'\
                'path=a:5,b:_0;label=BM',
            },
          '169' =>
            {
              'count' => 2,
              'color' => 'gray',
              'code' =>
                'junction;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0',
            },
          'X11' =>
            {
              'count' => 2,
              'color' => 'gray',
              'code' =>
                'city=revenue:60,slots:3;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;label=Y',
            },
          'X13' =>
            {
              'count' => 1,
              'color' => 'gray',
              'code' =>
                'city=revenue:80,slots:4;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;'\
                'path=a:5,b:_0;label=BM',
            },
          'X17' =>
            {
              'count' => 2,
              'color' => 'gray',
              'code' =>
                'town=revenue:10;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0',
            },
          'X18' =>
            {
              'count' => 2,
              'color' => 'gray',
              'code' =>
                'city=revenue:50,slots:3;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0',
            },
          'X19' =>
            {
              'count' => 4,
              'color' => 'gray',
              'code' =>
                'city=revenue:50,slots:3;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;'\
                'path=a:5,b:_0',
            },
        }.freeze

        TRAINS = [
          {
            name: 'L',
            distance: [
              {
                'nodes' => ['city'],
                'pay' => 1,
                'visit' => 1,
              },
              {
                'nodes' => ['town'],
                'pay' => 1,
                'visit' => 1,
              },
            ],
            num: 14,
            price: 50,
            rusts_on: '3',
            variants: [
              {
                name: '2',
                distance: 2,
                price: 120,
                rusts_on: '4',
                available_on: '1',
              },
            ],
          },
          {
            name: '3',
            distance: 3,
            num: 6,
            price: 200,
            rusts_on: '6',
          },
          {
            name: '4',
            distance: 4,
            num: 4,
            price: 300,
            rusts_on: '7',
          },
          {
            name: '5',
            distance: 5,
            num: 2,
            price: 500,
            events: [
              {
                'type' => 'close_concessions',
              },
            ],
          },
          {
            name: '6',
            distance: 6,
            num: 3,
            price: 600,
            events: [
              {
                'type' => 'full_capitalisation',
              },
            ],
          },
          {
            name: '7',
            distance: 7,
            num: 20,
            price: 750,
            variants: [
              {
                name: 'E',
                distance: 99,
                multiplier: 2,
                price: 1000,
              },
            ],
            events: [
              {
                'type' => 'phase_revenue',
              },
            ],
          },
          {
            name: '2P',
            distance: 2,
            num: 2,
            price: 0,
          },
          {
            name: 'LP',
            distance: [
              {
                'nodes' => ['city'],
                'pay' => 1,
                'visit' => 1,
              },
              {
                'nodes' => ['town'],
                'pay' => 1,
                'visit' => 1,
              },
            ],
            num: 1,
            price: 0,
          },
          {
            name: '5P',
            distance: 5,
            num: 1,
            price: 500,
          },
          {
            name: 'P+',
            distance: [
              {
                'nodes' => ['city'],
                'pay' => 99,
                'visit' => 99,
              },
              {
                'nodes' => ['town'],
                'pay' => 99,
                'visit' => 99,
              },
            ],
            num: 2,
            price: 0,
          },
        ].freeze

        UPGRADE_COST_L_TO_2_PHASE_2 = 70

        def discountable_trains_for(corporation)
          discount_info = []

          upgrade_cost = if @phase.name.to_i < 2
                           self.class::UPGRADE_COST_L_TO_2
                         else
                           self.class::UPGRADE_COST_L_TO_2_PHASE_2
                         end
          corporation.trains.select { |t| t.name == 'L' }.each do |train|
            discount_info << [train, train, '2', upgrade_cost]
          end
          discount_info
        end

        def init_companies(players)
          game_companies.map do |company|
            next if players.size < (company[:min_players] || 0)
            next unless starting_companies.include?(company[:sym])

            opts = self.class::STARTING_COMPANIES_OVERRIDE[company[:sym]] || {}
            Company.new(**company.merge(opts))
          end.compact
        end

        def init_corporations(stock_market)
          game_corporations.map do |corporation|
            next unless self.class::STARTING_CORPORATIONS.include?(corporation[:sym])

            opts = self.class::STARTING_CORPORATIONS_OVERRIDE[corporation[:sym]] || {}
            Corporation.new(
              min_price: stock_market.par_prices.map(&:price).min,
              capitalization: self.class::CAPITALIZATION,
              **corporation.merge(opts),
            )
          end.compact
        end
      end
    end
  end
end
