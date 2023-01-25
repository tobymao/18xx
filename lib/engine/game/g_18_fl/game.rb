# frozen_string_literal: true

require_relative 'meta'
require_relative '../base'
require_relative 'round/operating'
require_relative '../cities_plus_towns_route_distance_str'

module Engine
  module Game
    module G18FL
      class Game < Game::Base
        include_meta(G18FL::Meta)
        include CitiesPlusTownsRouteDistanceStr

        register_colors(black: '#37383a',
                        orange: '#f48221',
                        brightGreen: '#76a042',
                        red: '#d81e3e',
                        turquoise: '#00a993',
                        blue: '#0189d1',
                        brown: '#7b352a')

        CURRENCY_FORMAT_STR = '$%s'

        BANK_CASH = 8000

        CERT_LIMIT = { 2 => 21, 3 => 15, 4 => 12 }.freeze

        STARTING_CASH = { 2 => 300, 3 => 300, 4 => 300 }.freeze

        CAPITALIZATION = :full

        MUST_SELL_IN_BLOCKS = true

        TILE_TYPE = :lawson

        TILES = {
          '3' => 6,
          '4' => 8,
          '6o' =>
          {
            'count' => 1,
            'color' => 'yellow',
            'code' => 'city=revenue:20,slots:1;path=a:1,b:_0;path=a:3,b:_0;label=O',
          },
          '6fl' =>
          {
            'count' => 1,
            'color' => 'yellow',
            'code' => 'city=revenue:20,slots:1;path=a:1,b:_0;path=a:3,b:_0;label=FL',
          },
          '8' => 10,
          '9' => 14,
          '58' => 8,
          '15' =>
          {
            'count' => 2,
            'color' => 'green',
            'code' =>
            'city=revenue:30,slots:2;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;label=K',
          },
          '80' => 4,
          '81' => 4,
          '82' => 6,
          '83' => 6,
          '141' => 5,
          '142' => 5,
          '143' => 5,
          '405' =>
          {
            'count' => 2,
            'color' => 'green',
            'code' =>
            'city=revenue:40,slots:2;path=a:1,b:_0;path=a:5,b:_0;path=a:6,b:_0;label=T',
          },
          '443o' =>
          {
            'count' => 1,
            'color' => 'green',
            'code' =>
            'city=revenue:30,slots:2;path=a:1,b:_0;path=a:3,b:_0;path=a:5,b:_0;label=O',
          },
          '443fl' =>
          {
            'count' => 1,
            'color' => 'green',
            'code' =>
            'city=revenue:30,slots:2;path=a:1,b:_0;path=a:3,b:_0;path=a:5,b:_0;label=FL',
          },
          '487' =>
          {
            'count' => 1,
            'color' => 'green',
            'code' =>
            'city=revenue:40,slots:1;city=revenue:40,slots:1;'\
            'path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_1;path=a:4,b:_1;label=Jax',
          },
          '63' =>
          {
            'count' => 1,
            'color' => 'brown',
            'code' =>
            'city=revenue:40,slots:2;label=O;'\
            'path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;path=a:0,b:_0',
          },
          '146' => 8,
          '431' =>
          {
            'count' => 2,
            'color' => 'brown',
            'code' =>
            'city=revenue:60,slots:2;path=a:1,b:_0;path=a:5,b:_0;path=a:6,b:_0;label=T',
          },
          '488' =>
          {
            'count' => 1,
            'color' => 'brown',
            'code' =>
            'city=revenue:50,slots:1;city=revenue:50,slots:1;label=Jax;'\
            'path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_1;path=a:4,b:_1',
          },
          '544' => 2,
          '545' => 2,
          '546' => 2,
          '611' =>
          {
            'count' => 1,
            'color' => 'brown',
            'code' =>
            'city=revenue:40,slots:2;label=FL;'\
            'path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0',
          },
          '489' =>
          {
            'count' => 1,
            'color' => 'gray',
            'code' =>
            'city=revenue:70,slots:3;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;label=Jax',
          },
        }.freeze

        LOCATION_NAMES = {
          'A22' => 'Savannah',
          'B1' => 'New Orleans',
          'B5' => 'Mobile',
          'B7' => 'Pensacola',
          'B13' => 'Chattahoochee',
          'B15' => 'Tallahassee',
          'B19' => 'Lake City',
          'B23' => 'Jacksonville',
          'C14' => 'St. Marks',
          'C24' => 'St. Augustine',
          'D19' => 'Cedar Key',
          'D23' => 'Palatka',
          'D25' => 'Daytona',
          'E26' => 'Titusville',
          'F23' => 'Orlando',
          'G20' => 'Tampa',
          'I22' => 'Punta Gorda',
          'I28' => 'West Palm Beach',
          'J27' => 'Fort Lauderdale',
          'K28' => 'Miami',
          'M24' => 'Key West',
          'N23' => 'Havana',
        }.freeze

        MARKET = [
          %w[60
             65
             70p
             75p
             80p
             90p
             100p
             110p
             125
             140
             160
             180
             200m
             225
             250
             275
             300
             330
             360
             400],
           ].freeze

        PHASES = [
          {
            name: '2',
            train_limit: { five_share: 2 },
            tiles: [:yellow],
            corporation_sizes: [5],
            operating_rounds: 1,
          },
          {
            name: '3',
            on: '3',
            train_limit: { five_share: 2, ten_share: 4 },
            tiles: %i[yellow green],
            corporation_sizes: [5],
            operating_rounds: 2,
            status: ['may_convert'],
          },
          {
            name: '4',
            on: '4',
            train_limit: { five_share: 1, ten_share: 3 },
            tiles: %i[yellow green],
            corporation_sizes: [5, 10],
            operating_rounds: 2,
            status: ['may_convert'],
          },
          {
            name: '5',
            on: '5',
            train_limit: { ten_share: 2 },
            tiles: %i[yellow green brown],
            corporation_sizes: [10],
            operating_rounds: 3,
            status: ['hotels_doubled'],
          },
          {
            name: '6',
            on: %w[6 3E],
            train_limit: { ten_share: 2 },
            tiles: %i[yellow green brown gray],
            corporation_sizes: [10],
            operating_rounds: 3,
            status: ['hotels_doubled'],
          },
        ].freeze

        TRAINS = [
          {
            name: '2',
            distance: [{ 'nodes' => %w[city offboard], 'pay' => 2, 'visit' => 2 },
                       { 'nodes' => ['town'], 'pay' => 99, 'visit' => 99 }],
            price: 100,
            rusts_on: '4',
            num: 5,
          },
          {
            name: '3',
            distance: [{ 'nodes' => %w[city offboard], 'pay' => 3, 'visit' => 3 },
                       { 'nodes' => ['town'], 'pay' => 99, 'visit' => 99 }],
            price: 200,
            rusts_on: '6',
            num: 4,
          },
          {
            name: '4',
            distance: [{ 'nodes' => %w[city offboard], 'pay' => 4, 'visit' => 4 },
                       { 'nodes' => ['town'], 'pay' => 99, 'visit' => 99 }],
            price: 400,
            rusts_on: 'D',
            num: 3,
          },
          {
            name: '5',
            distance: [{ 'nodes' => %w[city offboard], 'pay' => 5, 'visit' => 5 },
                       { 'nodes' => ['town'], 'pay' => 99, 'visit' => 99 }],
            price: 500,
            num: 2,
            events: [{ 'type' => 'close_companies' },
                     { 'type' => 'close_port' },
                     { 'type' => 'forced_conversions' }],
          },
          {
            name: '6',
            distance: [{ 'nodes' => %w[city offboard], 'pay' => 6, 'visit' => 6 },
                       { 'nodes' => ['town'], 'pay' => 99, 'visit' => 99 }],
            price: 600,
            variants: [
              {
                name: '3E',
                distance: [{ 'nodes' => %w[city offboard], 'pay' => 3, 'visit' => 3, 'multiplier' => 2 },
                           {
                             'nodes' => ['town'],
                             'pay' => 99,
                             'visit' => 99,
                             'multiplier' => 0,
                           }],
                price: 600,
              },
            ],
            num: 7,
            events: [{ 'type' => 'hurricane' }],
          },
        ].freeze

        COMPANIES = [
          {
            name: 'Tallahassee Railroad',
            value: 0,
            discount: -20,
            revenue: 5,
            desc: 'The winner of this private gets Priority Deal in the first Stock Round. '\
                  'This may be closed to grant a corporation an additional yellow tile lay. '\
                  'Terrain costs must be paid for normally',
            sym: 'TR',
            abilities: [
            {
              type: 'tile_lay',
              owner_type: 'player',
              count: 1,
              free: false,
              special: false,
              reachable: true,
              hexes: [],
              tiles: %w[3 4 6o 6fl 8 9 58],
              closed_when_used_up: true,
              when: %w[track owning_player_track],
            },
          ],
            color: nil,
          },
          {
            name: 'Peninsular and Occidental Steamship Company',
            value: 0,
            discount: -30,
            revenue: 10,
            desc: 'Closing this private grants the operating Corporation a port token to place on a port city. '\
                  'The port token increases the value of that city by $20 for that corporation only',
            sym: 'POSC',
            abilities: [
              {
                type: 'assign_hexes',
                when: 'any',
                hexes: %w[B5 B23 G20 K28],
                count: 1,
                owner_type: 'player',
              },
              {
                type: 'assign_corporation',
                when: 'any',
                count: 1,
                owner_type: 'player',
              },
            ],
            color: nil,
          },
          {
            name: 'Terminal Company',
            value: 0,
            discount: -70,
            revenue: 15,
            desc: 'Allows a Corporation to place an extra token on a city tile of yellow or higher. '\
                  'This is an additional token and free. This token does not use a token slot in the city. '\
                  'This token can be disconnected',
            sym: 'TC',
            min_players: 3,
            abilities: [
              {
                when: 'any',
                extra_action: true,
                type: 'token',
                owner_type: 'player',
                count: 1,
                from_owner: true,
                extra_slot: true,
                special_only: true,
                price: 0,
                teleport_price: 0,
                hexes: %w[B5 B15 B23 G20 F23 J27 K28],
              },
            ],
            color: nil,
          },
          {
            name: 'Florida East Coast Canal and Transportation Company',
            value: 0,
            discount: -110,
            revenue: 20,
            desc: 'This Company comes with a single share of the Florida East Coast Railway. '\
                  'This company closes when the FECR buys its first train',
            sym: 'FECCTC',
            min_players: 4,
            abilities: [{ type: 'close', when: 'bought_train', corporation: 'FECR' },
                        { type: 'shares', shares: 'FECR_1' }],
            color: nil,
          },
        ].freeze

        CORPORATIONS = [
          {
            float_percent: 50,
            sym: 'LN',
            name: 'Louisville and Nashville Railroad',
            logo: '18_fl/LN',
            simple_logo: '18_fl/LN.alt',
            shares: [40, 20, 20, 20],
            tokens: [0, 20, 20, 20],
            coordinates: 'B5',
            color: :darkblue,
            type: 'five_share',
            always_market_price: true,
            reservation_color: nil,
          },
          {
            float_percent: 50,
            sym: 'Plant',
            name: 'The Plant System',
            logo: '18_fl/Plant',
            simple_logo: '18_fl/Plant.alt',
            shares: [40, 20, 20, 20],
            tokens: [0, 20, 20, 20],
            coordinates: 'B15',
            color: :deepskyblue,
            text_color: 'black',
            type: 'five_share',
            always_market_price: true,
            reservation_color: nil,
          },
          {
            float_percent: 50,
            sym: 'SR',
            name: 'Southern Railway',
            logo: '18_fl/SR',
            simple_logo: '18_fl/SR.alt',
            shares: [40, 20, 20, 20],
            tokens: [0, 20, 20, 20],
            coordinates: 'B23',
            city: 1,
            color: '#76a042',
            type: 'five_share',
            always_market_price: true,
            reservation_color: nil,
          },
          {
            float_percent: 50,
            sym: 'SAL',
            name: 'Seaboard Air Line',
            logo: '18_fl/SAL',
            simple_logo: '18_fl/SAL.alt',
            shares: [40, 20, 20, 20],
            tokens: [0, 20, 20, 20],
            coordinates: 'B23',
            city: 0,
            color: '#f48221',
            type: 'five_share',
            always_market_price: true,
            reservation_color: nil,
          },
          {
            float_percent: 50,
            sym: 'ACL',
            name: 'Atlantic Coast Line',
            logo: '18_fl/ACL',
            simple_logo: '18_fl/ACL.alt',
            shares: [40, 20, 20, 20],
            tokens: [0, 20, 20, 20],
            coordinates: 'G20',
            color: :purple,
            type: 'five_share',
            always_market_price: true,
            reservation_color: nil,
          },
          {
            float_percent: 50,
            sym: 'FECR',
            name: 'Florida East Coast Railway',
            logo: '18_fl/FECR',
            simple_logo: '18_fl/FECR.alt',
            shares: [40, 20, 20, 20],
            tokens: [0, 20, 20, 20],
            coordinates: 'K28',
            color: '#d81e3e',
            type: 'five_share',
            always_market_price: true,
            reservation_color: nil,
          },
        ].freeze

        HEXES = {
          white: {
            %w[B3
               B9
               B11
               B17
               B21
               C12
               C16
               C18
               C20
               C22
               D21
               E20
               E22
               E24
               F21
               F25
               G22
               G26
               H21] => '',
            %w[G24 H23 I24 J23 J25 K24] => 'upgrade=cost:40,terrain:swamp',
            ['H25'] =>
                   'upgrade=cost:40,terrain:swamp;border=edge:5,type:impassable;border=edge:4,type:impassable',
            ['I26'] =>
                   'upgrade=cost:40,terrain:swamp;border=edge:2,type:impassable;border=edge:3,type:impassable',
            ['H27'] => 'border=edge:0,type:impassable;border=edge:1,type:impassable',
            ['K26'] => 'upgrade=cost:40,terrain:swamp;border=edge:5,type:impassable',
            ['L27'] => 'upgrade=cost:40,terrain:swamp;border=edge:2,type:impassable',
            ['J27'] => 'city=revenue:0;label=FL',
            ['F23'] => 'city=revenue:0;label=O',
            %w[B7
               B13
               B19
               C14
               C24
               D19
               D23
               D25
               E26
               I22
               I28] => 'town=revenue:0',
            ['M26'] => 'upgrade=cost:80,terrain:water',
            ['M24'] => 'town=revenue:0;upgrade=cost:80,terrain:water',
          },
          yellow: {
            ['B5'] =>
                     'city=revenue:20;path=a:1,b:_0;path=a:4,b:_0;label=K;icon=image:port,sticky:1',
            ['B15'] =>
            'city=revenue:20;path=a:1,b:_0;path=a:4,b:_0;path=a:6,b:_0;label=K',
            ['B23'] =>
            'city=revenue:30;city=revenue:30;'\
            'path=a:5,b:_0;path=a:6,b:_0;path=a:1,b:_1;path=a:2,b:_1;label=Jax;icon=image:port,sticky:1',
            ['G20'] =>
            'city=revenue:30;path=a:5,b:_0;path=a:3,b:_0;label=T;icon=image:port,sticky:1',
            ['K28'] =>
            'city=revenue:30;path=a:6,b:_0;path=a:2,b:_0;label=T;icon=image:port,sticky:1',
          },
          red: {
            ['A22'] => 'offboard=revenue:yellow_30|brown_80;path=a:5,b:_0',
            ['B1'] => 'offboard=revenue:yellow_40|brown_70;path=a:4,b:_0',
            ['N23'] => 'offboard=revenue:yellow_60|brown_100;path=a:3,b:_0',
          },
          gray: {
            %w[A2 A8 A10 A12 A14 A16 A18 A20] => '',
            ['A4'] => 'offboard=revenue:yellow_0,visit_cost:99;path=a:5,b:_0',
            ['A6'] => 'offboard=revenue:yellow_0,visit_cost:99;path=a:6,b:_0',
          },
        }.freeze

        LAYOUT = :pointy

        HOME_TOKEN_TIMING = :operating_round
        SELL_BUY_ORDER = :sell_buy
        SELL_MOVEMENT = :left_block
        SELL_AFTER = :operate
        EBUY_OTHER_VALUE = true
        EBUY_DEPOT_TRAIN_MUST_BE_CHEAPEST = false
        TILE_LAYS = [{ lay: true, upgrade: true }, { lay: :not_if_upgraded, upgrade: false }].freeze
        STEAMBOAT_HEXES = %w[B5 B23 G20 K28].freeze
        EVENTS_TEXT = Base::EVENTS_TEXT.merge(
          'hurricane' => ['Florida Keys Hurricane', 'Track and hotels in the Florida Keys (M24, M26) is removed'],
          'close_port' => ['Port Token Removed'],
          'forced_conversions' => ['Forced Conversions',
                                   'All remaining 5 share corporations immediately convert to 10 share corporations']
        ).freeze
        MARKET_TEXT = Base::MARKET_TEXT.merge(max_price: 'Maximum price for a 5-share corporation').freeze

        STATUS_TEXT = Base::STATUS_TEXT.merge(
          'hotels_doubled' => ['Hotel Bonus Doubled', 'Hotel bonus increases from $10 to $20'],
          'may_convert' => ['Corporations May Convert',
                            'At the start of a corporations Operating turn it
                           may choose to convert to a 10 share corporation'],
        ).freeze

        SOLD_OUT_INCREASE = false
        ASSIGNMENT_TOKENS = {
          'POSC' => '/icons/1846/sc_token.svg',
        }.freeze
        def stock_round
          Engine::Round::Stock.new(self, [
            Engine::Step::DiscardTrain,
            G18FL::Step::BuySellParShares,
          ])
        end

        def new_auction_round
          Engine::Round::Auction.new(self, [
            G18FL::Step::BuyCert,
          ])
        end

        def operating_round(round_num)
          G18FL::Round::Operating.new(self, [
            Engine::Step::Bankrupt,
            G18FL::Step::Assign,
            Engine::Step::Exchange,
            G18FL::Step::Convert,
            Engine::Step::SpecialTrack,
            Engine::Step::BuyCompany,
            G18FL::Step::Track,
            G18FL::Step::SpecialToken,
            G18FL::Step::Token,
            Engine::Step::Route,
            G18FL::Step::Dividend,
            Engine::Step::DiscardTrain,
            G18FL::Step::BuyTrain,
            [Engine::Step::BuyCompany, { blocks: true }],
          ], round_num: round_num)
        end

        def init_stock_market
          G18FL::StockMarket.new(game_market, self.class::CERT_LIMIT_TYPES,
                                 multiple_buy_types: self.class::MULTIPLE_BUY_TYPES)
        end

        def steamboat
          @steamboat ||= company_by_id('POSC')
        end

        def tile_company
          @tile_company ||= company_by_id('TR')
        end

        def token_company
          @token_company ||= company_by_id('POSC')
        end

        def revenue_for(route, stops)
          revenue = super

          raise GameError, 'Route visits same hex twice' if route.hexes.size != route.hexes.uniq.size

          raise GameError, '3E must visit at least two paying revenue centers' if route.train.variant['name'] == '3E' &&
             stops.count { |h| !h.town? } <= 1

          steam = steamboat.id
          if route.corporation.assigned?(steam) && (port = stops.map(&:hex).find { |hex| hex.assigned?(steam) })
            revenue += 20 * port.tile.icons.count { |icon| icon.name == 'port' }
          end
          hotels = stops.count { |h| h.tile.icons.any? { |i| i.name == route.corporation.id } }

          # 3E doesn't count hotels.
          route.train.variant['name'] == '3E' ? revenue : revenue + (hotels * hotel_value)
        end

        def init_hexes(_companies, corporations)
          hexes = super
          place_home_tokens(corporations, hexes)
          hexes
        end

        def place_home_tokens(corporations, hexes)
          corporations.each do |corporation|
            tile = hexes.find { |hex| hex.coordinates == corporation.coordinates }.tile
            tile.cities[corporation.city || 0].place_token(corporation, corporation.tokens.first, free: true)
          end
        end

        def hotel_value
          @phase.status.include?('hotels_doubled') ? 20 : 10
        end

        # Event logic goes here
        def event_close_port!
          @log << 'Port closes'
          removals = Hash.new { |h, k| h[k] = {} }

          @corporations.each do |corp|
            corp.assignments.dup.each do |company, _|
              removals[company][:corporation] = corp.name
              corp.remove_assignment!(company)
            end
          end

          @hexes.each do |hex|
            hex.assignments.dup.each do |company, _|
              removals[company][:hex] = hex.name
              hex.remove_assignment!(company)
            end
          end

          self.class::STEAMBOAT_HEXES.each do |hex|
            hex_by_id(hex).tile.icons.reject! { |icon| icon.name == 'port' }
          end

          removals.each do |company, removal|
            hex = removal[:hex]
            corp = removal[:corporation]
            @log << "-- Event: #{corp}'s #{company_by_id(company).name} token removed from #{hex} --"
          end
        end

        def corporation_opts
          two_player? && @optional_rules&.include?(:two_player_share_limit) ? { max_ownership_percent: 70 } : {}
        end

        def event_hurricane!
          @log << '-- Event: Florida Keys Hurricane --'
          key_west = @hexes.find { |h| h.id == 'M24' }
          key_island = @hexes.find { |h| h.id == 'M26' }

          @log << 'A hurricane destroys track in the Florida Keys (M24, M26)'
          key_island.lay_downgrade(key_island.original_tile)

          @log << 'The hurricane also destroys the hotels in Key West'
          key_west.tile.icons.clear
          key_west.lay_downgrade(key_west.original_tile)
        end

        # 5 => 10 share conversion logic
        def event_forced_conversions!
          @log << '-- Event: All 5 share corporations must convert to 10 share corporations immediately --'
          @corporations.select { |c| c.type == :five_share }.each { |c| convert(c, funding: c.share_price) }
        end

        def process_convert(action)
          @game.convert(action.entity)
        end

        def convert(corporation, funding: true)
          before = corporation.total_shares
          shares = @_shares.values.select { |share| share.corporation == corporation }

          corporation.share_holders.clear

          case corporation.type
          when :five_share
            shares.each { |share| share.percent = 10 }
            shares[0].percent = 20
            new_shares = Array.new(5) { |i| Share.new(corporation, percent: 10, index: i + 4) }
            corporation.type = :ten_share
          else
            raise GameError, 'Cannot convert 10 share corporation'
          end

          shares.each { |share| corporation.share_holders[share.owner] += share.percent }

          new_shares.each do |share|
            add_new_share(share)
          end

          after = corporation.total_shares
          @log << "#{corporation.name} converts from #{before} to #{after} shares"
          if funding
            conversion_funding = 5 * corporation.share_price.price
            @log << "#{corporation.name} gets #{format_currency(conversion_funding)} from the conversion"
            @bank.spend(conversion_funding, corporation)
          end

          new_shares
        end

        def add_new_share(share)
          owner = share.owner
          corporation = share.corporation
          corporation.share_holders[owner] += share.percent if owner
          owner.shares_by_corporation[corporation] << share
          @_shares[share.id] = share
        end
      end
    end
  end
end
