# frozen_string_literal: true

require_relative 'meta'
require_relative '../base'
require_relative '../g_1830/game'

module Engine
  module Game
    module G1830Plus
      class Game < G1830::Game
        include_meta(G1830Plus::Meta)
        CERT_LIMIT = { 2 => 32, 3 => 27, 4 => 20, 5 => 16, 6 => 14, 7 => 13 }.freeze

        STARTING_CASH = { 2 => 1200, 3 => 800, 4 => 600, 5 => 480, 6 => 400, 7 => 350 }.freeze

        LOCATION_NAMES = {
          'D2' => 'Lansing',
          'F2' => 'Chicago',
          'L2' => 'Chattanooga',
          'K7' => 'Huntington',
          'K3' => 'Lexington',
          'F4' => 'Toledo',
          'J14' => 'Washington',
          'F22' => 'Providence',
          'E5' => 'Detroit & Windsor',
          'L16' => 'Norfolk',
          'D10' => 'Hamilton & Toronto',
          'F6' => 'Cleveland',
          'E7' => 'London',
          'A11' => 'Canadian West',
          'K13' => 'Richmond',
          'M13' => 'Deep South',
          'E11' => 'Dunkirk & Buffalo',
          'H12' => 'Altoona',
          'D14' => 'Rochester',
          'C15' => 'Kingston',
          'I15' => 'Baltimore',
          'B16' => 'Ottawa',
          'F16' => 'Scranton',
          'H18' => 'Philadelphia & Trenton',
          'A19' => 'Montreal',
          'E19' => 'Albany',
          'G19' => 'New York & Newark',
          'I19' => 'Atlantic City',
          'F24' => 'Mansfield',
          'B20' => 'Burlington & Plattsburgh',
          'E23' => 'Boston',
          'B24' => 'Maritime Provinces',
          'D4' => 'Flint',
          'F10' => 'Erie',
          'G7' => 'Akron & Canton',
          'G17' => 'Reading & Allentown',
          'F20' => 'New Haven & Hartford',
          'H4' => 'Columbus',
          'B10' => 'Barrie',
          'H10' => 'Pittsburgh',
          'H16' => 'Lancaster',
        }.freeze

        HEXES = {
          red: {
            ['F2'] =>
                     'offboard=revenue:yellow_40|brown_70;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0',
            ['K1'] =>
                   'offboard=revenue:yellow_30|brown_60,hide:1,groups:Gulf;path=a:4,b:_0;border=edge:5',
            ['L2'] =>
                   'offboard=revenue:yellow_30|brown_60;path=a:3,b:_0;path=a:4,b:_0;border=edge:2',
            ['A9'] =>
                   'offboard=revenue:yellow_30|brown_50,hide:1,groups:Canada;path=a:5,b:_0;border=edge:4',
            ['A11'] =>
                   'offboard=revenue:yellow_30|brown_50,groups:Canada;path=a:5,b:_0;path=a:0,b:_0;border=edge:1',
            ['M13'] => 'offboard=revenue:yellow_30|brown_40;path=a:2,b:_0;path=a:3,b:_0',
            ['B24'] => 'offboard=revenue:yellow_20|brown_30;path=a:1,b:_0;path=a:0,b:_0',
          },
          gray: {
            ['D2'] => 'city=revenue:20;path=a:5,b:_0;path=a:4,b:_0',
            ['F6'] => 'city=revenue:30;path=a:5,b:_0;path=a:0,b:_0',
            ['E9'] => 'path=a:2,b:3;path=a:1,b:3',
            ['D14'] => 'city=revenue:20;path=a:1,b:_0;path=a:4,b:_0;path=a:0,b:_0',
            ['C15'] => 'town=revenue:10;path=a:1,b:_0;path=a:3,b:_0',
            ['L16'] => 'city=slots:2,revenue:yellow_30|brown_50;path=a:2,b:_0;path=a:1,b:_0;path=a:3,b:_0',
            ['A17'] => 'path=a:0,b:5;path=a:0,b:4;path=a:5,b:4',
            ['A19'] => 'city=revenue:yellow_40|brown_60,slots:2;path=a:5,b:_0;path=a:0,b:_0;path=a:1,b:_0',
            %w[F24] => 'town=revenue:10;path=a:1,b:_0;path=a:2,b:_0',
            %w[I19] => 'town=revenue:10;path=a:1,b:_0;path=a:2,b:_0;path=a:0,b:_0',
            ['D24'] => 'path=a:1,b:0;path=a:2,b:0',
          },
          white: {
            %w[F4 J14 F22] => 'city=revenue:0;upgrade=cost:80,terrain:water',
            ['E7'] => 'town=revenue:0;border=edge:5,type:impassable',
            ['F8'] => 'border=edge:2,type:impassable',
            ['C11'] => 'border=edge:5,type:impassable',
            ['C13'] => 'border=edge:0,type:impassable',
            ['D12'] => 'border=edge:2,type:impassable;border=edge:3,type:impassable',
            ['B16'] => 'city=revenue:0;border=edge:5,type:impassable',
            ['C17'] => 'upgrade=cost:120,terrain:mountain;border=edge:2,type:impassable',
            %w[D4 F10] => 'town',
            %w[C5] => 'border=edge:4,type:impassable',
            %w[C7] => 'border=edge:1,type:impassable',
            %w[I13
               D18
               B12
               B14
               B22
               C9
               C23
               D8
               D16
               D20
               E3
               E13
               E15
               F12
               F14
               F18
               G3
               G5
               G9
               G11
               H2
               H6
               H8
               H14
               I3
               I5
               I7
               K5 L4 L12 L14] => 'blank',
            %w[G15 E17 E21 G13 I11 J10 J12 L6 L8 L10 K9 K11] =>
            'upgrade=cost:120,terrain:mountain',
            %w[D22] => 'upgrade=cost:80,terrain:mountain',
            %w[C21] => 'upgrade=cost:40,terrain:mountain',
            %w[J2 J4 J6 J8 I9 K15 K17 J16 J18] => 'upgrade=cost:40,terrain:water',
            %w[E19 H4 B10 H10 H16 K3 K13] => 'city',
            ['F16'] => 'city=revenue:0;upgrade=cost:120,terrain:mountain',
            ['K7'] => 'city=revenue:0;upgrade=cost:80,terrain:mountain',
            %w[G7 G17 F20 B20] => 'town=revenue:0;town=revenue:0',
            %w[D6 I17 B18 C19] => 'upgrade=cost:80,terrain:water',
          },
          yellow: {
            %w[E5] =>
                     'city=revenue:20;city=revenue:0;label=OO;upgrade=cost:80,terrain:water;path=a:1,b:_0',
            %w[D10] =>
                    'city=revenue:0;city=revenue:0;label=OO;upgrade=cost:80,terrain:water',
            %w[E11 H18] => 'city=revenue:0;city=revenue:0;label=OO',
            ['I15'] => 'city=revenue:30;path=a:4,b:_0;path=a:0,b:_0;label=B',
            ['G19'] =>
            'city=revenue:40;city=revenue:40;path=a:3,b:_0;path=a:0,b:_1;label=NY;upgrade=cost:80,terrain:water',
            ['E23'] => 'city=revenue:30;path=a:3,b:_0;path=a:5,b:_0;label=B',
          },
          green: {
            ['H12'] => 'halt;halt'\
            ';path=a:4,b:1;path=a:4,b:_0;path=a:1,b:_0'\
            ';path=a:5,b:1;path=a:5,b:_1;path=a:1,b:_1',
          },
        }.freeze

        LAYOUT = :pointy

        def place_home_token(corporation)
          return super unless corporation == prr

          return if corporation.tokens.first&.used

          # There's a PRR icon on the map for this
          hex_by_id('H12').tile.icons << Engine::Part::Icon.new('../logos/18_chesapeake/PRR')
          hex_by_id('H12').tile.reservations.delete(prr)
          corporation.tokens.first.used = true
        end

        def prr
          corporation_by_id('PRR')
        end

        def city_tokened_by?(stop, corporation)
          return true if corporation == prr && stop.hex.id == 'H12'

          super
        end

        def check_distance(route, visits)
          distance = super

          prr_halt_visits = route.stops.count(&:halt?)
          prr_token_visits = route.stops.count { |s| s.city? && s.tokened_by?(prr) }
          raise GameError, 'Only PRR may use PRR home halt' if prr_halt_visits.positive? && route.train.owner != prr
          raise GameError, 'Train may not visit PRR home halt more than once' if prr_halt_visits > 1
          raise GameError, 'Train must use PRR station or home halt' if route.train.owner == prr &&
              prr_token_visits.zero? && prr_halt_visits.zero?
        end

        def max_halts(route)
          route.train.owner == prr ? 1 : 0
        end

        def compute_stops(route)
          # This only applies to PRR
          unless route.train.owner == prr
            route.halts = 0
            return super
          end

          visits = route.visited_stops
          return [] if visits.empty?

          # The non-halts are always stops
          stops = visits.reject(&:halt?)

          allowance = [1, route.train.distance - stops.size].min

          # add in halts requested (from previous run or UI button)
          #
          # reset requested halts to nil if no halts on route, ignoring halts, not using halt for subsidies,
          # maximum halts allowed is zero, or requested halts is greater than maximum allowed
          halts = visits.select(&:halt?)

          halt_max = 1

          route.halts = nil if halts.empty? || route.halts && route.halts > halt_max

          num_halts = [halts.size, (route.halts || 0)].min
          if num_halts.positive?
            stops.concat(halts.take(num_halts))
            allowance -= num_halts
          end

          # if requested halts is nil (i.e. this is first time for this route), add as many halts as possible if
          # there are halts on route, there is room for some, and we aren't ignoring halts
          if !route.halts && halts.any? && allowance.positive?
            num_halts = [halts.size, allowance].min
            stops.concat(halts.take(num_halts))
          end

          # update route halts
          route.halts = num_halts if !halts.empty? || route.halts

          stops
        end

        def route_distance(route)
          route.stops.size
        end

        def revenue_for(route, stops)
          revenue = super
          # route halts default to YES
          revenue += 10 if stops.any?(&:halt?) && !route.halts&.negative?
          revenue
        end

        def routes_subsidy(_routes)
          0
        end

        def subsidy_for(_route, _stops)
          0
        end

        def setup
          @prr_graph = Graph.new(self, home_as_token: true)
        end

        def graph_for_entity(entity)
          entity == prr ? @prr_graph : @graph
        end

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
            Engine::Step::BuyTrain,
            [Engine::Step::BuyCompany, { blocks: true }],
          ], round_num: round_num)
        end
      end
    end
  end
end
