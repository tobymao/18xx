# frozen_string_literal: true

require_relative 'meta'
require_relative '../base'

module Engine
  module Game
    module G18EU
      class Game < Game::Base
        include_meta(G18EU::Meta)

        CURRENCY_FORMAT_STR = '£%d'

        BANK_CASH = 12_000

        CERT_LIMIT = { 2 => 28, 3 => 20, 4 => 16, 5 => 13, 6 => 11 }.freeze

        STARTING_CASH = { 2 => 750, 3 => 450, 4 => 350, 5 => 300, 6 => 250 }.freeze

        CAPITALIZATION = :incremental

        MUST_SELL_IN_BLOCKS = true

        TILE_TYPE = :lawson

        TILES = {
          '3' => 8,
          '4' => 10,
          '7' => 4,
          '8' => 15,
          '9' => 15,
          '14' => 4,
          '15' => 4,
          '57' => 8,
          '58' => 14,
          '80' => 4,
          '81' => 4,
          '82' => 4,
          '83' => 4,
          '141' => 5,
          '142' => 4,
          '143' => 2,
          '144' => 2,
          '145' => 4,
          '146' => 5,
          '147' => 4,
          '201' => 7,
          '202' => 9,
          '513' => 5,
          '544' => 3,
          '545' => 3,
          '546' => 3,
          '576' => 4,
          '577' => 4,
          '578' => 3,
          '579' => 3,
          '580' => 1,
          '581' => 2,
          '582' => 9,
          '583' => 1,
          '584' => 2,
          '611' => 8,
        }.freeze

        LOCATION_NAMES = {
          'N17' => 'Bucharest',
          'N5' => 'Warsaw',
          'A6' => 'London',
          'A10' => 'Paris',
          'G2' => 'Hamburg',
          'G22' => 'Rome',
          'B17' => 'Lyon',
          'B19' => 'Marseille',
          'C8' => 'Brussels',
          'D3' => 'Amsterdam',
          'D7' => 'Cologne',
          'D13' => 'Strausburg',
          'D19' => 'Turin',
          'E6' => 'Dortmund',
          'E18' => 'Milan',
          'E20' => 'Genoa',
          'F9' => 'Frankfurt',
          'G12' => 'Munich',
          'H19' => 'Venice',
          'I18' => 'Trieste',
          'J5' => 'Berlin',
          'J7' => 'Dresden',
          'J11' => 'Prague',
          'M16' => 'Budapest',
          'B7' => 'Lille',
          'B13' => 'Dijon',
          'C4' => 'Rotterdam',
          'C6' => 'Antwerp',
          'C16' => 'Geneva',
          'D5' => 'Utrecht',
          'D15' => 'Basil',
          'E12' => 'Stuttgart',
          'F3' => 'Bremen',
          'F11' => 'Augsburg',
          'F21' => 'Florence',
          'G6' => 'Hannover',
          'G10' => 'Nuremberg',
          'G20' => 'Bologne',
          'H7' => 'Magdeburg',
          'I8' => 'Leipzig',
          'K4' => 'Stettin',
          'K12' => 'Brunn',
          'K14' => 'Vienna',
          'K16' => 'Semmering',
          'L5' => 'Thorn',
          'C20' => 'Nice',
          'E14' => 'Zürich',
          'H15' => 'Innsbruck',
          'I14' => 'Salzburg',
          'L15' => 'Pressburg',
          'M10' => 'Krakau',
        }.freeze

        MARKET = [
          %w[82
             90
             100
             110
             122
             135
             150
             165
             180
             200
             225
             245
             270
             300
             330
             360
             400],
          %w[75
             82
             90
             100
             110
             122
             135
             150
             165
             180
             200
             225
             245
             270],
          %w[70 75 82 90 100p 110 122 135 150 165 180],
          %w[65 70 75 82p 90p 100 110 122],
          %w[60 65 70p 75p 82 90],
          %w[50 60 65 70 75],
          %w[40 50 60 65],
        ].freeze

        PHASES = [
          {
            name: '2',
            train_limit: 4,
            tiles: [:yellow],
            status: ['minor_limit_two'],
            operating_rounds: 2,
          },
          {
            name: '3',
            on: '3',
            train_limit: 4,
            tiles: %i[yellow green],
            status: ['minor_limit_two'],
            operating_rounds: 2,
          },
          {
            name: '4',
            on: '4',
            train_limit: 3,
            tiles: %i[yellow green],
            status: ['minor_limit_one'],
            operating_rounds: 2,
          },
          {
            name: '5',
            on: '5',
            train_limit: 2,
            tiles: %i[yellow green brown],
            status: %w[minor_limit_one normal_formation],
            operating_rounds: 2,
          },
          {
            name: '6',
            on: '6',
            train_limit: 2,
            tiles: %i[yellow green brown],
            status: ['normal_formation'],
            operating_rounds: 2,
          },
          {
            name: '8',
            on: '8',
            train_limit: 2,
            tiles: %i[yellow green brown gray],
            status: ['normal_formation'],
            operating_rounds: 2,
          },
        ].freeze

        TRAINS = [
          {
            name: '2',
            rusts_on: '4',
            distance: [{ 'nodes' => %w[city offboard], 'pay' => 2, 'visit' => 2 },
                       { 'nodes' => ['offboard'], 'pay' => 2 },
                       { 'nodes' => ['town'], 'pay' => 99, 'visit' => 99 }],
            price: 100,
            num: 15,
          },
          {
            name: '3',
            rusts_on: '6',
            distance: [{ 'nodes' => %w[city offboard], 'pay' => 3, 'visit' => 3 },
                       { 'nodes' => ['offboard'], 'pay' => 2 },
                       { 'nodes' => ['town'], 'pay' => 99, 'visit' => 99 }],
            price: 200,
            num: 5,
          },
          { name: 'P', distance: 99, price: 100, num: 5 },
          {
            name: '4',
            rusts_on: '8',
            distance: [{ 'nodes' => %w[city offboard], 'pay' => 4, 'visit' => 4 },
                       { 'nodes' => ['offboard'], 'pay' => 2 },
                       { 'nodes' => ['town'], 'pay' => 99, 'visit' => 99 }],
            price: 300,
            num: 4,
          },
          {
            name: '5',
            distance: [{ 'nodes' => %w[city offboard], 'pay' => 5, 'visit' => 5 },
                       { 'nodes' => ['offboard'], 'pay' => 2 },
                       { 'nodes' => ['town'], 'pay' => 99, 'visit' => 99 }],
            events: [{ 'type' => 'minor_exchange' }],
            price: 500,
            num: 3,
          },
          {
            name: '6',
            distance: [{ 'nodes' => %w[city offboard], 'pay' => 6, 'visit' => 6 },
                       { 'nodes' => ['offboard'], 'pay' => 2 },
                       { 'nodes' => ['town'], 'pay' => 99, 'visit' => 99 }],
            price: 600,
            num: 2,
          },
          {
            name: '8',
            distance: [{ 'nodes' => %w[city offboard], 'pay' => 8, 'visit' => 8 },
                       { 'nodes' => ['offboard'], 'pay' => 2 },
                       { 'nodes' => ['town'], 'pay' => 99, 'visit' => 99 }],
            price: 800,
            num: 99,
          },
        ].freeze

        CORPORATIONS = [
          {
            float_percent: 50,
            sym: 'BNR',
            name: 'Belgian National Railways',
            logo: '18_eu/BNR',
            simple_logo: '18_eu/BNR.alt',
            tokens: [0, 0, 0, 0, 0],
            color: '#ffcb05',
            text_color: 'black',
          },
          {
            float_percent: 50,
            sym: 'DR',
            name: 'Dutch Railways',
            logo: '18_eu/DR',
            simple_logo: '18_eu/DR.alt',
            tokens: [0, 0, 0, 0, 0],
            color: '#fff200',
            text_color: 'black',
          },
          {
            float_percent: 50,
            sym: 'FS',
            name: 'Italian State Railways',
            logo: '18_eu/FS',
            simple_logo: '18_eu/FS.alt',
            tokens: [0, 0, 0, 0, 0],
            color: '#00a651',
          },
          {
            float_percent: 50,
            sym: 'RBSR',
            name: 'Royal Bavarian State Railroad',
            logo: '18_eu/RBSR',
            simple_logo: '18_eu/RBSR.alt',
            tokens: [0, 0, 0, 0, 0],
            color: '#8ed8f8',
            text_color: 'black',
          },
          {
            float_percent: 50,
            sym: 'RPR',
            name: 'Royal Prussian Railway',
            logo: '18_eu/RPR',
            simple_logo: '18_eu/RPR.alt',
            tokens: [0, 0, 0, 0, 0],
            color: '#00a4e4',
          },
          {
            float_percent: 50,
            sym: 'AIRS',
            name: 'Austrian Imperial Royal State',
            logo: '18_eu/AIRS',
            simple_logo: '18_eu/AIRS.alt',
            tokens: [0, 0, 0, 0, 0],
            color: '#fffcd5',
            text_color: 'black',
          },
          {
            float_percent: 50,
            sym: 'SNCF',
            name: 'SNCF',
            logo: '18_eu/SNCF',
            simple_logo: '18_eu/SNCF.alt',
            tokens: [0, 0, 0, 0, 0],
            color: '#ed1c24',
          },
          {
            float_percent: 50,
            sym: 'GSR',
            name: 'German State Railways',
            logo: '18_eu/GSR',
            simple_logo: '18_eu/GSR.alt',
            tokens: [0, 0, 0, 0, 0],
            color: '#231f20',
          },
        ].freeze

        MINORS = [
          {
            sym: '1',
            name: 'Chemin de Fer du Nord',
            coordinates: 'A10',
            city: 0,
            logo: '18_eu/1',
            simple_logo: '18_eu/1.alt',
            tokens: [0],
            color: 'black',
            text_color: 'white',
            abilities: [
            {
              type: 'exchange',
              corporations: %w[BNR DR FS RBSR RPR AIRS SNCF GSR],
              owner_type: 'player',
              from: 'ipo',
            },
          ],
          },
          {
            sym: '2',
            name: 'État Belge',
            coordinates: 'C8',
            logo: '18_eu/2',
            simple_logo: '18_eu/2.alt',
            tokens: [0],
            color: 'black',
            text_color: 'white',
            abilities: [
              {
                type: 'exchange',
                corporations: %w[BNR DR FS RBSR RPR AIRS SNCF GSR],
                owner_type: 'player',
                from: 'ipo',
              },
            ],
          },
          {
            sym: '3',
            name: 'Paris-Lyon-Méditerranée',
            coordinates: 'A10',
            city: 1,
            logo: '18_eu/3',
            simple_logo: '18_eu/3.alt',
            tokens: [0],
            color: 'black',
            text_color: 'white',
            abilities: [
              {
                type: 'exchange',
                corporations: %w[BNR DR FS RBSR RPR AIRS SNCF GSR],
                owner_type: 'player',
                from: 'ipo',
              },
            ],
          },
          {
            sym: '4',
            name: 'Leipzig-Dresdner-Bahn',
            coordinates: 'J7',
            city: 0,
            logo: '18_eu/4',
            simple_logo: '18_eu/4.alt',
            tokens: [0],
            color: 'black',
            text_color: 'white',
            abilities: [
              {
                type: 'exchange',
                corporations: %w[BNR DR FS RBSR RPR AIRS SNCF GSR],
                owner_type: 'player',
                from: 'ipo',
              },
            ],
          },
          {
            sym: '5',
            name: 'Ferrovia Adriatica',
            coordinates: 'H19',
            city: 0,
            logo: '18_eu/5',
            simple_logo: '18_eu/5.alt',
            tokens: [0],
            color: 'black',
            text_color: 'white',
            abilities: [
              {
                type: 'exchange',
                corporations: %w[BNR DR FS RBSR RPR AIRS SNCF GSR],
                owner_type: 'player',
                from: 'ipo',
              },
            ],
          },
          {
            sym: '6',
            name: 'Kaiser-Ferdinand-Nordbahn',
            coordinates: 'K14',
            city: 0,
            logo: '18_eu/6',
            simple_logo: '18_eu/6.alt',
            tokens: [0],
            color: 'black',
            text_color: 'white',
            abilities: [
              {
                type: 'exchange',
                corporations: %w[BNR DR FS RBSR RPR AIRS SNCF GSR],
                owner_type: 'player',
                from: 'ipo',
              },
            ],
          },
          {
            sym: '7',
            name: 'Berlin-Potsdamer-Bahn',
            coordinates: 'J5',
            city: 0,
            logo: '18_eu/7',
            simple_logo: '18_eu/7.alt',
            tokens: [0],
            color: 'black',
            text_color: 'white',
            abilities: [
              {
                type: 'exchange',
                corporations: %w[BNR DR FS RBSR RPR AIRS SNCF GSR],
                owner_type: 'player',
                from: 'ipo',
              },
            ],
          },
          {
            sym: '8',
            name: 'Ungarische Staatsbahn',
            coordinates: 'M16',
            city: 0,
            logo: '18_eu/8',
            simple_logo: '18_eu/8.alt',
            tokens: [0],
            color: 'black',
            text_color: 'white',
            abilities: [
              {
                type: 'exchange',
                corporations: %w[BNR DR FS RBSR RPR AIRS SNCF GSR],
                owner_type: 'player',
                from: 'ipo',
              },
            ],
          },
          {
            sym: '9',
            name: 'Berlin-Stettiner-Bahn',
            coordinates: 'J5',
            city: 1,
            logo: '18_eu/9',
            simple_logo: '18_eu/9.alt',
            tokens: [0],
            color: 'black',
            text_color: 'white',
            abilities: [
              {
                type: 'exchange',
                corporations: %w[BNR DR FS RBSR RPR AIRS SNCF GSR],
                owner_type: 'player',
                from: 'ipo',
              },
            ],
          },
          {
            sym: '10',
            name: 'Strade Ferrate Alta Italia',
            coordinates: 'E18',
            city: 0,
            logo: '18_eu/10',
            simple_logo: '18_eu/10.alt',
            tokens: [0],
            color: 'black',
            text_color: 'white',
            abilities: [
              {
                type: 'exchange',
                corporations: %w[BNR DR FS RBSR RPR AIRS SNCF GSR],
                owner_type: 'player',
                from: 'ipo',
              },
            ],
          },
          {
            sym: '11',
            name: 'Südbahn',
            coordinates: 'K14',
            city: 1,
            logo: '18_eu/11',
            simple_logo: '18_eu/11.alt',
            tokens: [0],
            color: 'black',
            text_color: 'white',
            abilities: [
              {
                type: 'exchange',
                corporations: %w[BNR DR FS RBSR RPR AIRS SNCF GSR],
                owner_type: 'player',
                from: 'ipo',
              },
            ],
          },
          {
            sym: '12',
            name: 'Hollandsche Maatschappij',
            coordinates: 'D3',
            city: 0,
            logo: '18_eu/12',
            simple_logo: '18_eu/12.alt',
            tokens: [0],
            color: 'black',
            text_color: 'white',
            abilities: [
              {
                type: 'exchange',
                corporations: %w[BNR DR FS RBSR RPR AIRS SNCF GSR],
                owner_type: 'player',
                from: 'ipo',
              },
            ],
          },
          {
            sym: '13',
            name: 'Ludwigsbahn',
            coordinates: 'G12',
            city: 0,
            logo: '18_eu/13',
            simple_logo: '18_eu/13.alt',
            tokens: [0],
            color: 'black',
            text_color: 'white',
            abilities: [
              {
                type: 'exchange',
                corporations: %w[BNR DR FS RBSR RPR AIRS SNCF GSR],
                owner_type: 'player',
                from: 'ipo',
              },
            ],
          },
          {
            sym: '14',
            name: 'Ligne Strasbourg-Bâle',
            coordinates: 'D13',
            city: 0,
            logo: '18_eu/14',
            simple_logo: '18_eu/14.alt',
            tokens: [0],
            color: 'black',
            text_color: 'white',
            abilities: [
              {
                type: 'exchange',
                corporations: %w[BNR DR FS RBSR RPR AIRS SNCF GSR],
                owner_type: 'player',
                from: 'ipo',
              },
            ],
          },
          {
            sym: '15',
            name: 'Grand Central',
            coordinates: 'B17',
            city: 0,
            logo: '18_eu/15',
            simple_logo: '18_eu/15.alt',
            tokens: [0],
            color: 'black',
            text_color: 'white',
            abilities: [
              {
                type: 'exchange',
                corporations: %w[BNR DR FS RBSR RPR AIRS SNCF GSR],
                owner_type: 'player',
                from: 'ipo',
              },
            ],
          },
        ].freeze

        HEXES = {
          red: {
            ['N17'] => 'offboard=revenue:yellow_30|brown_50;path=a:2,b:_0',
            ['N5'] => 'offboard=revenue:yellow_20|brown_30;path=a:1,b:_0',
            ['A6'] => 'offboard=revenue:yellow_40|brown_70;path=a:0,b:_0;path=a:5,b:_0',
            ['G2'] =>
                   'offboard=revenue:yellow_30|brown_50;path=a:1,b:_0;path=a:_0,b:5;'\
                   'path=a:0,b:_0;path=a:_0,b:5;path=a:0,b:_0;path=a:_0,b:1',
            ['G22'] =>
                   'offboard=revenue:yellow_30|brown_50;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0',
          },
          blue: {
            ['D1'] =>
                     'offboard=revenue:10,visit_cost:0,route:optional;path=a:0,b:_0;icon=image:port;',
            %w[B21 E22 I20] =>
            'offboard=revenue:10,visit_cost:0,route:optional;path=a:3,b:_0;icon=image:port;',
          },
          yellow: {
            ['A10'] =>
                     'city=revenue:40,loc:15;city=revenue:40;path=a:4,b:_0;path=a:5,b:_1;label=P',
            ['J5'] =>
            'city=revenue:30;city=revenue:30;path=a:4,b:_0;path=a:1,b:_1;label=B-V',
            ['K14'] =>
            'city=revenue:30;city=revenue:30;path=a:0,b:_0;path=a:3,b:_1;label=B-V',
            ['K16'] => 'path=a:1,b:3;upgrade=cost:60,terrain:mountain',
          },
          white: {
            %w[B17 C8 D3 D13 E18 G12 H19 J7 M16] =>
                     'city=revenue:0;label=Y',
            %w[B19 D7 D19 E6 E20 F9 I18 J11] => 'city=revenue:0',
            %w[B7
               B13
               C4
               C6
               C16
               D5
               D15
               E12
               F3
               F11
               F21
               G6
               G10
               G20
               H7
               I8
               K4
               K12
               L5] => 'town=revenue:0',
            %w[C20 E14 H15 I14 L15 M10] =>
            'town=revenue:0;upgrade=cost:60,terrain:mountain',
            %w[A14
               A16
               C10
               D9
               D11
               F15
               G16
               I10
               I12
               J9
               J13
               K8
               L9] => 'upgrade=cost:60,terrain:mountain',
            %w[C18 D17 E16 F17 G18 H17 I16 J15] =>
            'upgrade=cost:120,terrain:mountain',
            %w[A8
               A12
               A18
               A20
               B9
               B15
               C12
               C14
               D21
               E4
               E8
               E10
               F5
               F7
               F13
               G4
               G8
               G14
               H3
               H5
               H9
               H11
               H13
               H21
               I4
               J3
               J17
               J19
               K6
               K10
               K18
               L7
               L11
               L13
               L17
               M6
               M8
               M12
               M14
               B11
               F19
               I6] => '',
          },
        }.freeze

        LAYOUT = :flat

        SELL_BUY_ORDER = :sell_buy
        SELL_AFTER = :operate
        HOME_TOKEN_TIMING = :par

        MIN_BID_INCREMENT = 5
        MUST_BID_INCREMENT_MULTIPLE = true
        TOKENS_FEE = 100

        FIRST_OR_MINOR_TILE_LAYS = [{ lay: true, upgrade: false }, { lay: true, upgrade: false }].freeze
        MINOR_TILE_LAYS = [{ lay: true, upgrade: false }].freeze
        TILE_LAYS = [{ lay: true, upgrade: true }].freeze

        EVENTS_TEXT = Base::EVENTS_TEXT.merge(
            'minor_exchange' => [
              'Minor Exchange',
              'Conduct the Minor Company Final Exchange Round immediately prior to the next Stock Round.',
            ],
          ).freeze

        STATUS_TEXT = Base::STATUS_TEXT.merge(
          'minor_limit_two' => [
            'Minor Train Limit: 2',
            'Minor companies are limited to owning 2 trains.',
          ],
          'minor_limit_one' => [
            'Minor Train Limit: 1',
            'Minor companies are limited to owning 1 train.',
          ],
          'normal_formation' => [
            'Full Capitalization',
            'Corporations may be formed without exchanging a minor, selecting any open city. '\
            'The five remaining shares are placed in the bank pool, with the par price paid '\
            'to the corporation.',
          ]
        ).freeze

        def setup
          @minors.each do |minor|
            train = @depot.upcoming[0]
            buy_train(minor, train, :free)
            hex = hex_by_id(minor.coordinates)
            city = minor.city.to_i || 0
            hex.tile.cities[city].place_token(minor, minor.next_token, free: true)
          end

          add_optional_train('3') if @optional_rules&.include?(:extra_three_train)
          add_optional_train('3') if @optional_rules&.include?(:second_extra_three_train)
          add_optional_train('4') if @optional_rules&.include?(:extra_four_train)

          @minor_exchange = nil
        end

        # this could be a useful function in depot itself
        def add_optional_train(type)
          modified_trains = @depot.trains.select { |t| t.name == type }
          new_train = modified_trains.first.clone
          new_train.index = modified_trains.length
          @depot.add_train(new_train)
        end

        def ipo_name(_entity = nil)
          'Treasury'
        end

        def init_round
          Round::Auction.new(self, [G18EU::Step::ModifiedDutchAuction])
        end

        def exchange_for_partial_presidency?
          false
        end

        def operating_round(round_num)
          Round::Operating.new(self, [
            G18EU::Step::Bankrupt,
            G18EU::Step::Track,
            Engine::Step::Token,
            Engine::Step::Route,
            G18EU::Step::Dividend,
            G18EU::Step::BuyTrain,
            Engine::Step::IssueShares,
            G18EU::Step::DiscardTrain,
          ], round_num: round_num)
        end

        def stock_round
          Round::Stock.new(self, [
            G18EU::Step::DiscardTrain,
            G18EU::Step::HomeToken,
            G18EU::Step::ReplaceToken,
            G18EU::Step::BuySellParShares,
          ])
        end

        def new_minor_exchange_round
          # TODO: Implement Minor Exchange Round
          @minor_exchange = :done
          new_stock_round
        end

        # I don't like duplicating all of this just to add the minor exchange round, but
        # it requires refactoring the base code to be any cleaner
        def next_round!
          @round =
            case @round
            when Round::Stock
              @operating_rounds = @phase.operating_rounds
              reorder_players
              new_operating_round
            when Round::Operating
              if @round.round_num < @operating_rounds
                or_round_finished
                new_operating_round(@round.round_num + 1)
              else
                @turn += 1
                or_round_finished
                or_set_finished
                if @minor_exchange == :triggered
                  new_minor_exchange_round
                else
                  new_stock_round
                end
              end
            when init_round.class
              init_round_finished
              reorder_players
              new_operating_round(@round.round_num)
            end
        end

        def train_limit(entity)
          return super unless entity.minor?

          @phase.name.to_i > 3 ? 1 : 2
        end

        def tile_lays(entity)
          return FIRST_OR_MINOR_TILE_LAYS if entity.minor? && !entity.operated?
          return MINOR_TILE_LAYS if entity.minor?

          super
        end

        def event_minor_exchange!
          @log << '-- Event: Minor Exchange occurs before next Stock Round --'

          @minor_exchange = :triggered
        end

        def player_card_minors(player)
          @minors.select { |m| m.owner == player }
        end

        def all_corporations
          @minors + @corporations
        end

        def player_sort(entities)
          minors, majors = entities.partition(&:minor?)
          (minors.sort_by { |m| m.name.to_i } + majors.sort_by(&:name)).group_by(&:owner)
        end

        # def revenue_for(route, stops)
        # revenue = super

        # TODO: Token Bonus
        # TODO: Pullman Car

        # revenue
        # end

        # def revenue_str(route)
        # str = super

        # TODO: Token Bonus
        # TODO: Pullman Car

        # str
        # end

        def emergency_issuable_cash(corporation)
          emergency_issuable_bundles(corporation).max_by(&:num_shares)&.price || 0
        end

        def emergency_issuable_bundles(entity)
          issuable_shares(entity)
        end

        def issuable_shares(entity)
          return [] unless entity.corporation?
          return [] unless entity.num_ipo_shares

          bundles_for_corporation(entity, entity)
            .select { |bundle| @share_pool.fit_in_bank?(bundle) }
            .map { |bundle| reduced_bundle_price_for_market_drop(bundle) }
        end

        def redeemable_shares(entity)
          return [] unless entity.corporation?

          bundles_for_corporation(share_pool, entity)
            .reject { |bundle| entity.cash < bundle.price }
        end

        def reduced_bundle_price_for_market_drop(bundle)
          return bundle if bundle.num_shares == 1

          new_price = (1..bundle.num_shares).sum do |max_drops|
            @stock_market.find_share_price(bundle.corporation, (1..max_drops).map { |_| :up }).price
          end

          bundle.share_price = new_price / bundle.num_shares

          bundle
        end

        def owns_any_minor?(entity)
          @minors.find { |minor| minor.owner == entity }
        end

        def can_par?(corporation, entity)
          return super if @phase.status.include?('normal_formation')
          return false unless owns_any_minor?(entity)

          super
        end

        def all_free_hexes(corporation)
          hexes.select do |hex|
            hex.tile.cities.any? { |city| city.tokenable?(corporation, free: true) }
          end
        end

        # The player will swap one of their minors tokens for the major home token
        # This gets the list of cities where their minors have tokens
        def all_minor_cities(corporation)
          @minors.map do |minor|
            next unless minor.owner == corporation.owner

            # only need to use first since minors have one token
            minor.tokens.first.city
          end.compact
        end

        def all_minor_hexes(corporation)
          all_minor_cities(corporation).map(&:hex)
        end

        def home_token_locations(corporation)
          return all_free_hexes(corporation) if @minors.empty?

          all_minor_hexes(corporation)
        end

        def exchange_corporations(exchange_ability)
          return super if !exchange_ability.owner.minor? || @loading

          parts = graph.connected_nodes(exchange_ability.owner).keys
          parts.select(&:city?).flat_map { |c| c.tokens.compact.map(&:corporation) }
        end

        def after_par(corporation)
          @log << "#{corporation.name} spends #{format_currency(TOKENS_FEE)} for four additional tokens"

          corporation.spend(TOKENS_FEE, @bank)
        end
      end
    end
  end
end
