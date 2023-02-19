# frozen_string_literal: true

require_relative 'meta'
require_relative '../base'
require_relative '../../game_error'
require_relative '../g_1856/game'

module Engine
  module Game
    module G1836Jr56
      class Game < G1856::Game
        include_meta(G1836Jr56::Meta)

        CURRENCY_FORMAT_STR = '%s F'

        BANK_CASH = 6000

        CERT_LIMIT = { 2 => 20, 3 => 13, 4 => 10 }.freeze
        def cert_limit(_player = nil)
          # cert limit isn't dynamic in 1836jr56
          CERT_LIMIT[@players.size]
        end

        STARTING_CASH = { 2 => 450, 3 => 300, 4 => 225 }.freeze

        TILES = {
          '2' => 1,
          '3' => 3,
          '4' => 3,
          '5' => 2,
          '6' => 2,
          '7' => 7,
          '8' => 13,
          '9' => 13,
          '14' => 4,
          '15' => 4,
          '16' => 1,
          '17' => 1,
          '18' => 1,
          '19' => 1,
          '20' => 1,
          '23' => 4,
          '24' => 4,
          '25' => 1,
          '26' => 1,
          '27' => 1,
          '28' => 1,
          '29' => 1,
          '39' => 1,
          '40' => 1,
          '41' => 3,
          '42' => 3,
          '43' => 2,
          '44' => 1,
          '45' => 2,
          '46' => 2,
          '47' => 2,
          '56' => 1,
          '57' => 4,
          '58' => 3,
          '59' => 2,
          '63' => 4,
          '64' => 1,
          '65' => 1,
          '66' => 1,
          '67' => 1,
          '68' => 1,
          '70' => 1,
          '120' => 1,
          '121' => 2,
          '122' => 1,
          '123' => 1,
          '124' => 1,
          '125' =>
          {
            'count' => 4,
            'color' => 'brown',
            'code' =>
            'city=revenue:40,slots:2;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0',
          },
          '126' => 1,
          '127' => 1,
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

        PHASES = [
          {
            name: '2',
            train_limit: 4,
            tiles: [:yellow],
            status: %w[escrow facing_2],
            operating_rounds: 1,
          },
          {
            name: "2'",
            on: "2'",
            train_limit: 4,
            tiles: [:yellow],
            status: %w[escrow facing_3],
            operating_rounds: 1,
          },
          {
            name: '3',
            on: '3',
            train_limit: 4,
            tiles: %i[yellow green],
            operating_rounds: 2,
            status: %w[escrow facing_3 can_buy_companies],
          },
          {
            name: "3'",
            on: "3'",
            train_limit: 4,
            tiles: %i[yellow green],
            operating_rounds: 2,
            status: %w[escrow facing_4 can_buy_companies],
          },
          {
            name: '4',
            on: '4',
            train_limit: 3,
            tiles: %i[yellow green],
            operating_rounds: 2,
            status: %w[escrow facing_4 can_buy_companies],
          },
          {
            name: "4'",
            on: "4'",
            train_limit: 3,
            tiles: %i[yellow green],
            operating_rounds: 2,
            status: %w[incremental facing_5 can_buy_companies],
          },
          {
            name: '5',
            on: '5',
            train_limit: 2,
            tiles: %i[yellow green brown],
            status: %w[incremental facing_5],
            operating_rounds: 3,
          },
          {
            name: "5'",
            on: "5'",
            train_limit: 2,
            tiles: %i[yellow green brown],
            status: %w[fullcap facing_6],
            operating_rounds: 3,
          },
          {
            name: '6',
            on: '6',
            train_limit: 2,
            tiles: %i[yellow green brown gray],
            status: %w[fullcap facing_6 upgradable_towns no_loans],
            operating_rounds: 3,
          },
          {
            name: '8',
            on: '8',
            train_limit: 2,
            tiles: %i[yellow green brown gray black],
            status: %w[fullcap facing_6 upgradable_towns no_loans],
            operating_rounds: 3,
          },
        ].freeze

        TRAINS = [{ name: '2', distance: 2, price: 100, rusts_on: '4', num: 4 },
                  { name: "2'", distance: 2, price: 100, rusts_on: '4', num: 1 },
                  { name: '3', distance: 3, price: 225, rusts_on: '6', num: 3 },
                  { name: "3'", distance: 3, price: 225, rusts_on: '6', num: 1 },
                  { name: '4', distance: 4, price: 350, rusts_on: '8', num: 2 },
                  {
                    name: "4'",
                    distance: 4,
                    price: 350,
                    rusts_on: '8',
                    num: 1,
                    events: [{ 'type' => 'no_more_escrow_corps' }],
                  },
                  {
                    name: '5',
                    distance: 5,
                    price: 550,
                    num: 1,
                    events: [{ 'type' => 'close_companies' }],
                  },
                  {
                    name: "5'",
                    distance: 5,
                    price: 550,
                    num: 1,
                    events: [{ 'type' => 'no_more_incremental_corps' }],
                  },
                  {
                    name: '6',
                    distance: 6,
                    price: 700,
                    num: 2,
                    events: [{ 'type' => 'nationalization' }, { 'type' => 'remove_tokens' }],
                  },
                  {
                    name: '8',
                    distance: 8,
                    price: 1000,
                    num: 5,
                    available_on: '6',
                    discount: { '4' => 350, "4'" => 350, '5' => 350, "5'" => 350, '6' => 350 },
                  }].freeze

        COMPANIES = [
          {
            name: 'Amsterdam Canal Company',
            value: 20,
            revenue: 5,
            desc: 'No special ability. Blocks hex D6 while owned by player.',
            sym: 'ACC',
            abilities: [{ type: 'blocks_hexes', owner_type: 'player', hexes: ['D6'] }],
            color: nil,
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
            color: nil,
          },
          {
            name: 'Charbonnages du Hainaut',
            value: 50,
            revenue: 10,
            desc: 'Owning corporation may place a tile and station token in the CdH hex J8 for only the F60 cost of'\
                  ' the mountain. The track is not required to be connected to existing track of this corporation (or any'\
                  " corporation), and can be used as a teleport. This counts as the corporation's track lay for that turn."\
                  ' Blocks hex J8 while owned by player.',
            sym: 'CdH',
            abilities: [{ type: 'blocks_hexes', owner_type: 'player', hexes: ['J8'] },
                        {
                          type: 'teleport',
                          owner_type: 'corporation',
                          tiles: %w[6 5 57],
                          hexes: ['J8'],
                        }],
            color: nil,
          },
          {
            # Rules questions
            # https://boardgamegeek.com/thread/2344775/regie-des-postes-private-company-clarification
            name: 'Régie des Postes',
            value: 70,
            revenue: 15,
            desc: 'Owning Corporation may place the +"20" token on any City or Town. The value of the location is '\
                  ' increased by F20 for each and every time that Corporation\'s trains visit it',
            sym: 'RdP',
            abilities: [
              {
                type: 'assign_hexes',
                when: 'owning_corp_or_turn',
                hexes: %w[A9 B8 B10 D6 E5 E11 F4 F10 G7 H2 H4 H6 H10 I3 I9 J6 J8 K11],
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
        ].freeze

        ASSIGNMENT_TOKENS = {
          'RdP' => '/icons/1846/sc_token.svg',
        }.freeze
        PORT_HEXES = %w[A9 B8 B10 D6 E5 E11 F4 F10 G7 H2 H4 H6 H10 I3 I9 J6 J8 K11].freeze
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
          {
            sym: 'MESS',
            logo: '1836_jr/DR',
            simple_logo: '1836_jr/DR.alt',
            name: 'Maatschappij tot Exploitie van de Staats-Spoorwegen',
            tokens: [],
            color: '#fff',
            text_color: '#000',
            abilities: [
              {
                type: 'train_buy',
                description: 'Inter train buy/sell at face value',
                face_value: true,
              },
              {
                type: 'train_limit',
                increase: 99,
                description: '3 train limit',
              },
              {
                type: 'borrow_train',
                train_types: %w[8 D],
                description: 'May borrow a train when trainless*',
              },
            ],
            reservation_color: nil,
          },
        ].freeze

        HAMILTON_HEX = 'A1' # Don't use; the future_label renders nicely in 1836jr56
        DESTINATIONS = {
          'NBDS' => 'E5',
          'HSM' => 'E11',
          'NFL' => 'D6',
          'B' => 'H10',
          'Nord' => 'I9',
          'GCL' => 'K13',
        }.freeze
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
                     'city=revenue:40;path=a:0,b:_0;path=a:_0,b:5;label=T;upgrade=cost:40,terrain:water',
            ['E5'] => 'city=revenue:0;city=revenue:0;label=OO;future_label=label:H,color:gray',
            %w[E11 H10] =>
            'city=revenue:0;city=revenue:0;label=OO;upgrade=cost:40,terrain:water',
            ['H6'] => 'city=revenue:30;path=a:1,b:_0;path=a:_0,b:3;label=B-L;future_label=label:Lon,color:brown',
            ['I3'] => 'city=revenue:30;path=a:0,b:_0;path=a:_0,b:4;label=B-L;future_label=label:Bar,color:brown',
          },
          blue: {
            %w[E3 G1] =>
            'offboard=revenue:green_20|brown_30,format:+%s,groups:port,route:never;'\
            'path=a:4,b:_0,terminal:1;path=a:5,b:_0,terminal:1',
          },
          green: {
            ['J2'] =>
            'offboard=revenue:green_20|brown_30,format:+%s,groups:port,route:never;'\
            'path=a:3,b:_0,terminal:1;path=a:4,b:_0,terminal:1',
          },
        }.freeze

        LAYOUT = :pointy

        SELL_BUY_ORDER = :sell_buy_sell
        TILE_RESERVATION_BLOCKS_OTHERS = :always
        def national
          @national ||= corporation_by_id('MESS')
        end

        def port
          @port ||= company_by_id('RdP')
        end

        def company_bought(company, entity) end

        def tunnel
          raise GameError, "'tunnel' Should not be used"
        end

        def bridge
          raise GameError, "'bridge' Should not be used"
        end

        def wsrc
          raise GameError, "'wsrc' Should not be used"
        end

        def setup
          @straight_city ||= @all_tiles.find { |t| t.name == '57' }
          @sharp_city ||= @all_tiles.find { |t| t.name == '5' }
          @gentle_city ||= @all_tiles.find { |t| t.name == '6' }

          @straight_track ||= @all_tiles.find { |t| t.name == '9' }
          @sharp_track ||= @all_tiles.find { |t| t.name == '7' }
          @gentle_track ||= @all_tiles.find { |t| t.name == '8' }

          @x_city ||= @all_tiles.find { |t| t.name == '14' }
          @k_city ||= @all_tiles.find { |t| t.name == '15' }

          @brown_london ||= @all_tiles.find { |t| t.name == '126' }
          @brown_barrie ||= @all_tiles.find { |t| t.name == '127' }

          @gray_hamilton ||= @all_tiles.find { |t| t.name == '123' }

          @post_nationalization = false
          @nationalization_train_discard_trigger = false
          @national_formed = false

          @pre_national_percent_by_player = {}
          @pre_national_market_percent = 0

          @pre_national_market_prices = {}
          @nationalized_corps = []

          @bankrupted = false

          @destination_statuses = {}

          # Is the president of the national a "false" president?
          # A false president gets the presidency with only one share; in this case the president gets
          # the full president's certificate but is obligated to buy up to the full presidency in the
          # following SR unless a different player becomes rightfully president during share exchange
          # It is impossible for someone who didn't become president in
          # exchange (1 share tops) to steal the presidency in the SR because
          # they'd have to buy 2 shares in one action which is a no-no
          # nil: Presidency not awarded yet at all
          # not-nl: 1-share false presidency has been awarded to the player (value of var)
          @false_national_president = nil

          # CGR flags
          @national_ever_owned_permanent = false

          # Corp -> Borrowed Train
          @borrowed_trains = {}
          create_destinations(DESTINATIONS)
          national.add_ability(self.class::NATIONAL_IMMOBILE_SHARE_PRICE_ABILITY)
          national.add_ability(self.class::NATIONAL_FORCED_WITHHOLD_ABILITY)
        end

        def stock_round
          G1856::Round::Stock.new(self, [
            Engine::Step::DiscardTrain,
            Engine::Step::Exchange,
            Engine::Step::SpecialTrack,
            G1856::Step::BuySellParShares,
          ])
        end

        def operating_round(round_num)
          G1856::Round::Operating.new(self, [
            G1856::Step::Bankrupt,
            G1856::Step::CashCrisis,
            # No exchanges.
            G1856::Step::Assign,
            G1856::Step::Loan,
            Engine::Step::SpecialTrack,
            Engine::Step::SpecialToken,
            Engine::Step::BuyCompany,
            Engine::Step::HomeToken,

            # Nationalization!!
            G1856::Step::NationalizationPayoff,
            G1856::Step::RemoveTokens,
            G1856::Step::NationalizationDiscardTrains,
            G1836Jr56::Step::Track,
            G1856::Step::Escrow,
            G1856::Step::Token,
            G1856::Step::BorrowTrain,
            Engine::Step::Route,
            # Interest - See Loan
            G1856::Step::Dividend,
            Engine::Step::DiscardTrain,
            G1836Jr56::Step::BuyTrain,
            # Repay Loans - See Loan
            [G1856::Step::BuyCompany, { blocks: true }],
          ], round_num: round_num)
        end

        def event_close_companies!
          @log << '-- Event: Private companies close --'
          @companies.each do |company|
            if (ability = abilities(company, :close, on_phase: 'any')) && (ability.on_phase == 'never' ||
                      @phase.phases.any? { |phase| ability.on_phase == phase[:name] })
              next
            end

            company.close!
          end
        end

        def icon_path(corp)
          super if corp == national

          "../logos/1836_jr/#{corp}"
        end

        def revenue_for(route, stops)
          revenue = super # port private is counted in super

          port_stop = stops.find { |stop| stop.groups.include?('port') }
          # Port offboards
          if port_stop
            raise GameError, "#{port_stop.tile.location_name} must contain 2 other stops" if stops.size < 3

            per_token = port_stop.route_revenue(route.phase, route.train)
            revenue -= per_token # It's already been counted, so remove

            revenue += stops.sum do |stop|
              next per_token if stop.city? && stop.tokened_by?(route.train.owner)

              0
            end
          end

          revenue
        end
      end
    end
  end
end
