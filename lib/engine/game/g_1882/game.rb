# frozen_string_literal: true

require_relative 'meta'
require_relative '../base'

module Engine
  module Game
    module G1882
      class Game < Game::Base
        include_meta(G1882::Meta)

        register_colors(green: '#237333',
                        gray: '#9a9a9d',
                        red: '#d81e3e',
                        blue: '#0189d1',
                        yellow: '#FFF500',
                        brown: '#7b352a')

        AXES = { x: :number, y: :letter }.freeze
        CORPORATIONS_WITHOUT_NEUTRAL = %w[CPR CN].freeze

        CURRENCY_FORMAT_STR = '$%d'

        BANK_CASH = 9000

        CERT_LIMIT = { 2 => 20, 3 => 14, 4 => 11, 5 => 10, 6 => 9 }.freeze

        STARTING_CASH = { 2 => 900, 3 => 600, 4 => 450, 5 => 360, 6 => 300 }.freeze

        CAPITALIZATION = :full

        MUST_SELL_IN_BLOCKS = false

        TILES = {
          '1' => 1,
          '2' => 1,
          '3' => 1,
          '4' => 1,
          '7' => 5,
          '8' => 10,
          '9' => 10,
          '14' => 3,
          '15' => 2,
          '18' => 1,
          '19' => 1,
          '20' => 1,
          '23' => 3,
          '24' => 3,
          '26' => 1,
          '27' => 1,
          '41' => 2,
          '42' => 2,
          '43' => 2,
          '44' => 1,
          '45' => 2,
          '46' => 2,
          '47' => 1,
          '55' => 1,
          '56' => 1,
          '57' => 4,
          '58' => 1,
          '59' => 1,
          '63' => 3,
          '66' => 1,
          '67' => 1,
          '68' => 1,
          '69' => 1,
          'R1' =>
          {
            'count' => 1,
            'color' => 'green',
            'code' =>
            'city=revenue:60;city=revenue:60;path=a:0,b:_0;path=a:_0,b:1;path=a:2,b:_1;path=a:_1,b:3;label=R',
          },
          'R2' =>
          {
            'count' => 1,
            'color' => 'brown',
            'code' =>
            'city=revenue:70,slots:2;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;label=R',
          },
        }.freeze

        LOCATION_NAMES = {
          'I1' => 'Western Canada (HB +100)',
          'B2' => 'Northern Alberta (HB +100)',
          'L2' => 'Lethbridge',
          'C3' => 'Lloydminster',
          'G3' => 'Kindersley',
          'K3' => 'Medicine Hat',
          'M3' => 'Elkwater',
          'D4' => 'Maidstone',
          'F4' => 'Wilkie',
          'E5' => 'North Battleford & Battleford',
          'I5' => 'Swift Current',
          'D6' => 'Spiritwood',
          'N6' => 'Shaunavon',
          'G7' => 'Saskatoon',
          'D8' => 'Prince Albert',
          'F8' => 'Rosthern & Melfort',
          'J8' => 'Moose Jaw',
          'L8' => 'Assiniboia',
          'C9' => 'Candle Lake',
          'G9' => 'Humboldt',
          'K9' => 'Rouleau & Mossbank',
          'J10' => "Pile o' Bones & Lumsden",
          'A11' => 'Sandy Bay',
          'C11' => 'Flin Flon',
          'G11' => 'Wadena',
          'I11' => "Melville & Fort Qu'Appelle",
          'M11' => 'Wayburn & Estevan',
          'O11' => 'USA',
          'B12' => 'Hudson Bay',
          'J12' => 'Moosomin',
          'L12' => 'Carlyle',
          'N12' => 'Oxbow',
          'I13' => 'Eastern Canada',
          'K13' => 'Virden',
        }.freeze

        MARKET = [
          %w[76
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
             350e],
          %w[70
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
          %w[65
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
          %w[60y 66 71 76p 82 90 100 110 120 130],
          %w[55y 62 67 71p 76 82 90 100],
          %w[50y 58y 65 67p 71 75 80],
          %w[45o 54y 63 67 69 70],
          %w[40o 50y 60y 67 68],
          %w[30b 40o 50y 60y],
          %w[20b 30b 40o 50y],
          %w[10b 20b 30b 40o],
        ].freeze

        PHASES = [
          {
            name: '2',
            on: '2',
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
            train_limit: 3,
            tiles: %i[yellow green brown],
            operating_rounds: 3,
            status: ['can_buy_companies'],
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
          },
        ].freeze

        TRAINS = [{ name: '2', distance: 2, price: 80, rusts_on: '4', num: 6 },
                  { name: '3', distance: 3, price: 180, rusts_on: '6', num: 5 },
                  { name: '4', distance: 4, price: 300, rusts_on: 'D', num: 4 },
                  {
                    name: '5',
                    distance: 5,
                    price: 450,
                    num: 3,
                    events: [{ 'type' => 'close_companies' }],
                  },
                  { name: '6', distance: 6, price: 630, num: 3 },
                  {
                    name: 'D',
                    distance: 999,
                    price: 1100,
                    num: 20,
                    available_on: '6',
                    discount: { '4' => 300, '5' => 300, '6' => 300 },
                  }].freeze

        COMPANIES = [
          {
            name: 'Hudson Bay',
            value: 20,
            revenue: 5,
            desc: 'Blocks hex C11 (Flin Flon) while owned by a player. Closes at the start of Phase 5.',
            sym: 'HB',
            abilities: [{ type: 'blocks_hexes', owner_type: 'player', hexes: ['C11'] }],
            color: nil,
          },
          {
            name: 'Saskatchewan Central',
            value: 50,
            revenue: 10,
            desc: "Blocks hex H4 while owned by a player. On the owner's turn during a stock round they may convert it"\
                  " to a President's share of the SC by choosing its par price and using their \"buy action\" to purchase an"\
                  ' additional share of the SC. This is the only way the SC can be started. Place the SC home token in any'\
                  ' available non-reserved city slot or replace a neutral station. If the next available train is a 3, 4, 5'\
                  ' or 6, add one train of that type to the Depot. Closes at the start of Phase 6.',
            sym: 'SC',
            abilities: [{ type: 'close', on_phase: '6' },
                        { type: 'blocks_hexes', owner_type: 'player', hexes: ['H4'] },
                        {
                          type: 'exchange',
                          corporations: ['SC'],
                          owner_type: 'player',
                          from: 'par',
                        }],
            color: nil,
          },
          {
            name: 'North West Rebellion',
            value: 80,
            revenue: 15,
            desc: 'The owning corporation may move a single station token located in a non-NWR hex to any open city in'\
                  " an NWR hex. This action is free and may be performed at any time during the corporation's turn. An extra"\
                  " tile lay or upgrade may be performed on the destination hex. If the corporation's home token is moved,"\
                  ' replace it with a neutral station (its home token cannot be moved if a neutral station already exists in'\
                  ' the corporation’s home hex). Closes at the start of Phase 5.',
            sym: 'NWR',
            abilities: [
              {
                type: 'token',
                owner_type: 'corporation',
                hexes: %w[C3 D4 D6 E5],
                price: 0,
                teleport_price: 0,
                when: 'owning_corp_or_turn',
                special_only: true,
                count: 1,
                from_owner: true,
              },
              {
                type: 'tile_lay',
                when: 'owning_corp_or_turn',
                owner_type: 'corporation',
                count: 1,
                hexes: [],
                tiles: [],
              },
            ],
            color: nil,
          },
          {
            name: 'Trestle Bridge',
            value: 140,
            revenue: 0,
            desc: 'Blocks hex G9 while owned by a player. Earns $10 whenever any corporation pays to cross a river.'\
                  ' Comes with a 10% share of a randomly selected corporation (excluding SC). Closes at the start of'\
                  ' Phase 5.',
            sym: 'TB',
            abilities: [
              {
                type: 'shares',
                shares: 'random_share',
                corporations: %w[CNR CPR GT HBR QLL],
              },
              { type: 'blocks_hexes', owner_type: 'player', hexes: ['G9'] },
              { type: 'tile_income', income: 10, terrain: 'water' },
            ],
            color: nil,
          },
          {
            name: 'Canadian Pacific',
            value: 180,
            revenue: 25,
            desc: "Purchasing player immediately takes the 20% President's share of the CPR and chooses its par value."\
                  ' This private closes at the start of phase 5 or when the CPR purchases a train. It cannot be bought by a'\
                  ' corporation.',
            sym: 'CP',
            abilities: [{ type: 'shares', shares: 'CPR_0' }, { type: 'no_buy' }],
            color: nil,
          },
        ].freeze

        CORPORATIONS = [
          {
            sym: 'CN',
            name: 'Canadian National',
            logo: '1882/CN',
            simple_logo: '1882/CN.alt',
            tokens: [],
            color: :orange,
            text_color: 'black',
            reservation_color: nil,
          },
          {
            sym: 'CNR',
            name: 'Canadian Northern',
            logo: '1882/CNR',
            simple_logo: '1882/CNR.alt',
            tokens: [0, 40, 100],
            coordinates: 'D8',
            color: '#237333',
            reservation_color: nil,
          },
          {
            sym: 'HBR',
            name: 'Hudson Bay Railway',
            logo: '1882/HBR',
            simple_logo: '1882/HBR.alt',
            tokens: [0, 40, 100],
            coordinates: 'G11',
            color: :gold,
            text_color: 'black',
            reservation_color: nil,
          },
          {
            sym: 'CPR',
            name: 'Canadian Pacific Railway',
            logo: '1882/CPR',
            simple_logo: '1882/CPR.alt',
            tokens: [0, 40, 100, 100],
            coordinates: 'I5',
            color: '#d81e3e',
            reservation_color: nil,
          },
          {
            sym: 'GT',
            name: 'Grand Trunk Pacific',
            logo: '1882/GT',
            simple_logo: '1882/GT.alt',
            tokens: [0, 40, 100],
            coordinates: 'L8',
            color: :black,
            reservation_color: nil,
          },
          {
            sym: 'SC',
            name: 'Saskatchewan Central Railroad',
            logo: '1882/SC',
            simple_logo: '1882/SC.alt',
            tokens: [0],
            color: '#0189d1',
            reservation_color: nil,
          },
          {
            sym: 'QLL',
            name: "Qu'Appelle, Long Lake Railroad Co.",
            logo: '1882/QLL',
            simple_logo: '1882/QLL.alt',
            tokens: [0, 40],
            coordinates: 'J10',
            color: :purple,
            reservation_color: nil,
          },
        ].freeze

        HEXES = {
          red: {
            ['I1'] => 'offboard=revenue:yellow_40|brown_80;path=a:4,b:_0;path=a:5,b:_0',
            ['B2'] =>
                   'offboard=revenue:yellow_30|brown_60;border=edge:0,type:water,cost:40;path=a:0,b:_0;path=a:5,b:_0',
            ['O11'] => 'offboard=revenue:yellow_30|brown_30;path=a:3,b:_0',
            ['B12'] =>
                   'offboard=revenue:yellow_40|brown_50;border=edge:0,type:water,cost:60;path=a:0,b:_0;path=a:1,b:_0',
            ['I13'] => 'offboard=revenue:yellow_30|brown_40;path=a:1,b:_0;path=a:2,b:_0',
          },
          white: {
            %w[F2 H2 K5 M5 L6 M7 M9 B10 L10 H12] => '',
            ['K11'] => 'border=edge:3,type:water,cost:40',
            ['J2'] => 'border=edge:4,type:water,cost:20',
            ['L4'] => 'border=edge:2,type:water,cost:40',
            ['B4'] => 'icon=image:1882/NWR,sticky:1',
            %w[G3 L8 G11 J12] => 'city=revenue:0',
            ['C3'] =>
            'city=revenue:0;border=edge:1,type:water,cost:20;border=edge:0,type:water,cost:40;'\
            'icon=image:1882/NWR,sticky:1',
            ['K3'] =>
            'city=revenue:0;border=edge:0,type:water,cost:20;border=edge:1,type:water,cost:40;'\
            'border=edge:3,type:water,cost:40;border=edge:4,type:water,cost:40;'\
            'border=edge:5,type:water,cost:40',
            ['D4'] =>
            'city=revenue:0;border=edge:0,type:water,cost:40;border=edge:1,type:water,cost:40;'\
            'border=edge:5,type:water,cost:20;icon=image:1882/NWR,sticky:1',
            ['D6'] =>
            'city=revenue:0;border=edge:0,type:water,cost:40;border=edge:1,type:water,cost:40;'\
            'icon=image:1882/NWR,sticky:1',
            ['G7'] =>
            'city=revenue:0;border=edge:3,type:water,cost:40;border=edge:5,type:water,cost:40',
            ['J8'] => 'city=revenue:0;border=edge:2,type:water,cost:40',
            ['G9'] =>
            'city=revenue:0;border=edge:2,type:water,cost:20;border=edge:3,type:water,cost:40',
            ['C11'] =>
            'city=revenue:0;border=edge:0,type:water,cost:60;border=edge:5,type:water,cost:60',
            ['I5'] =>
            'city=revenue:0;border=edge:2,type:water,cost:20;border=edge:3,type:water,cost:40;'\
            'border=edge:4,type:water,cost:40',
            ['M3'] =>
            'town=revenue:0;upgrade=cost:40,terrain:mountain;border=edge:3,type:water,cost:20',
            ['D2'] => 'border=edge:3,type:water,cost:40;border=edge:4,type:water,cost:20',
            ['F6'] =>
            'border=edge:3,type:water,cost:40;border=edge:4,type:water,cost:20;icon=image:1882/NWR,sticky:1',
            ['E3'] =>
            'border=edge:3,type:water,cost:40;border=edge:4,type:water,cost:40;icon=image:1882/NWR,sticky:1',
            ['J6'] => 'border=edge:3,type:water,cost:40;border=edge:4,type:water,cost:40',
            ['I3'] =>
            'border=edge:0,type:water,cost:40;border=edge:1,type:water,cost:20;border=edge:5,type:water,cost:40',
            ['E7'] =>
            'border=edge:0,type:water,cost:40;border=edge:1,type:water,cost:20;'\
            'border=edge:5,type:water,cost:40;icon=image:1882/NWR,sticky:1',
            %w[J4 H8] =>
            'border=edge:1,type:water,cost:40;border=edge:2,type:water,cost:40;border=edge:3,type:water,cost:40',
            ['C5'] => 'border=edge:0,type:water,cost:40;icon=image:1882/NWR,sticky:1',
            ['G5'] => 'border=edge:0,type:water,cost:40',
            ['H4'] => 'border=edge:0,type:water,cost:40;border=edge:5,type:water,cost:20',
            ['H6'] => 'border=edge:0,type:water,cost:40;border=edge:1,type:water,cost:40',
            ['I7'] =>
            'border=edge:0,type:water,cost:20;border=edge:1,type:water,cost:40;'\
            'border=edge:4,type:water,cost:40;border=edge:5,type:water,cost:40',
            ['K7'] => 'border=edge:3,type:water,cost:20',
            ['E9'] =>
            'border=edge:0,type:water,cost:40;border=edge:3,type:water,cost:20;'\
            'border=edge:4,type:water,cost:40;border=edge:5,type:water,cost:40',
            ['I9'] => 'border=edge:5,type:water,cost:60',
            ['D10'] =>
            'border=edge:0,type:water,cost:60;border=edge:1,type:water,cost:40;border=edge:5,type:water,cost:40',
            %w[F10 E11] =>
            'border=edge:2,type:water,cost:40;border=edge:3,type:water,cost:60',
            ['H10'] => 'border=edge:0,type:water,cost:20',
            ['D12'] =>
            'border=edge:3,type:water,cost:60;border=edge:2,type:water,cost:60',
            ['L12'] => 'town=revenue:0',
            ['F4'] => 'town=revenue:0;border=edge:3,type:water,cost:40',
            ['K9'] => 'town=revenue:0;town=revenue:0',
            ['I11'] =>
            'town=revenue:0;town=revenue:0;border=edge:0,type:water,cost:40;border=edge:1,type:water,cost:40',
            ['F8'] =>
            'town=revenue:0;town=revenue:0;border=edge:0,type:water,cost:40;'\
            'border=edge:2,type:water,cost:40;border=edge:3,type:water,cost:40;'\
            'border=edge:5,type:water,cost:20',
          },
          gray: {
            ['L2'] =>
                     'city=revenue:40;path=a:4,b:_0;path=a:_0,b:5;border=edge:4,type:water,cost:40',
            ['N6'] => 'city=revenue:30;path=a:2,b:_0;path=a:_0,b:4',
            ['C7'] => 'path=a:0,b:1;border=edge:5',
            ['D8'] =>
            'city=revenue:30;path=a:0,b:_0;path=a:1,b:_0;border=edge:0,type:water,cost:40;border=edge:2;border=edge:4',
            ['N8'] => 'path=a:3,b:4',
            ['C9'] =>
            'town=revenue:10;path=a:0,b:_0;path=a:_0,b:4;border=edge:0,type:water,cost:20;border=edge:1',
            ['N10'] => 'path=a:2,b:4',
            ['A11'] => 'town=revenue:10;path=a:0,b:_0;path=a:_0,b:1',
            ['N12'] => 'town=revenue:10;path=a:2,b:_0;path=a:_0,b:3',
            ['K13'] => 'city=revenue:20;path=a:2,b:_0',
          },
          yellow: {
            ['M11'] => 'city=revenue:0;city=revenue:0;label=OO',
            ['E5'] =>
            'city=revenue:0;city=revenue:0;label=OO;border=edge:2,type:water,cost:20;'\
            'border=edge:3,type:water,cost:40;'\
            'border=edge:4,type:water,cost:40;icon=image:1882/NWR,sticky:1',
            ['J10'] =>
            'city=revenue:40;city=revenue:40;path=a:1,b:_0;path=a:4,b:_1;label=R;'\
            'border=edge:2,type:water,cost:60;border=edge:3,type:water,cost:20;'\
            'border=edge:4,type:water,cost:40',
            ['F12'] => 'path=a:1,b:3',
          },
          blue: {
            ['B6'] =>
                        'offboard=revenue:yellow_20|brown_30,visit_cost:0,route:optional;'\
                        'path=a:0,b:_0;path=a:1,b:_0;icon=image:1882/fish',
          },
        }.freeze

        LAYOUT = :flat

        MUST_BID_INCREMENT_MULTIPLE = true
        SELL_BUY_ORDER = :sell_buy_sell
        TRACK_RESTRICTION = :permissive
        DISCARDED_TRAINS = :remove
        EVENTS_TEXT = Base::EVENTS_TEXT.merge(
          'nwr' => ['North West Rebellion',
                    'Remove all yellow tiles from NWR-marked hexes. Station markers remain']
        ).freeze

        GAME_END_CHECK = { bankrupt: :immediate, stock_market: :current_round, bank: :full_or }.freeze
        # Two lays or one upgrade, second tile costs 20
        TILE_LAYS = [{ lay: true, upgrade: true }, { lay: :not_if_upgraded, upgrade: false, cost: 20 }].freeze

        def stock_round
          Round::Stock.new(self, [
            Engine::Step::DiscardTrain,
            G1882::Step::HomeToken,
            G1882::Step::BuySellParShares,
          ])
        end

        def new_auction_round
          Round::Auction.new(self, [
            Engine::Step::CompanyPendingPar,
            G1882::Step::WaterfallAuction,
          ])
        end

        def operating_round(round_num)
          Round::Operating.new(self, [
            Engine::Step::Bankrupt,
            Engine::Step::BuyCompany,
            Engine::Step::HomeToken,
            G1882::Step::SpecialNWR,
            G1882::Step::Track,
            Engine::Step::Token,
            Engine::Step::Route,
            Engine::Step::Dividend,
            Engine::Step::DiscardTrain,
            Engine::Step::BuyTrain,
            [Engine::Step::BuyCompany, { blocks: true }],
          ], round_num: round_num)
        end

        def home_token_locations(corporation)
          raise NotImplementedError unless corporation.name == 'SC'

          # SC, find all locations with neutral or no token
          cn_corp = corporations.find { |x| x.name == 'CN' }
          hexes = @hexes.dup
          hexes.select do |hex|
            hex.tile.cities.any? { |city| city.tokenable?(corporation, free: true) || city.tokened_by?(cn_corp) }
          end
        end

        def add_extra_train_when_sc_pars(corporation)
          first = depot.upcoming.first
          train = @sc_reserve_trains.find { |t| t.name == first.name }
          @sc_company = nil
          return unless train

          # Move events other than NWR rebellion earlier.
          train.events, first.events = first.events.partition { |e| e['type'] != 'nwr' }

          @log << "#{corporation.name} adds an extra #{train.name} train to the depot"
          train.reserved = false
          @depot.unshift_train(train)
        end

        def init_train_handler
          depot = super

          # Grab the reserve trains that SC can add
          trains = %w[3 4 5 6]

          @sc_reserve_trains = []
          trains.each do |train_name|
            train = depot.upcoming.reverse.find { |t| t.name == train_name }
            @sc_reserve_trains << train
            depot.remove_train(train)
            train.reserved = true
          end

          # Due to SC adding an extra train this isn't quite a phase change, so the event needs to be tied to a train.
          nwr_train = trains[rand % trains.size]
          @log << "NWR Rebellion occurs on purchase of the first #{nwr_train} train"
          train = depot.upcoming.find { |t| t.name == nwr_train }
          train.events << { 'type' => 'nwr' }

          depot
        end

        def setup
          cp = @companies.find { |company| company.name == 'Canadian Pacific' }
          cp.add_ability(Ability::Close.new(
            type: :close,
            when: 'bought_train',
            corporation: abilities(cp, :shares).shares.first.corporation.name,
          ))
        end

        def init_company_abilities
          @companies.each do |company|
            next unless (ability = abilities(company, :exchange))

            next unless ability.from.include?(:par)

            exchange_corporations(ability).first.par_via_exchange = company
            @sc_company = company
          end
          super
        end

        def init_corporations(stock_market)
          min_price = stock_market.par_prices.map(&:price).min

          corporations = self.class::CORPORATIONS.map do |corporation|
            corporation[:needs_token_to_par] = true if corporation[:sym] == 'CN'
            Corporation.new(
              min_price: min_price,
              capitalization: self.class::CAPITALIZATION,
              **corporation,
            )
          end

          # CN's tokens use a neutral logo, but as layed become owned by cn but don't block other players
          cn_corp = corporations.find { |x| x.name == 'CN' }
          logo = '/logos/1882/neutral.svg'
          corporations.each do |x|
            unless CORPORATIONS_WITHOUT_NEUTRAL.include?(x.name)
              x.tokens << Token.new(cn_corp, price: 0, logo: logo, simple_logo: logo, type: :neutral)
            end
          end
          corporations
        end

        def event_nwr!
          @log << '-- Event: North West Rebellion! --'
          name = 'NWR'
          @hexes.each do |hex|
            next unless hex.tile.icons.any? { |icon| icon.name == name }

            next unless hex.tile.color == :yellow
            next unless hex.tile != hex.original_tile

            @log << "Rebellion destroys tile #{hex.name}"
            old_tile = hex.tile
            hex.lay_downgrade(hex.original_tile)
            tiles << old_tile
          end

          # Some companies might no longer have valid routes
          @graph.clear_graph_for_all
        end

        def revenue_for(route, stops)
          revenue = super

          # East offboards I1, B2
          east = stops.find { |stop| %w[I1 B2].include?(stop.hex.name) }
          # Hudson B12
          west = stops.find { |stop| stop.hex.name == 'B12' }
          revenue += 100 if east && west

          revenue
        end

        def action_processed(action)
          if action.is_a?(Action::LayTile) && action.tile.name == 'R2'
            action.tile.location_name = 'Regina'
            return
          end

          return unless @sc_company
          return if !@sc_company.closed? && !@sc_company&.owner&.corporation?

          @log << 'Saskatchewan Central can no longer be converted to a public corporation'
          @corporations.reject! { |c| c.id == 'SC' }
          @sc_company = nil
        end

        def count_available_tokens(corporation)
          corporation.tokens.sum { |t| t.used || t.corporation != corporation ? 0 : 1 }
        end

        def token_string(corporation)
          # All neutral tokens belong to CN, so it will count them normally.
          "#{count_available_tokens(corporation)}"\
            "/#{corporation.tokens.sum { |t| t.corporation != corporation ? 0 : 1 }}"\
            "#{', N' if corporation.tokens.any? { |t| t.corporation != corporation }}"
        end

        def token_note
          'N = neutral token'
        end

        def token_ability_from_owner_usable?(_ability, _corporation)
          true
        end
      end
    end
  end
end
