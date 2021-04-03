# frozen_string_literal: true

require_relative 'meta'
require_relative '../base'
module Engine
  module Game
    module G18Scan
      class Game < Game::Base
        include_meta(G18Scan::Meta)

        CURRENCY_FORMAT_STR = 'K%d'

        BANK_CASH = 6000

        CERT_LIMIT = { 2 => 18, 3 => 12, 4 => 9 }.freeze

        STARTING_CASH = { 2 => 900, 3 => 600, 4 => 450 }.freeze

        CAPITALIZATION = :full

        MUST_SELL_IN_BLOCKS = true

        TILES = {
          '5' => 12,
          '8' => 8,
          '9' => 8,
          '15' => 6,
          '58' => 7,
          '80' => 3,
          '81' => 3,
          '82' => 3,
          '83' => 3,
          '121' =>
  {
    'count' => 1,
    'color' => 'green',
    'code' =>
    'city=revenue:50,loc:center;path=a:0,b:_2;'\
    'path=a:_2,b:_1;path=a:_0,b:_1;label=COP',
  },
          '141' => 3,
          '142' => 3,
          '143' => 3,
          '144' => 3,
          '145' => 3,
          '146' => 3,
          '403' =>
  {
    'count' => 1,
    'color' => 'yellow',
    'code' =>
    'city=revenue:30,loc:center;town=revenue:10,loc:0;path=a:0,b:_2;'\
    'path=a:_2,b:_1;path=a:_0,b:_1;label=COP;upgrade=cost:40',
  },
          '544' => 3,
          '545' => 3,
          '546' => 4,
          '582' => 2,
          '584' =>
  {
    'count' => 1,
    'color' => 'brown',
    'code' =>
    'city=revenue:30,slots:2;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;'\
      'path=a:4,b:_0;label=COP',
  },
        }.freeze
        LOCATION_NAMES = {
          'A6' => 'Kiel',
          'B7' => 'Stettin',
          'C6' => 'Copenhagen & Odense',
          'D1' => 'Newcastle',
          'D3' => 'Stavanger',
          'D5' => 'Aarhus',
          'D7' => 'Malmö',
          'E2' => 'Bergen',
          'E4' => 'Kristiansand',
          'F5' => 'Götenborg',
          'G4' => 'Oslo',
          'G8' => 'Norrköping',
          'J5' => 'Gävle',
          'K2' => 'Trondheim',
          'K6' => 'Stockholm',
          'L3' => 'Östersund',
          'M6' => 'Turku',
          'M8' => 'Tallinn',
          'N7' => 'Helsinki',
          'O4' => 'Umeå',
          'O6' => 'Tampere',
          'P7' => 'Lahti',
          'Q8' => 'Vyborg',
          'R1' => 'Narvik',
          'R3' => 'Luleå',
          'S2' => 'Gällivare',
          'S4' => 'Oulu',
          'T1' => 'Kiruna',

        }.freeze

        MARKET = [
          %w[82 90 100 110 122 135 150 165 180 200 220 245 270 300 330 360 400],
          %w[75 85 90 100 110 122 135 150 165 180 200 220 245 270],
          %w[70 75 82 90 100p 110 122 135 150 165 180],
          %w[65 70 75 82p 90p 100 110 122],
          %w[60 65 70p 75p 82 90],
          %w[50 60 65 70 75],
          %w[40 50 60 65],
          ].freeze

        PHASES = [
          {
            name: '2',
            train_limit: { minor: 2, major: 4, national: 0 },
            tiles: [:yellow],
            status: %w[float_2 incremental],
          },
          {
            name: '3',
            on: '3',
            train_limit: { minor: 2, major: 4, national: 0 },
            tiles: %i[yellow green],
            status: %w[float_3 incremental],
          },
          {
            name: '4',
            on: '4',
            train_limit: { minor: 1, major: 3, national: 0 },
            tiles: %i[yellow green],
            status: %w[float_4 incremental],
          },
          {
            name: '5',
            on: '5',
            train_limit: { major: 2, national: 3 },
            tiles: %i[yellow green brown],
            status: %w[float_5 fullcap],
          },
          {
            name: '5E',
            on: '5E',
            train_limit: { major: 2, national: 3 },
            tiles: %i[yellow green brown],
            status: %w[float_5 fullcap],
          },
          {
            name: '4D',
            on: '4D',
            train_limit: { major: 2, national: 3 },
            tiles: %i[yellow green brown],
            status: %w[float_5 fullcap],
          },
        ].freeze

        TRAINS = [
          {
            name: '2',
            distance: 2,
            price: 100,
            obsolete_on: '4',
            variants: [
              {
                name: '1+1',
                distance: [{ 'nodes' => %w[city offboard], 'pay' => 1, 'visit' => 1 },
                           { 'nodes' => %w[town], 'pay' => 1, 'visit' => 1 }],
                price: 80,
              },
            ],
            num: 6,
          },
          {
            name: '3',
            distance: 3,
            price: 200,
            obsolete_on: '5',
            variants: [
              {
                name: '2+2',
                distance: [{ 'nodes' => %w[city offboard], 'pay' => 2, 'visit' => 2 },
                           { 'nodes' => %w[town], 'pay' => 2, 'visit' => 2 }],
                price: 180,
              },
            ],
            num: 4,
          },
          {
            name: '4',
            distance: 4,
            price: 300,
            obsolete_on: '4D',
            variants: [
              {
                name: '3+3',
                distance: [{ 'nodes' => %w[city offboard], 'pay' => 3, 'visit' => 3 },
                           { 'nodes' => %w[town], 'pay' => 3, 'visit' => 3 }],
                price: 280,
              },
            ],
            num: 3,
          },
          {
            name: '5',
            distance: 5,
            price: 500,
            variants: [
              {
                name: '4+4',
                distance: [{ 'nodes' => %w[city offboard], 'pay' => 4, 'visit' => 4 },
                           { 'nodes' => %w[town], 'pay' => 4, 'visit' => 4 }],
                price: 480,
              },
            ],
            num: 2,
          },
          {
            name: '5E',
            distance: [{ 'nodes' => %w[city offboard], 'pay' => 5, 'visit' => 5 },
                       { 'nodes' => ['town'], 'pay' => 0, 'visit' => 99 }],
            price: 600,
            available_on: '5',
            num: 2,
          },
          {
            name: '4D',
            distance: [{ 'nodes' => %w[city offboard], 'pay' => 4, 'visit' => 4, 'multiplier' => 2 },
                       { 'nodes' => ['town'], 'pay' => 0, 'visit' => 99 }],
            price: 800,
            num: 6,
          },
        ].freeze

        # rubocop:disable Layout/LineLength
        COMPANIES = [
          {
            sym: 'Ferry',
            name: 'Stockholm-Åbo Ferry Company',
            value: 120,
            revenue: 20,
            desc: 'Comes with two +20 bonus tokens. Tokens may be purchased by a Corporation for K20 to gain a +20 bonus to runs across the ferry on L7.',
            abilities: [
              { type: 'shares', shares: 'VR_1' },
              { type: 'close', when: 'tokens_sold' },
            ],
          },
          {
            sym: 'Mine',
            name: 'Lapland Ore Mine',
            value: 150,
            revenue: 25,
            desc: 'Comes with one +50 token. Token may be purchased by a Corporation for K50 to increase the value of one run to Kiruna (T1) by 50.',
          },
          {
            sym: 'SJS',
            name: 'Sjaellandske Jerbaneselskab (Zeeland Railway Company)',
            value: 180,
            revenue: 30,
            desc: 'Lays COP (C6) for free',
            abilities: [
              {
                type: 'tile_lay',
                discount: 40,
                owner_type: 'corporation',
                tiles: %w[403 121],
                hexes: ['C6'],
                count: 1,
                when: 'track',
              },
              { type: 'close', when: 'bought_train', corporation: 'DSB' },
              { type: 'no_buy' },
              { type: 'shares', shares: 'DSB_0' },
            ],
          },

          {
            sym: '1',
            name: 'Södra Stambanan (Southern Mainline)',
            value: 260,
            revenue: 0,
            desc: 'Owner takes control of minor corporation 1. Begins in Malmö (D7). This private cannot be sold. Destination: Göteborg (F5). When Phase 5 begins, the minor corporation closes, but its owner receives a 10% share in SJ.',
            abilities: [{ type: 'no_buy', owner_type: 'player' }],
          },
          {
            sym: '2',
            name: 'Nordvästra Stambanan (Northwestern Mainline)',
            value: 220,
            revenue: 0,
            desc: 'Owner takes control of minor corporation 2. Begins in Northern Stockholm (K6). This private cannot be sold. Destination: Trondheim (K2). When Phase 5 begins, the minor corporation closes, but its owner receives a 10% share in SJ.',
            abilities: [{ type: 'no_buy', owner_type: 'player' }],
          },
          {
            sym: '3',
            name: 'Västra Stambanan (Western Mainline)',
            value: 200,
            revenue: 0,
            desc: 'Owner takes control of minor corporation 3. Begins in Southwestern Stockholm (K6). This private cannot be sold. Destination: Oslo (G4). When Phase 5 begins, the minor corporation closes, but its owner receives a 10% share in SJ.',
            abilities: [{ type: 'no_buy', owner_type: 'player' }],
          },
        ].freeze
        # rubocop:enable Layout/LineLength

        CORPORATIONS = [
          {
            sym: 'DSB',
            name: 'Danske Statsbaner',
            logo: '18_mex/CHI',
            simple_logo: '18_mex/CHI.alt',
            tokens: [0, 40, 100],
            coordinates: 'C6',
            color: '#FF7F40',
          },
          {
            sym: 'S&NJ',
            name: 'Sveriges & Norges Järnvägar',
            logo: '18_mex/NdM',
            simple_logo: '18_mex/NdM.alt',
            tokens: [0, 40, 100],
            coordinates: 'S2',
            color: '#6AA84F',
          },
          {
            sym: 'NSB',
            name: 'Norges Statsbaner',
            logo: '18_mex/MC',
            simple_logo: '18_mex/MC.alt',
            tokens: [0, 40, 100, 100],
            coordinates: 'G4',
            color: '#FF0000',
          },
          {
            sym: 'VR',
            name: 'Valtionrautatiet',
            logo: '18_mex/FCP',
            simple_logo: '18_mex/FCP.alt',
            tokens: [0, 40, 100, 100],
            coordinates: 'B3',
            color: '#00FFFF',
            text_color: 'black',
          },
          {
            sym: 'SJ',
            name: 'Statens Järnvägar',
            logo: '18_mex/TM',
            simple_logo: '18_mex/TM.alt',
            tokens: [0, 40, 100, 100, 100, 100],
            coordinates: 'I12',
            color: '#1155CC',
          },
        ].freeze

        MINORS = [
          {
            sym: '1',
            name: 'Södra Stambanan (Southern Mainline)',
            logo: '18_mex/A',
            simple_logo: '18_mex/A.alt',
            tokens: [0, 40],
            coordinates: 'D7',
            color: '#A4C2F4',
          },
          {
            sym: '2',
            name: 'Nordvästra Stambanan (Northwestern Mainline)',
            logo: '18_mex/B',
            simple_logo: '18_mex/B.alt',
            tokens: [0, 40],
            coordinates: 'K6',
            color: '#A4C2F4',
          },
          {
            sym: '3',
            name: 'Västra Stambanan (Western Mainline)',
            logo: '18_mex/C',
            simple_logo: '18_mex/C.alt',
            tokens: [0, 40],
            coordinates: 'K6',
            color: '#A4C2F4',
          },
        ].freeze

        # rubocop:disable Layout/LineLength
        HEXES = {
          red: {
            ['A6'] => 'city=revenue:yellow_20|green_30|brown_50,slots:1;path=a:3,b:_0,terminal:1;path=a:4,b:_0,terminal:1',
            ['B7'] => 'city=revenue:yellow_10|green_30|brown_60,slots:1;path=a:3,b:_0,terminal:1;path=a:4,b:_0,terminal:1',
            ['D1'] => 'city=revenue:yellow_20|green_30|brown_80,slots:1;path=a:5,b:_0,terminal:1',
            ['M8'] => 'city=revenue:yellow_0|green_30|brown_60,slots:1;path=a:3,b:_0,terminal:1',
            ['Q8'] => 'city=revenue:yellow_30|green_50|brown_80,slots:1;path=a:2,b:_0,terminal:1',
            ['T1'] => 'town=revenue:yellow_10|green_50|brown_10;path=a:0,b:_0;path=a:1,b:_0',
          },
          lightBlue: {
            ['L7'] => 'path=a:2,b:3,track:narrow',
          },
          white: {
            %w[B5 E6 F7 H5 H7 I4 I6 K4 N3 P3 Q6] => '',
            %w[F1 H1 J1 N1 P1 G2 I2 M2 O2 Q2 F3 H3 J3] => 'upgrade=cost:60,terrain:mountain',
            %w[G6 J5 L3 P7 R3] => 'town=revenue:0',
            %w[G4 N7 O6 S2] => 'city=revenue:0',
            %w[K2 R1] => 'city=revenue:0;upgrade=cost:60,terrain:mountain',
            %w[F5 M6] => 'city=revenue:0;border=edge:1,type:impassable;border=edge:2,type:impassable',
            ['C6'] => 'city=revenue:0;town=revenue:0;upgrade=cost:40,terrain:water',
            ['D3'] => 'city=revenue:0;border=edge:3,type:impassable',
            ['D5'] => 'city=revenue:0;border=edge:3,type:impassable;border=edge:4,type:impassable;border=edge:5,type:impassable',
            ['D7'] => 'city=revenue:0;upgrade=cost:40,terrain:water',
            ['E2'] => 'city=revenue:0;border=edge:0,type:impassable',
            ['E4'] => 'town=revenue:0;border=edge:0,type:impassable,border=edge:5,type:impassable',
            ['F5'] => 'city=revenue:0;border=edge:1,type:impassable;border=edge:2,type:impassable',
            ['L5'] => 'city=revenue:0;border=edge:4,type:impassable;border=edge:5,type:impassable',
            ['M4'] => 'border=edge:5,type:impassable',
            ['N5'] => 'border=edge:1,type:impassable;border=edge:2,type:impassable;border=edge:3,type:impassable',
            ['O6'] => 'city=revenue:0;border=edge:0,type:impassable;border=edge:5,type:impassable',
            ['P5'] => 'border=edge:2,type:impassable;border=edge:3,type:impassable',
            ['Q4'] => 'border=edge:0,type:impassable;border=edge:4,type:impassable;border=edge:5,type:impassable',
            ['R1'] => 'city=revenue:0;upgrade=cost:60,terrain:mountain',
            ['R5'] => 'border=edge:2,type:impassable',
            ['S4'] => 'town=revenue:0;border=edge:1,type:impassable',
          },
          yellow: {
            ['K6'] => 'city=revenue:30;city=revenue:30;path=a:1,b:_0;path=a:2,b:_1;border=edge:4,type:impassable',
          },
        }.freeze
        # rubocop:enable Layout/LineLength

        LAYOUT = :pointy

        AXES = { x: :letter, y: :number }.freeze

        GAME_END_CHECK = { bank: :current_set }.freeze

        TRACK_RESTRICTION = :semirestrictive

        COPENHAGEN_HEX = 'C6'

        EVENTS_TEXT = Base::EVENTS_TEXT.merge(
          'minors_closed' => ['Minors closed'],
        ).freeze

        def company_1
          @company_1 ||= company_by_id('1')
        end

        def company_2
          @company_2 ||= company_by_id('2')
        end

        def company_3
          @company_3 ||= company_by_id('3')
        end

        def sj
          @sj_corporation ||= corporation_by_id('SJ')
        end

        def company_1_reserved_share
          @company_1_reserved_share ||= sj.shares[6]
        end

        def company_2_reserved_share
          @company_2_reserved_share ||= sj.shares[7]
        end

        def company_3_reserved_share
          @company_3_reserved_share ||= sj.shares[8]
        end

        def dsb
          @dsb_corporation ||= corporation_by_id('DSB')
        end

        def nsb
          @nsb_corporation ||= corporation_by_id('NSB')
        end

        def vr
          @vr_corporation ||= corporation_by_id('VR')
        end

        def nsj
          @nsj_corporation ||= corporation_by_id('NSJ')
        end

        def minor_1
          @minor_a ||= minor_by_id('1')
        end

        def minor_2
          @minor_2 ||= minor_by_id('2')
        end

        def minor_3
          @minor_3 ||= minor_by_id('3')
        end

        def operating_round(round_num)
          Round::Operating.new(self, [
            Engine::Step::Bankrupt,
            G18Scan::Step::Assign,
            G18Scan::Step::BuyCompany,
            Engine::Step::HomeToken,
            G18Scan::Step::Merge,
            G18Scan::Step::SpecialTrack,
            G18Scan::Step::Track,
            Engine::Step::Token,
            Engine::Step::Route,
            G18Scan::Step::Dividend,
            Engine::Step::DiscardTrain,
            G18Scan::Step::SingleDepotTrainBuy,
            [Engine::Step::BuyCompany, { blocks: true }],
          ], round_num: round_num)
        end
      end
    end
  end
end
