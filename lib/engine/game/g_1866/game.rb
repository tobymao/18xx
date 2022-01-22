# frozen_string_literal: true

require_relative 'meta'
require_relative 'entities'
require_relative 'map'
require_relative '../base'

module Engine
  module Game
    module G1866
      class Game < Game::Base
        include_meta(G1866::Meta)
        include G1866::Entities
        include G1866::Map

        GAME_END_CHECK = { bank: :full_or, stock_market: :current_or }.freeze

        BANKRUPTCY_ALLOWED = false
        CURRENCY_FORMAT_STR = '£%d'
        BANK_CASH = 99_999

        CERT_LIMIT = { 3 => 40, 4 => 30, 5 => 24, 6 => 20, 7 => 17 }.freeze
        STARTING_CASH = { 3 => 800, 4 => 600, 5 => 480, 6 => 400, 7 => 340 }.freeze

        CAPITALIZATION = :incremental

        EBUY_OTHER_VALUE = false

        TILE_TYPE = :lawson
        LAYOUT = :pointy

        HOME_TOKEN_TIMING = :operate
        MUST_BID_INCREMENT_MULTIPLE = true
        MUST_BUY_TRAIN = :always
        NEXT_SR_PLAYER_ORDER = :least_cash

        MUST_SELL_IN_BLOCKS = false
        SELL_AFTER = :first
        SELL_BUY_ORDER = :sell_buy
        SELL_MOVEMENT = :down_share
        SOLD_OUT_INCREASE = false

        MARKET = [
          %w[0 5 10 15 20 25 30p 35p 40p 45p 50p 55p 60x 65x 70x 75x 80x 90x 100z 110z 120z 135z 150w 165w 180
             200 220 240 260 280 300 330 360 390 420 460 500 540 580 630 680],
          %w[0 5 10 15 20 25 30p 35p 40p 45p 50p 55p 60p 65p 70p 75p 80x 90x 100x 110x 120z 135z 150z 165w 180w
             200 220 240 260 280 300 330 360 390 420 460 500 540 580 630 680],
          %w[0 5 10 15 20 25 30 35 40 45 50 55 60p 65p 70p 75p 80p 90p 100p 110x 120x 135x 150z 165z 180w
             200pxzw 220 240 260 280 300 330 360 390 420 460 500 540 580 630 680],
          %w[120P 100P 75P 75P 75P 120P 80P 80P 80P 50P],
        ].freeze

        EVENTS_TEXT = {
          'green_ferries' => ['Green ferries', 'The green ferry lines opens up'],
          'brown_ferries' => ['Brown ferries', 'The brown ferry lines opens up'],
          'formation' => ['Formation', 'Forced formation of Major Nationals. Order of forming is: '\
                                       'Switzerland, Spain, Benelux, Austro-Hungarian Empire, Italy, France, '\
                                       'Germany, Great Britain.'],
        }.freeze

        MARKET_TEXT = Base::MARKET_TEXT.merge(par_overlap: 'Minor nationals',
                                              par: 'Yellow phase (L/2) par',
                                              par_1: 'Green phase (3/4) par',
                                              par_2: 'Brown phase (5/6) par',
                                              par_3: 'Gray phase (8/10) par').freeze

        STATUS_TEXT = Base::STATUS_TEXT.merge(
          'can_convert_corporation' => ['Convert Corporation', 'Corporations can convert from 5 shares to 10 shares.'],
          'can_convert_major' => ['Convert Major National', 'President of G1 and I1 can form Germany or Italy Major '\
                                                            'National.'],
        ).freeze

        STOCKMARKET_COLORS = Base::STOCKMARKET_COLORS.merge(par_overlap: :white,
                                                            par: :yellow,
                                                            par_1: :green,
                                                            par_2: :brown,
                                                            par_3: :gray).freeze

        PHASES = [
          {
            name: 'L/2',
            on: '',
            train_limit: { minor_national: 1, national: 1, share_5: 3 },
            tiles: [:yellow],
            operating_rounds: 99,
          },
          {
            name: '3',
            on: '3',
            train_limit: { minor_national: 1, national: 1, share_5: 3, share_10: 4 },
            tiles: %i[yellow green],
            operating_rounds: 99,
            status: %w[can_convert_corporation can_convert_major],
          },
          {
            name: '4',
            on: '4',
            train_limit: { minor_national: 1, national: 1, share_5: 3, share_10: 4 },
            tiles: %i[yellow green],
            operating_rounds: 99,
            status: %w[can_convert_corporation can_convert_major],
          },
          {
            name: '5',
            on: '5',
            train_limit: { minor_national: 1, national: 1, share_5: 2, share_10: 3 },
            tiles: %i[yellow green brown],
            operating_rounds: 99,
            status: %w[can_convert_corporation],
          },
          {
            name: '6',
            on: '6',
            train_limit: { minor_national: 1, national: 1, share_5: 2, share_10: 3 },
            tiles: %i[yellow green brown],
            operating_rounds: 99,
            status: %w[can_convert_corporation],
          },
          {
            name: '8',
            on: '8',
            train_limit: { minor_national: 1, national: 1, share_5: 1, share_10: 2 },
            tiles: %i[yellow green brown gray],
            operating_rounds: 99,
            status: %w[can_convert_corporation],
          },
          {
            name: '10',
            on: '10',
            train_limit: { minor_national: 1, national: 1, share_5: 1, share_10: 2 },
            tiles: %i[yellow green brown gray],
            operating_rounds: 99,
            status: %w[can_convert_corporation],
          },
        ].freeze

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
            obsolete_on: '3',
            variants: [
              {
                name: '2',
                distance: [
                  {
                    'nodes' => %w[city offboard],
                    'pay' => 2,
                    'visit' => 2,
                  },
                  {
                    'nodes' => ['town'],
                    'pay' => 99,
                    'visit' => 99,
                  },
                ],
                price: 100,
                obsolete_on: '4',
              },
            ],
          },
          {
            name: '3',
            distance: [
              {
                'nodes' => %w[city offboard],
                'pay' => 3,
                'visit' => 3,
              },
              {
                'nodes' => ['town'],
                'pay' => 99,
                'visit' => 99,
              },
            ],
            num: 4,
            price: 200,
            obsolete_on: '6',
            events: [
              {
                'type' => 'green_ferries',
              },
            ],
          },
          {
            name: '4',
            distance: [
              {
                'nodes' => %w[city offboard],
                'pay' => 4,
                'visit' => 4,
              },
              {
                'nodes' => ['town'],
                'pay' => 99,
                'visit' => 99,
              },
            ],
            num: 4,
            price: 300,
            obsolete_on: '8',
          },
          {
            name: '5',
            distance: [
              {
                'nodes' => %w[city offboard],
                'pay' => 5,
                'visit' => 5,
              },
              {
                'nodes' => ['town'],
                'pay' => 99,
                'visit' => 99,
              },
            ],
            num: 4,
            price: 450,
            obsolete_on: '10',
            events: [
              {
                'type' => 'brown_ferries',
              },
              {
                'type' => 'formation',
              },
            ],
            variants: [
              {
                name: '3E',
                distance: [
                  {
                    'nodes' => ['city'],
                    'pay' => 3,
                    'visit' => 3,
                  },
                  {
                    'nodes' => ['town'],
                    'pay' => 0,
                    'visit' => 99,
                  },
                ],
                multiplier: 2,
                price: 450,
                obsolete_on: '10',
              },
            ],
          },
          {
            name: '6',
            distance: [
              {
                'nodes' => %w[city offboard],
                'pay' => 6,
                'visit' => 6,
              },
              {
                'nodes' => ['town'],
                'pay' => 99,
                'visit' => 99,
              },
            ],
            num: 4,
            price: 600,
            variants: [
              {
                name: '4E',
                distance: [
                  {
                    'nodes' => ['city'],
                    'pay' => 4,
                    'visit' => 4,
                  },
                  {
                    'nodes' => ['town'],
                    'pay' => 0,
                    'visit' => 99,
                  },
                ],
                multiplier: 2,
                price: 600,
              },
            ],
          },
          {
            name: '8',
            distance: [
              {
                'nodes' => %w[city offboard],
                'pay' => 8,
                'visit' => 8,
              },
              {
                'nodes' => ['town'],
                'pay' => 99,
                'visit' => 99,
              },
            ],
            num: 4,
            price: 800,
            variants: [
              {
                name: '5E',
                distance: [
                  {
                    'nodes' => ['city'],
                    'pay' => 5,
                    'visit' => 5,
                  },
                  {
                    'nodes' => ['town'],
                    'pay' => 0,
                    'visit' => 99,
                  },
                ],
                multiplier: 2,
                price: 800,
              },
            ],
          },
          {
            name: '10',
            distance: [
              {
                'nodes' => %w[city offboard],
                'pay' => 10,
                'visit' => 10,
              },
              {
                'nodes' => ['town'],
                'pay' => 99,
                'visit' => 99,
              },
            ],
            num: 20,
            price: 1000,
            variants: [
              {
                name: '6E',
                distance: [
                  {
                    'nodes' => ['city'],
                    'pay' => 6,
                    'visit' => 6,
                  },
                  {
                    'nodes' => ['town'],
                    'pay' => 0,
                    'visit' => 99,
                  },
                ],
                multiplier: 2,
                price: 1000,
              },
            ],
          },
          {
            name: 'INF',
            distance: 99,
            num: 18,
            price: 0,
            reserved: true,
          },
        ].freeze

        # *********** 1866 Specific constants ***********
        CORPORATIONS_OPERATING_RIGHTS = {
          'LNWR' => 'GBN',
          'GWR' => 'GBN',
          'NBR' => 'GBN',
          'PLM' => 'FN',
          'MIDI' => 'FN',
          'OU' => 'FN',
          'KPS' => %w[GN G1],
          'BY' => %w[GN G3],
          'KHS' => %w[GN G2],
          'SB' => 'AHN',
          'BH' => 'AHN',
          'FNR' => 'AHN',
          'SSFL' => %w[IN I5],
          'IFT' => %w[IN I1],
          'SFAI' => %w[IN I3],
          'SBB' => 'SWN',
          'GL' => 'BN',
          'NRS' => 'BN',
          'ZPB' => 'SPN',
          'MZA' => 'SPN',
        }.freeze

        DOUBLE_HEX = %w[G15 G19 J12 J18 K5].freeze

        ENTITY_STATUS_TEXT = {
          'LNWR' => 'Available from ISR',
          'GWR' => 'Available from ISR',
          'NBR' => 'Available from ISR',
          'PLM' => 'Available from ISR',
          'MIDI' => 'Available from ISR',
          'OU' => 'Available from ISR',
          'KPS' => 'Available from OR1',
          'BY' => 'Available from OR1',
          'KHS' => 'Available from OR1',
          'SB' => 'Available from OR2',
          'BH' => 'Available from OR2',
          'FNR' => 'Available from OR2',
          'SSFL' => 'Available from OR2',
          'IFT' => 'Available from OR2',
          'SFAI' => 'Available from OR2',
          'SBB' => 'Available from OR2',
          'GL' => 'Available from OR1',
          'NRS' => 'Available from OR1',
          'ZPB' => 'Available from OR2',
          'MZA' => 'Available from OR2',
          'G1' => 'Available from ISR',
          'G2' => 'Available from ISR',
          'G3' => 'Available from ISR',
          'G4' => 'Available from ISR',
          'G5' => 'Available from ISR',
          'I1' => 'Available from ISR',
          'I2' => 'Available from ISR',
          'I3' => 'Available from ISR',
          'I4' => 'Available from ISR',
          'I5' => 'Available from ISR',
          'AHN' => 'Available from OR1',
          'BN' => 'Available from OR1',
          'FN' => 'Available from OR1',
          'GBN' => 'Available from OR1',
          'SPN' => 'Available from OR1',
          'SWN' => 'Available from OR1',
          'GN' => 'Converted by G1 president or force convert in phase 5',
          'IN' => 'Converted by I1 president or force convert in phase 5',
        }.freeze

        FERRY_TILE_G7 = 'border=edge:2,type:impassable;border=edge:4,type:impassable;path=a:1,b:5'
        FERRY_TILE_S25 = 'border=edge:0,type:impassable;path=a:1,b:2'
        FERRY_TILE_F8 = 'border=edge:1,type:impassable;border=edge:5,type:impassable;path=a:2,b:4'
        FERRY_TILE_H4 = 'border=edge:3,type:impassable;border=edge:5,type:impassable;path=a:0,b:2'

        GERMANY_NATIONAL = 'GN'
        ITALY_NATIONAL = 'IN'

        INCOME_BOND = 'P8'
        INCOME_BOND_REVENUE = {
          'L/2' => 10,
          '3' => 20,
          '4' => 20,
          '5' => 30,
          '6' => 30,
          '8' => 40,
          '10' => 40,
        }.freeze

        LOCAL_TRAIN = 'L'

        LONDON_HEX = 'F6'
        LONDON_TILE = 'L1'
        PARIS_HEX = 'J6'
        PARIS_TILE = 'P1'

        MAX_PAR_VALUE = 200

        MINOR_NATIONAL_PAR_ROWS = {
          'G1' => [3, 0],
          'G2' => [3, 1],
          'G3' => [3, 2],
          'G4' => [3, 3],
          'G5' => [3, 4],
          'I1' => [3, 5],
          'I2' => [3, 6],
          'I3' => [3, 7],
          'I4' => [3, 8],
          'I5' => [3, 9],
        }.freeze

        NATIONAL_CORPORATIONS = %w[GBN FN AHN BN SPN SWN GN G1 G2 G3 G4 G5 IN I1 I2 I3 I4 I5].freeze
        NATIONAL_REGION_HEXES = {
          'G1' => %w[E23 E25 F20 F22 F24 F26 G15 G17 G19 G21 G23 G25 H14 H16 H18 H24 H26 I25],
          'G2' => %w[D18 E15 E17 E19 E21 F16 F18],
          'G3' => %w[I17 I19 J16 J18 J20 K17 K19 K21],
          'G4' => %w[I13 I15 J14 K15],
          'G5' => %w[H20 H22 I21 I23],
          'I1' => %w[S21 S23 T20 T22 T24 U21 V18 V20 W19],
          'I2' => %w[N12 O13 O15 S13 T12],
          'I3' => %w[M17 N14 N16 N18 N20 O17 P18],
          'I4' => %w[Q19 R18 R20 S19],
          'I5' => %w[P16 Q17],
          'AHN' => %w[J22 J24 J26 K23 K25 L18 L20 L22 L24 L26 M19 M21 M23 M25 N22 N24 N26 O21 O23 O25
                      P22 P24 P26 Q23 Q25 R24],
          'BN' => %w[E13 F10 F12 F14 G9 G11 G13 H10 H12 I11],
          'FN' => %w[H8 I1 I3 I5 I7 I9 J0 J2 J4 J6 J8 J10 J12 K1 K3 K5 K7 K9 K11 K13 L2 L4 L6 L8 L10
                     M3 M5 M7 M9 M11 N2 N4 N6 N8 N10 O3 O5 O7 O9 O11 P6 P8 P10 P12 Q13],
          'GBN' => %w[A3 B2 B4 C3 C5 D2 D4 D6 E1 E3 E5 E7 F2 F4 F6 G1 G3 G5],
          'SPN' => %w[O1 P2 P4 Q1 Q3 Q5 R2 R4 S1 S3 T2 U1],
          'SWN' => %w[L12 L14 L16 M13 M15],
          'GN' => %w[E23 E25 F20 F22 F24 F26 G15 G17 G19 G21 G23 G25 H14 H16 H18 H24 H26 I25 D18 E15 E17
                     E19 E21 F16 F18 I17 I19 J16 J18 J20 K17 K19 K21 I13 I15 J14 K15 H20 H22 I21 I23],
          'IN' => %w[S21 S23 T20 T22 T24 U21 V18 V20 W19 N12 O13 O15 S13 T12 M17 N14 N16 N18 N20 O17 P18
                     Q19 R18 R20 S19 P16 Q17],
        }.freeze

        # Only need up to phase 5, all national concessions are forced to convert in phase 5
        NATIONAL_PHASE_PAR_TYPES = {
          'L/2' => :par_1,
          '3' => :par_2,
          '4' => :par_2,
          '5' => :par_3,
        }.freeze

        NATIONAL_TILE_LAYS = [{ lay: true, upgrade: true, cost: 0 }].freeze
        TILE_LAYS = [
          { lay: true, upgrade: true, cost: 0 },
          { lay: true, upgrade: true, cost: 10 },
          { lay: true, upgrade: true, cost: 20 },
          { lay: true, upgrade: true, cost: 30 },
        ].freeze

        TILE_LAYS_UPGRADE = {
          'L/2' => 0,
          '3' => 1,
          '4' => 1,
          '5' => 2,
          '6' => 2,
          '8' => 3,
          '10' => 4,
        }.freeze

        PHASE_PAR_TYPES = {
          'L/2' => :par,
          '3' => :par_1,
          '4' => :par_1,
          '5' => :par_2,
          '6' => :par_2,
          '8' => :par_3,
          '10' => :par_3,
        }.freeze

        PORT_TOKEN_BONUS = {
          'L/2' => 0,
          '3' => 20,
          '4' => 20,
          '5' => 30,
          '6' => 30,
          '8' => 40,
          '10' => 40,
        }.freeze

        REGION_CORPORATIONS = {
          'GREAT_BRITAIN' => %w[LNWR GWR NBR],
          'FRANCE' => %w[PLM MIDI OU],
          'GERMANY' => %w[KPS BY KHS],
          'AUSTRIA' => %w[SB BH FNR],
          'ITALY' => %w[SSFL IFT SFAI],
        }.freeze

        STOCK_TURN_TOKEN_PREFIX = 'ST'
        STOCK_TURN_TOKENS = {
          '3': 5,
          '4': 4,
          '5': 3,
          '6': 3,
          '7': 2,
        }.freeze

        # Corporations which will be able to float on which turn
        TURN_CORPORATIONS = {
          'ISR' => %w[G1 G2 G3 G4 G5 I1 I2 I3 I4 I5 LNWR GWR NBR PLM MIDI OU],
          'OR1' => %w[GBN FN AHN BN SPN SWN G1 G2 G3 G4 G5 I1 I2 I3 I4 I5 LNWR GWR NBR PLM MIDI OU KPS BY KHS
                      GL NRS],
        }.freeze

        def can_par?(corporation, parrer)
          return false if corporation.id == self.class::GERMANY_NATIONAL && corporation_by_id('G1').owner != parrer
          return false if corporation.id == self.class::ITALY_NATIONAL && corporation_by_id('I1').owner != parrer

          super
        end

        def can_run_route?(entity)
          national_corporation?(entity) || entity.trains.any? { |t| local_train?(t) } || super
        end

        def check_connected(route, token)
          return if national_corporation?(route.corporation)

          super
        end

        def check_distance(route, visits)
          entity = route.corporation
          if national_corporation?(entity) && !visits_within_national_region?(entity, visits)
            raise GameError, 'Nationals can only run within its region'
          end
          if corporation?(entity) && !visits_operating_rights?(entity, visits)
            raise GameError, 'The director need operating rights to operate in the selected regions'
          end

          super
        end

        def check_overlap(routes)
          # Tracks by e-train and normal trains
          tracks_by_type = Hash.new { |h, k| h[k] = [] }

          # Check local train not use the same token more then one time
          local_token_hex = []
          routes.each do |route|
            if route.train.local? && !route.chains.empty?
              local_token_hex.concat(route.visited_stops.select(&:city?).map { |n| n.hex.id })
            end

            route.paths.each do |path|
              a = path.a
              b = path.b

              tracks = tracks_by_type[train_type(route.train)]
              tracks << [path.hex, a.num, path.lanes[0][1]] if a.edge?
              tracks << [path.hex, b.num, path.lanes[1][1]] if b.edge?

              if b.edge? && a.town? && (nedge = a.tile.preferred_city_town_edges[a]) && nedge != b.num
                tracks << [path.hex, a, path.lanes[0][1]]
              end
              if a.edge? && b.town? && (nedge = b.tile.preferred_city_town_edges[b]) && nedge != a.num
                tracks << [path.hex, b, path.lanes[1][1]]
              end
            end
          end

          tracks_by_type.each do |_type, tracks|
            tracks.group_by(&:itself).each do |k, v|
              raise GameError, "Route can't reuse track on #{k[0].id}" if v.size > 1
            end
          end

          local_token_hex.group_by(&:itself).each do |k, v|
            raise GameError, "Local train can only use the token on #{k} once" if v.size > 1
          end
        end

        def city_tokened_by?(city, entity)
          return true if national_corporation?(entity) && entity.coordinates.include?(city.hex.name)

          super
        end

        def compute_other_paths(routes, route)
          routes.flat_map do |r|
            next if r == route || train_type(route.train) != train_type(r.train)

            r.paths
          end
        end

        def entity_can_use_company?(entity, company)
          entity == company.owner
        end

        def float_str(_entity)
          ''
        end

        def format_currency(val)
          return super if (val % 1).zero?

          format('£%.1<val>f', val: val)
        end

        def graph_for_entity(entity)
          national_corporation?(entity) ? @national_graph : @graph
        end

        def init_companies(_players)
          # Must do the randomize here, since the companies is duped in the setup of the auction
          super.sort_by { rand }
        end

        def init_company_abilities
          @companies.each do |company|
            next unless (ability = abilities(company, :exchange))
            next unless ability.from.include?(:par)

            exchange_corporations(ability).first.par_via_exchange = company
          end

          super
        end

        def ipo_name(_entity)
          'Treasury'
        end

        def local_length
          99
        end

        def next_round!
          @round =
            case @round
            when Engine::Round::Stock
              @operating_rounds = @phase.operating_rounds
              new_operating_round
            when G1866::Round::Operating
              or_round_finished
              new_operating_round(@round.round_num + 1)
            when init_round.class
              reorder_players_isr!
              stock_round_isr
            end
        end

        def new_auction_round
          Engine::Round::Auction.new(self, [
            G1866::Step::SelectionAuction,
          ])
        end

        def num_certs(entity)
          # All players have a Stock Turn Company, this shouldnt count towards the cert limit.
          super - 1
        end

        def operating_order
          floated = @corporations.select(&:floated?)
          minor_nationals, corporations = floated.partition { |c| minor_national_corporation?(c) }

          minor_nationals + (corporations + @stock_turn_token_in_play.values.flatten).sort
        end

        def operating_round(round_num)
          @current_turn = "OR#{round_num}"
          G1866::Round::Operating.new(self, [
            G1866::Step::StockTurnToken,
            G1866::Step::FirstTurnHousekeeping,
            G1866::Step::Convert,
            G1866::Step::Track,
            G1866::Step::Token,
            Engine::Step::Route,
            G1866::Step::Dividend,
            G1866::Step::DiscardTrain,
            G1866::Step::BuyTrain,
          ], round_num: round_num)
        end

        def or_round_finished
          # Export all L/2 trains at the end of OR2
          @depot.export_all!('L') if @round.round_num == 2 && local_train?(@depot.upcoming.first)
        end

        def par_price_str(share_price)
          row, = share_price.coordinates
          row_str = case row
                    when 0
                      'T'
                    when 1
                      'M'
                    when 2
                      'B'
                    else
                      ''
                    end
          "#{format_currency(share_price.price)}#{row_str}"
        end

        def payout_companies
          # Set the correct revenue for the Income Bond
          income_bond = @companies.find { |c| c.id == self.class::INCOME_BOND }
          income_bond.revenue = self.class::INCOME_BOND_REVENUE[@phase.name] if income_bond&.owner

          super
        end

        def place_home_token(corporation)
          return super unless corporation.id == 'PLM'
          return if corporation.tokens.first&.used

          corporation.coordinates.each do |coord|
            hex = hex_by_id(coord)
            tile = hex&.tile
            cities = tile.cities
            city = cities.find { |c| c.reserved_by?(corporation) } || cities[0]
            token = corporation.find_token_by_type

            @log << "#{corporation.name} places a token on #{hex.name}"
            city.place_token(corporation, token)
          end
        end

        def price_movement_chart
          [
            ['Market Action', 'Movement'],
            ['ST action pass', '3 →'],
            ['ST action sell (with no buy)', '2 →'],
            ['ST action buy', '1 →'],
            ['ST action sell and buy', 'none'],
            ['Dividend 0', '1 ←'],
            ['Dividend > 0', 'none'],
            ['Dividend ≥ stock value', '1 →'],
            ['Dividend ≥ 2× stock value', '2 →'],
            ['Dividend ≥ 3× stock value', '3 →'],
            ['Sale made by director', '1 ←'],
            ['Sale made by non-director, or for each loan taken', '1 ↓, or 1 ← if cannot go down'],
            ['For each loan repaid', '1 ↑, or 1 → and 1 ↓ if cannot go up'],
          ]
        end

        def reservation_corporations
          @corporations.reject { |c| national_corporation?(c) }
        end

        def revenue_for(route, stops)
          if route.hexes.size != route.hexes.uniq.size &&
            route.hexes.none? { |h| self.class::DOUBLE_HEX.include?(h.name) }
            raise GameError, 'Route visits same hex twice'
          end

          train = route.train
          entity = route.train.owner
          revenue = if train_type(train) == :normal
                      super
                    else
                      stops.sum do |stop|
                        next 0 unless stop.city?

                        tokened = stop.tokened_by?(entity)
                        if tokened
                          stop.route_revenue(route.phase, route.train)
                        else
                          0
                        end
                      end
                    end

          # If the train is obsolete, pay half revenue
          revenue /= 2 if train.obsolete

          # Port Token Bonus, check first and last stop to see if we got a token in a port
          port_bonus = port_token_bonus(route.routes)
          revenue += port_bonus[route] if port_bonus[route]

          revenue
        end

        def revenue_str(route)
          rev_str = super

          # Port Token Bonus, check first and last stop to see if we got a token in a port
          port_bonus = port_token_bonus(route.routes)
          rev_str += " (PTB #{format_currency(port_bonus[route])})" if port_bonus[route].positive?
          rev_str += ' (Obsolete)' if route.train.obsolete
          rev_str
        end

        def round_description(name, round_number = nil)
          round_number ||= @round.round_num
          "#{name} Round #{round_number}"
        end

        def setup
          @stock_turn_token_per_player = self.class::STOCK_TURN_TOKENS[@players.size.to_s]
          @stock_turn_token_in_play = {}
          @stock_turn_token_number = {}
          @player_setup_order = @players.dup
          @player_setup_order.each_with_index do |player, index|
            @log << "#{player.name} have stock turn tokens with number #{index + 1}"
            @stock_turn_token_in_play[player] = []
            @stock_turn_token_number[player] = 0
          end

          @red_reservation_entity = corporation_by_id('R')
          @corporations.delete(@red_reservation_entity)

          @current_turn = 'ISR'

          @major_national_formed = {}
          @major_national_formed[self.class::GERMANY_NATIONAL] = false
          @major_national_formed[self.class::ITALY_NATIONAL] = false

          # Setup the nationals graph
          @national_graph = Graph.new(self, home_as_token: true, no_blocking: true)

          # Setup the nationals infinite trains
          self.class::NATIONAL_CORPORATIONS.each_with_index do |national, index|
            train = train_by_id("INF-#{index}")
            @depot.remove_train(train)
            train.buyable = false
            train.instance_variable_set(:@local, true)

            corporation = corporation_by_id(national)
            train.owner = corporation
            corporation.trains << train
          end

          # Randomize and setup the corporations
          setup_corporations

          # Give all players stock turn token and remove unused
          setup_stock_turn_token
        end

        def sorted_corporations
          turn_corporations = self.class::TURN_CORPORATIONS[@current_turn]
          ipoed, others = if turn_corporations
                            @corporations.select { |c| turn_corporations.include?(c.name) }.partition(&:ipoed)
                          else
                            @corporations.partition(&:ipoed)
                          end
          # Remove floated minor nationals
          ipoed.reject! { |c| minor_national_corporation?(c) }

          # Remove Germany and Italy if we cant form them
          others.reject! { |c| germany_or_italy_national?(c) } unless convert_major_national?

          ipoed.sort + others
        end

        def status_array(corporation)
          return if !corporation?(corporation) || !corporation.floated?

          [["#{corporation.type == :share_5 ? '5' : '10'}-share corporation", 'bold']]
        end

        def status_str(corporation)
          return if corporation.floated?

          self.class::ENTITY_STATUS_TEXT[corporation.id]
        end

        def tile_lays(entity)
          return self.class::NATIONAL_TILE_LAYS if national_corporation?(entity)

          self.class::TILE_LAYS
        end

        def train_help(_entity, runnable_trains, _routes)
          return [] if runnable_trains.empty?

          entity = runnable_trains[0].owner

          help = []
          if runnable_trains.any? { |t| local_train?(t) }
            help << "L (local) trains run in a city which has a #{entity.name} token. "\
                    'They can additionally run to a single small station, but are not required to do so. '\
                    'They can thus be considered 1 (+1) trains. '\
                    'Only one L train may operate on each station token.'
          end

          if national_corporation?(entity)
            help << 'Nationals run a hypothetical train of infinite length, within its national boundaries. '\
                    'This train is allowed to run a route of just a single city.'
          end

          help << 'Obsolete trains only runs for ½ revenue.' if runnable_trains.any?(&:obsolete)
          help
        end

        def upgrade_cost(_tile, _hex, entity, _spender)
          return 0 if national_corporation?(entity)

          super
        end

        def upgrades_to?(from, to, _special = false, selected_company: nil)
          # London
          return to.name == self.class::LONDON_TILE if from.hex.name == self.class::LONDON_HEX && from.color == :brown

          # Paris
          return to.name == self.class::PARIS_TILE if from.hex.name == self.class::PARIS_HEX && from.color == :brown

          super
        end

        def can_par_share_price?(share_price, corporation)
          return (share_price.corporations.empty? || share_price.price == self.class::MAX_PAR_VALUE) unless corporation

          share_price.corporations.none? { |c| c.type != :stock_turn_corporation } ||
            share_price.price == self.class::MAX_PAR_VALUE
        end

        def convert_corporation?
          @phase.status.include?('can_convert_corporation')
        end

        def convert_major_national?
          @phase.status.include?('can_convert_major')
        end

        def event_brown_ferries!
          @log << '-- Event: Brown Ferries --'

          update_ferry_hex('F8', self.class::FERRY_TILE_F8, [{ hex: 'E7', edge: 5 }, { hex: 'F10', edge: 1 }])
          update_ferry_hex('H4', self.class::FERRY_TILE_H4, [{ hex: 'G3', edge: 5 }, { hex: 'I3', edge: 3 }])
        end

        def event_formation!
          @log << '-- Event: Forced formation of Major Nationals --'

          # Order: Switzerland, Spain, Benelux, Austro-Hungarian Empire, Italy, France, Germany, Great Britain
          forced_formation_national(corporation_by_id('SWN'))
          forced_formation_national(corporation_by_id('SPN'))
          forced_formation_national(corporation_by_id('BN'))
          forced_formation_national(corporation_by_id('AHN'))
          forced_formation_major(corporation_by_id(self.class::ITALY_NATIONAL), %w[I1 I2 I3 I4 I5])
          forced_formation_national(corporation_by_id('FN'))
          forced_formation_major(corporation_by_id(self.class::GERMANY_NATIONAL), %w[G1 G2 G3 G4 G5])
          forced_formation_national(corporation_by_id('GBN'))
        end

        def event_green_ferries!
          @log << '-- Event: Green Ferries --'

          update_ferry_hex('G7', self.class::FERRY_TILE_G7, [{ hex: 'G5', edge: 4 }, { hex: 'H8', edge: 2 }])
          update_ferry_hex('S25', self.class::FERRY_TILE_S25, [{ hex: 'R24', edge: 5 }, { hex: 'S23', edge: 4 }])
        end

        def forced_formation_major(corporation, minors)
          return if @major_national_formed[corporation.id]

          share_price = forced_formation_par_prices(corporation).last
          @stock_market.set_par(corporation, share_price)

          # Find the share holders to give a share, then close the minor
          minors.each do |m|
            minor = corporation_by_id(m)
            @share_pool.transfer_shares(corporation.ipo_shares.first.to_bundle, minor.owner) if minor.owner

            close_corporation(minor)
          end

          # Move the rest of the shares into the market
          corporation_shares = corporation.shares_of(corporation)
          @share_pool.transfer_shares(ShareBundle.new(corporation_shares), @share_pool) unless corporation_shares.empty?

          corporation.ipoed = true
          @major_national_formed[corporation.id] = true
        end

        def forced_formation_national(corporation)
          return if corporation.floated?

          # Set the correct par price
          share_price = forced_formation_par_prices(corporation).last
          @stock_market.set_par(corporation, share_price)

          # Find the president and give player the share, and spend the money. The player can go into debt
          player = corporation.par_via_exchange.owner
          share = corporation.ipo_shares.first
          @share_pool.transfer_shares(share.to_bundle, player, price: 0)
          player.spend(share_price.price, @bank, check_cash: false)

          # Move the rest of the shares into the market
          @share_pool.transfer_shares(ShareBundle.new(corporation.shares_of(corporation)), @share_pool)

          # Close the concession
          corporation.par_via_exchange.close!
        end

        def forced_formation_par_prices(corporation)
          par_type = phase_par_type(corporation)
          par_prices = @stock_market.par_prices.select do |p|
            p.types.include?(par_type) && can_par_share_price?(p, corporation)
          end
          par_prices.reject! { |p| p.price == self.class::MAX_PAR_VALUE } if par_prices.size > 1
          par_prices
        end

        def hex_is_port?(hex)
          hex.tile.icons.any? { |i| i.name == 'port' }
        end

        def hex_operating_rights?(entity, hex)
          nationals = operating_rights(entity)
          nationals.any? { |national| self.class::NATIONAL_REGION_HEXES[national].include?(hex.name) }
        end

        def hex_within_national_region?(entity, hex)
          self.class::NATIONAL_REGION_HEXES[entity.id].include?(hex.name)
        end

        def local_train?(train)
          self.class::LOCAL_TRAIN == train.name
        end

        def germany_or_italy_national?(corporation)
          return false unless corporation

          corporation.id == self.class::GERMANY_NATIONAL || corporation.id == self.class::ITALY_NATIONAL
        end

        def germany_or_italy_upgraded?(corporation)
          hexes = self.class::NATIONAL_REGION_HEXES[corporation.id]
          hexes.any? do |h|
            hex = hex_by_id(h)
            next unless hex.tile.cities.size.positive?

            hex.tile != hex.original_tile
          end
        end

        def major_national_corporation?(corporation)
          return false unless corporation

          corporation.type == :national
        end

        def minor_national_corporation?(corporation)
          return false unless corporation

          corporation.type == :minor_national
        end

        def national_corporation?(corporation)
          minor_national_corporation?(corporation) || major_national_corporation?(corporation)
        end

        def operating_rights(entity)
          player = entity.owner
          national_shares = player.shares_by_corporation.select { |c, s| national_corporation?(c) && !s.empty? }

          rights = self.class::CORPORATIONS_OPERATING_RIGHTS[entity.id]
          operating_rights = rights.is_a?(Array) ? rights.dup : [rights]
          unless @major_national_formed[self.class::GERMANY_NATIONAL]
            operating_rights.reject! { |o| o == self.class::GERMANY_NATIONAL }
          end
          unless @major_national_formed[self.class::ITALY_NATIONAL]
            operating_rights.reject! { |o| o == self.class::ITALY_NATIONAL }
          end

          (national_shares.keys.map(&:id) + operating_rights).uniq
        end

        def port_token_bonus(routes)
          # Find all the port hexes and see which route pays the most
          port_hexes = {}
          routes.each do |route|
            train = route.train
            next if local_train?(train)

            entity = route.train.owner
            stops = route.visited_stops
            train_multiplier = train.multiplier || 1
            train_multiplier /= 2 if train.obsolete

            ptb = [stops.first]
            ptb << stops.last unless stops.first == stops.last
            ptb.each do |stop|
              next if !stop || !stop.city? || !stop.tokened_by?(entity) || !hex_is_port?(stop.hex)

              revenue = self.class::PORT_TOKEN_BONUS[route.phase.name] * train_multiplier
              if !port_hexes[stop.hex] || revenue > port_hexes[stop.hex]['revenue']
                port_hexes[stop.hex] = { route: route, revenue: revenue }
              end
            end
          end

          port_bonus = Hash.new { |h, k| h[k] = 0 }
          port_hexes.each { |_, r| port_bonus[r['route']] += r['revenue'] }
          port_bonus
        end

        def corporation?(corporation)
          return false unless corporation

          corporation.type == :share_5 || corporation.type == :share_10
        end

        def phase_par_type(corporation)
          if national_corporation?(corporation) && !germany_or_italy_national?(corporation)
            return self.class::NATIONAL_PHASE_PAR_TYPES[@phase.name]
          end

          self.class::PHASE_PAR_TYPES[@phase.name]
        end

        def place_starting_token(corporation, token, hex_coordinates)
          hex = hex_by_id(hex_coordinates)
          city = hex.tile.cities.first
          city.place_token(corporation, token, free: true, check_tokenable: false)
        end

        def purchase_stock_turn_token(player, share_price)
          index = @player_setup_order.find_index(player)
          corporation = Corporation.new(
            sym: "ST#{index + 1}.#{@stock_turn_token_number[player] + 1}",
            name: 'Stock Turn Token',
            logo: "1866/#{index + 1}",
            tokens: [],
            type: 'stock_turn_corporation',
            float_percent: 50,
            shares: [50, 50],
            always_market_price: true,
            color: 'black',
            text_color: 'white',
            reservation_color: nil,
            capitalization: self.class::CAPITALIZATION,
          )
          corporation.ipoed = true
          corporation.owner = player

          @stock_market.set_par(corporation, share_price)
          share = corporation.ipo_shares.first
          @share_pool.transfer_shares(share.to_bundle, player)

          player.spend(share_price.price, @bank)
          @stock_turn_token_in_play[player] << corporation
          @stock_turn_token_number[player] += 1

          @log << "#{player.name} buys a stock turn token at #{format_currency(share_price.price)}"
        end

        def reorder_players_isr!
          current_order = @players.dup

          # Sort on least amount of money
          @players.sort_by! { |p| [p.cash, current_order.index(p)] }

          # The player holding the P1 will become priority dealer
          p1 = @companies.find { |c| c.id == 'P1' }
          if p1
            @players.delete(p1.owner)
            @players.unshift(p1.owner)
            p1.close!
            @log << "#{p1.name} closes"
          end
          @log << "-- Priority order: #{@players.map(&:name).join(', ')}"
        end

        def setup_corporations
          # Randomize from preset seed to get same order
          corps = @corporations.select { |c| c.type == :share_5 }.sort_by { rand }
          @removed_corporations = []

          # Select one of the three corporations based in each of GB, France, A-H, Germany & Italy
          starting_corps = []
          self.class::REGION_CORPORATIONS.each do |_, v|
            corp = corps.find { |c| v.include?(c.name) }
            starting_corps << corp
            corps.delete(corp)
          end

          # Include the next 8 corporations in the game, remove the last 7.
          corps.each_with_index do |c, index|
            if index < 8
              starting_corps << c
            else
              @removed_corporations << c
              @corporations.delete(c)
            end
          end

          # Put down the home tokens of all the removed corporations
          @removed_corporations.each do |corp|
            Array(corp.coordinates).each do |coord|
              token = Engine::Token.new(corp, logo: "/logos/1866/#{corp.name}_REMOVED.svg",
                                              simple_logo: "/logos/1866/#{corp.name}_REMOVED.svg",
                                              type: :removed)

              place_starting_token(corp, token, coord)
            end
            @log << "#{corp.name} - #{corp.full_name} is removed from the game"
          end
        end

        def setup_stock_turn_token
          # Give each player a stock turn company
          @players.each_with_index do |player, index|
            company = @companies.find { |c| c.id == "#{self.class::STOCK_TURN_TOKEN_PREFIX}#{index + 1}" }
            company.owner = player
            player.companies << company
          end

          # Remove the unused stock turn companies
          @companies.dup.each do |company|
            next if !stock_turn_token_company?(company) || company.owner

            @companies.delete(company)
          end
        end

        def stock_round_isr
          @log << '-- Initial Stock Round --'
          @round_counter += 1
          Engine::Round::Stock.new(self, [
            G1866::Step::BuySellParShares,
          ])
        end

        def stock_turn_corporation?(corporation)
          return false unless corporation

          corporation.type == :stock_turn_corporation
        end

        def stock_turn_token_company?(company)
          company.id[0..1] == self.class::STOCK_TURN_TOKEN_PREFIX
        end

        def train_type(train)
          train.name.include?('E') ? :etrain : :normal
        end

        def update_ferry_hex(hex_name, tile_code, hex_borders)
          hex = hex_by_id(hex_name)
          hex_tile = Engine::Tile.from_code(hex_name, :blue, tile_code)
          hex.tile = hex_tile

          hex_borders.each do |border|
            hex_border = hex_by_id(border['hex'])
            border = hex_border.tile.borders.find { |b| b.edge == border['edge'] }
            hex_border.tile.borders.delete(border)
          end
          update_hex_neighbors(hex)
        end

        def update_hex_neighbors(hex)
          hex.all_neighbors.each do |direction, neighbor|
            next if hex.tile.borders.any? { |border| border.edge == direction && border.type == :impassable }

            neighbor.neighbors[neighbor.neighbor_direction(hex)] = hex
            hex.neighbors[direction] = neighbor
          end
        end

        def visits_operating_rights?(entity, visits)
          nationals = operating_rights(entity)

          count = visits.count do |v|
            nationals.any? { |national| self.class::NATIONAL_REGION_HEXES[national].include?(v.hex.name) }
          end

          count == visits.size
        end

        def visits_within_national_region?(entity, visits)
          hexes = self.class::NATIONAL_REGION_HEXES[entity.id]
          visits.count { |v| hexes.include?(v.hex.name) } == visits.size
        end
      end
    end
  end
end
