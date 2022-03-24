# frozen_string_literal: true

require_relative 'meta'
require_relative '../base'
require_relative 'stock_market'

module Engine
  module Game
    module G1870
      class Game < Game::Base
        include_meta(G1870::Meta)

        attr_accessor :sell_queue, :connection_run, :reissued

        register_colors(black: '#37383a',
                        orange: '#f48221',
                        brightGreen: '#76a042',
                        red: '#d81e3e',
                        turquoise: '#00a993',
                        blue: '#0189d1',
                        brown: '#7b352a')

        CURRENCY_FORMAT_STR = '$%d'

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

        TILES = {
          '1' => 1,
          '2' => 1,
          '3' => 3,
          '4' => 6,
          '5' => 2,
          '6' => 2,
          '7' => 9,
          '8' => 22,
          '9' => 23,
          '14' => 4,
          '15' => 4,
          '16' => 2,
          '17' => 2,
          '18' => 2,
          '19' => 2,
          '20' => 2,
          '23' => 4,
          '24' => 4,
          '25' => 3,
          '26' => 2,
          '27' => 2,
          '28' => 2,
          '29' => 2,
          '39' => 1,
          '40' => 2,
          '41' => 3,
          '42' => 3,
          '43' => 2,
          '44' => 1,
          '45' => 2,
          '46' => 2,
          '47' => 2,
          '55' => 1,
          '56' => 1,
          '57' => 5,
          '58' => 4,
          '63' => 5,
          '69' => 1,
          '70' => 2,
          '141' => 2,
          '142' => 2,
          '143' => 1,
          '144' => 1,
          '145' => 2,
          '146' => 2,
          '147' => 2,
          '170' => 4,
          '171K' =>
          {
            'count' => 1,
            'color' => 'gray',
            'code' =>
            'city=revenue:60,slots:3;path=a:0,b:_0;path=a:1,b:_0;'\
            'path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=K',
          },
          '172L' =>
          {
            'count' => 1,
            'color' => 'gray',
            'code' =>
            'city=revenue:60,slots:2;path=a:0,b:_0;path=a:1,b:_0;'\
            'path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=L',
          },
        }.freeze

        LOCATION_NAMES = {
          'A2' => 'Denver',
          'A22' => 'Chicago',
          'B9' => 'Topeka',
          'B11' => 'Kansas City',
          'B19' => 'Springfield, IL',
          'C18' => 'St. Louis',
          'D5' => 'Wichita',
          'E12' => 'Springfield, MO',
          'F5' => 'Oklahoma City',
          'H13' => 'Little Rock',
          'H17' => 'Memphis',
          'J3' => 'Fort Worth',
          'J5' => 'Dallas',
          'K16' => 'Jackson',
          'L11' => 'Alexandria',
          'M2' => 'Austin',
          'M6' => 'Houston',
          'M14' => 'Baton Rouge',
          'M20' => 'Mobile',
          'M22' => 'Southeast',
          'N1' => 'Southwest',
          'N7' => 'Galveston',
          'N17' => 'New Orleans',
        }.freeze

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

        PHASES = [
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

        TRAINS = [{ name: '2', distance: 2, price: 80, rusts_on: '4', num: 7 },
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
                  { name: '12', distance: 12, price: 1100, num: 12 }].freeze

        COMPANIES = [
          {
            name: 'Great River Shipping Company',
            value: 20,
            revenue: 5,
            desc: 'The GRSC has no special features.',
            sym: 'GRSC',
            color: nil,
          },
          {
            name: 'Mississippi River Bridge Company',
            value: 40,
            revenue: 10,
            desc: 'Until this company is closed or sold to a public company, no company may bridge the Mississippi'\
                  ' River. A company may lay track along the river, but may not lay track to cross the river, or do an'\
                  ' upgrade that would cause track to cross the river. The public company that purchases the Mississippi'\
                  ' River Bridge Company may build in one of the hexes along the Mississippi River for a $40 discount.'\
                  ' This company may be purchased by one of the two companies on the Mississippi River (Missouri Pacific'\
                  ' or St.Louis Southwestern) in phase one for $20 to $40. If one of these two public companies purchases'\
                  ' this private company during their first operating round, that company can lay a tile at its starting'\
                  ' city for no cost and in addition to its normal tile lay(s). The company cannot lay a tile in their'\
                  ' starting city and upgrade it during the same operating round.',
            sym: 'MRBC',
            abilities: [
              {
                type: 'blocks_partition',
                partition_type: 'water',
                owner_type: 'player',
              },
              {
                type: 'tile_lay',
                owner_type: 'corporation',
                count: 1,
                reachable: true,
                special: false,
                when: 'track',
                discount: 40,
                hexes: %w[A16 B17 C18 D17 E18 F19 G18 H17 I16 J15 K14 L13 M14 N15 O16 O18],
                tiles: %w[1 2 3 4 5 6 7 8 9 55 56 57 58 69],
              },
            ],
            color: nil,
          },
          {
            name: 'The Southern Cattle Company',
            value: 50,
            revenue: 10,
            desc: 'This company has a token that may be placed on any city west of the Mississippi River. Cities'\
                  ' located in the same hex as any portion of the Mississippi are not eligible for this placement. This'\
                  ' increases the value of that city by $10 for that company only. Placing the token does not close the'\
                  ' company.',
            sym: 'SCC',
            abilities: [
              {
                type: 'assign_hexes',
                hexes: %w[B9 B11 D5 E12 F5 H13 J3 J5 L11 M2 M6 N7],
                when: 'owning_corp_or_turn',
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
            name: 'The Gulf Shipping Company',
            value: 80,
            revenue: 15,
            desc: 'This company has two tokens. One represents an open port and the other is a closed port. One (but'\
                  ' not both) of these tokens may be placed on one of the cities: Memphis (H17), Baton Rouge (M14), Mobile'\
                  ' (M20), Galveston (N7) and New Orleans (N17). Either token increases the value of the city for the owning'\
                  ' company by $20. The open port token also increases the value of the city for all other companies by $10.'\
                  ' If the president of the owning company places the closed port token, the private company is closed. If'\
                  ' the open port token is placed, it may be replaced in a later operating round by the closed port token,'\
                  ' closing the company.',
            sym: 'GSC',
            abilities: [
              {
                type: 'assign_hexes',
                hexes: %w[H17 M14 M20 N7 N17],
                count: 2,
                owner_type: 'corporation',
                when: 'owning_corp_or_turn',
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
            name: 'St.Louis-San Francisco Railway',
            value: 140,
            revenue: 0,
            desc: "This is the President's certificate of the St.Louis-San Francisco Railway. The purchaser sets the"\
                  ' par value of the railway. Unlike other companies, this company may operate with just 20% sold. It may'\
                  ' not be purchased by another public company.',
            sym: 'SLSF',
            abilities: [{ type: 'shares', shares: 'SLSF_0' }, { type: 'no_buy' }],
            color: nil,
          },
          {
            name: 'Missouri-Kansas-Texas Railroad',
            value: 160,
            revenue: 20,
            desc: 'Comes with a 10% share of the Missouri-Kansas-Texas Railroad.',
            sym: 'MKT',
            abilities: [{ type: 'shares', shares: 'MKT_1' }],
            color: nil,
          },
        ].freeze

        CORPORATIONS = [
          {
            float_percent: 60,
            sym: 'ATSF',
            name: 'Santa Fe',
            logo: '1870/ATSF',
            simple_logo: '1870/ATSF.alt',
            tokens: [0, 40, 100],
            abilities: [{ type: 'assign_hexes', hexes: ['N1'], count: 1 }],
            coordinates: 'B9',
            color: '#7090c9',
            text_color: 'black',
            reservation_color: nil,
          },
          {
            float_percent: 60,
            sym: 'SSW',
            name: 'Cotton',
            logo: '1870/SSW',
            simple_logo: '1870/SSW.alt',
            tokens: [0, 40],
            abilities: [{ type: 'assign_hexes', hexes: ['J3'], count: 1 }],
            coordinates: 'H17',
            color: '#111199',
            reservation_color: nil,
          },
          {
            float_percent: 60,
            sym: 'SP',
            name: 'Southern Pacific',
            logo: '1870/SP',
            simple_logo: '1870/SP.alt',
            tokens: [0, 40, 100],
            abilities: [{ type: 'assign_hexes', hexes: ['N17'], count: 1 }],
            coordinates: 'N1',
            color: '#f48221',
            reservation_color: nil,
          },
          {
            float_percent: 20,
            sym: 'SLSF',
            name: 'Frisco',
            logo: '1870/SLSF',
            simple_logo: '1870/SLSF.alt',
            tokens: [0, 40, 100],
            abilities: [{ type: 'assign_hexes', hexes: ['M22'], count: 1 }],
            coordinates: 'E12',
            color: '#d02020',
            reservation_color: nil,
          },
          {
            float_percent: 60,
            sym: 'MP',
            name: 'Missouri Pacific',
            logo: '1870/MP',
            simple_logo: '1870/MP.alt',
            tokens: [0, 40, 100],
            abilities: [{ type: 'assign_hexes', hexes: ['J5'], count: 1 }],
            coordinates: 'C18',
            color: '#5b4545',
            reservation_color: nil,
          },
          {
            float_percent: 60,
            sym: 'MKT',
            name: 'Katy',
            logo: '1870/MKT',
            simple_logo: '1870/MKT.alt',
            tokens: [0, 40, 100],
            abilities: [{ type: 'assign_hexes', hexes: ['N1'], count: 1 }],
            coordinates: 'B11',
            color: '#018471',
            reservation_color: nil,
          },
          {
            float_percent: 60,
            sym: 'IC',
            name: 'Illinois Central',
            logo: '1870/IC',
            simple_logo: '1870/IC.alt',
            tokens: [0, 40],
            abilities: [{ type: 'assign_hexes', hexes: ['A22'], count: 1 }],
            coordinates: 'K16',
            color: '#b0b030',
            reservation_color: nil,
          },
          {
            float_percent: 60,
            sym: 'GMO',
            name: 'Gulf Mobile Ohio',
            logo: '1870/GMO',
            simple_logo: '1870/GMO.alt',
            tokens: [0, 40],
            abilities: [{ type: 'assign_hexes', hexes: ['C18'], count: 1 }],
            coordinates: 'M20',
            color: '#ff4080',
            text_color: 'black',
            reservation_color: nil,
          },
          {
            float_percent: 60,
            sym: 'FW',
            name: 'Fort Worth',
            logo: '1870/FW',
            simple_logo: '1870/FW.alt',
            tokens: [0, 40],
            abilities: [{ type: 'assign_hexes', hexes: ['A2'], count: 1 }],
            coordinates: 'J3',
            color: '#56ad9a',
            text_color: 'black',
            reservation_color: nil,
          },
          {
            float_percent: 60,
            sym: 'TP',
            name: 'Texas Pacific',
            logo: '1870/TP',
            simple_logo: '1870/TP.alt',
            tokens: [0, 40],
            abilities: [{ type: 'assign_hexes', hexes: ['N17'], count: 1 }],
            coordinates: 'J5',
            color: '#37383a',
            reservation_color: nil,
          },
        ].freeze

        HEXES = {
          white: {
            %w[A4 A6 A8 A12 A14 A18 A20 B3 B5 B15 B21 C2 C4 C6 C8 C10 C12 C20 D1 D3
               D7 D11 D19 E2 E4 E6 E10 F1 F3 F7 F17 F21 G4 G6 G8 G12 G14 G16 H1
               H9 H11 H15 H19 I2 I4 I6 I12 I18 I20 J1 J7 J13 J17 J19 J21 K2 K6 K8 K12 K18 L1
               L3 L5 L7 L9 L15 L17 L19 L21 M4 M12 M16 M18 N3 N5] => '',
            %w[B9 B19 D5 F5 H13 K16 M2 M6] => 'city=revenue:0',
            %w[J3 J5] => 'city=revenue:0;label=P',
            %w[B7 D9 D21 E8 F9 G10 G20 H21 I14 J9 K4 K20 M8 M10] => 'town=revenue:0',
            ['M20'] => 'city=revenue:0;icon=image:port,sticky:1',
            %w[C14 C16 G2 H5] => 'upgrade=cost:40,terrain:water',
            %w[H7 I8 J11 K10] => 'upgrade=cost:60,terrain:water',
            ['B11'] => 'city=revenue:0;upgrade=cost:40,terrain:water;label=P;label=K',
            ['L11'] => 'city=revenue:0;upgrade=cost:60,terrain:water',
            %w[A10 B13 H3] => 'town=revenue:0;upgrade=cost:40,terrain:water',
            %w[I10 E20] =>
                   'town=revenue:0;town=revenue:0;upgrade=cost:60,terrain:water',
            ['B17'] => 'upgrade=cost:40,terrain:river;partition=a:0-,b:2+,type:water',
            ['E18'] => 'upgrade=cost:60,terrain:river;partition=a:3-,b:5+,type:water',
            ['F19'] => 'upgrade=cost:60,terrain:river;partition=a:1-,b:3-,type:water',
            %w[G18 I16] =>
                   'upgrade=cost:60,terrain:river;partition=a:1-,b:3+,type:water',
            ['J15'] => 'upgrade=cost:60,terrain:river;partition=a:0+,b:3+,type:water',
            ['L13'] => 'upgrade=cost:80,terrain:river;partition=a:0-,b:4-,type:water',
            ['N15'] => 'upgrade=cost:80,terrain:river;partition=a:2+,b:5+,type:water',
            ['O16'] => 'upgrade=cost:100,terrain:river;partition=a:3-,b:4+,type:water',
            ['O18'] =>
                   'upgrade=cost:100,terrain:river;partition=a:0-,b:2-,type:water;border=edge:3,type:impassable',
            ['C18'] =>
                   'city=revenue:0;upgrade=cost:40,terrain:river;partition=a:0+,b:2+,type:water,restrict:inner;label=P;label=L',
            ['M14'] =>
                   'city=revenue:0;upgrade=cost:80,terrain:river;icon=image:port,sticky:1;'\
                   'partition=a:0-,b:2+,type:water,restrict:outer',
            ['H17'] =>
                   'city=revenue:0;upgrade=cost:60,terrain:river;icon=image:port,sticky:1;'\
                   'partition=a:1-,b:3+,type:water,restrict:outer',
            ['D17'] =>
                   'town=revenue:0;upgrade=cost:40,terrain:river;partition=a:4-,b:5+,type:water,restrict:outer',
            ['K14'] =>
                   'town=revenue:0;upgrade=cost:80,terrain:river;partition=a:0+,b:4-,type:water,restrict:outer',
            ['A16'] =>
                   'town=revenue:0;town=revenue:0;upgrade=cost:40,terrain:river;partition=a:0-,b:3,type:water,restrict:inner',
            ['O2'] => 'upgrade=cost:60,terrain:lake',
            %w[O4 O6 N9 N11 N13] => 'upgrade=cost:80,terrain:lake',
            ['N19'] =>
                   'upgrade=cost:80,terrain:lake;border=edge:0,type:impassable;border=edge:1,type:impassable',
            ['O14'] => 'upgrade=cost:100,terrain:lake',
            ['N7'] => 'city=revenue:0;upgrade=cost:80,terrain:lake;icon=image:port,sticky:1',
            ['N17'] =>
                   'city=revenue:0;upgrade=cost:80,terrain:lake;icon=image:port,sticky:1;border=edge:4,type:impassable;label=P',
            ['N21'] => 'town=revenue:0;upgrade=cost:80,terrain:lake',
            %w[D13 D15 E14 E16 F11 F13 F15] =>
                   'upgrade=cost:60,terrain:mountain',
            ['E12'] => 'city=revenue:0;upgrade=cost:60,terrain:mountain',
          },
          red: {
            ['A2'] =>
            'city=revenue:yellow_30|brown_40|blue_50,slots:0;'\
            'path=a:4,b:_0,terminal:1;path=a:5,b:_0,terminal:1',
            ['A22'] =>
            'city=revenue:yellow_40|brown_50|blue_60,slots:0;path=a:0,terminal:1,b:_0;path=a:1,b:_0,terminal:1',
            ['N1'] =>
            'city=revenue:yellow_20|brown_40|blue_50;path=a:3,b:_0,terminal:1;'\
            'path=a:4,b:_0,terminal:1;path=a:5,b:_0,terminal:1',
            ['M22'] =>
            'city=revenue:yellow_20|brown_30|blue_50,slots:0;path=a:0,b:_0,terminal:1;'\
            'path=a:1,b:_0,terminal:1;path=a:2,b:_0,terminal:1',
          },
        }.freeze

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

        def assignment_tokens(assignment)
          return "/icons/#{assignment.logo_filename}" if assignment.is_a?(Engine::Corporation)

          super
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
                          !stock_market.find_share_price(s.corporation, Array.new(bundle.num_shares, :up)).counts_for_limit
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

        def upgrades_to?(from, to, _special = false, selected_company: nil)
          return false if to.name == '171K' && from.hex.name != 'B11'
          return false if to.name == '172L' && from.hex.name != 'C18'
          return false if to.name == '63' && (from.hex.name == 'B11' || from.hex.name == 'C18')

          return true if %w[B11 C18 N17 J3 J5].include?(from.hex.name) && (from.color == :green && to.name == '170')

          super
        end

        def upgrades_to_correct_label?(from, to)
          return true if to.color != :brown

          super
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
      end
    end
  end
end
