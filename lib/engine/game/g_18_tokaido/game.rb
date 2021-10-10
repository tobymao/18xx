# frozen_string_literal: true

require_relative '../base'
require_relative 'meta'
require_relative 'step/buy_company'
require_relative 'step/draft_distribution'

module Engine
  module Game
    module G18Tokaido
      class Game < Game::Base
        include_meta(G18Tokaido::Meta)

        register_colors(green: '#237333',
                        red: '#d81e3e',
                        blue: '#0189d1',
                        yellow: '#FFF500',
                        orange: '#f48221',
                        brown: '#7b352a')

        TRACK_RESTRICTION = :permissive
        CURRENCY_FORMAT_STR = '¥%d'
        CERT_LIMIT = { 2 => 24, 3 => 16, 4 => 12 }.freeze
        STARTING_CASH = { 2 => 720, 3 => 550, 4 => 480 }.freeze
        CAPITALIZATION = :full
        MUST_SELL_IN_BLOCKS = false

        MARKET = [
          %w[75 80 85 90 100 110 125 140 160 180 200 225 250 275 300 325 360 400],
          %w[70 75 80 85 95p 105 115 130 145 160 180 200 225 250 275 300 325 360],
          %w[65 70 75 80p 85 95 105 115 130 145 160 180],
          %w[60 65 70p 75 80 85 95 105],
          %w[55 60 65 70 75 80],
          %w[50 55 60 65],
          %w[45 50 55],
          %w[40 45],
        ].freeze

        TILES = {
          '3' => 3,
          '4' => 3,
          '5' => 3,
          '6' => 3,
          '7' => 'unlimited',
          '8' => 'unlimited',
          '9' => 'unlimited',
          '14' => 3,
          '15' => 3,
          '23' => 3,
          '24' => 3,
          '25' => 2,
          '26' => 1,
          '27' => 1,
          '28' => 1,
          '29' => 1,
          '30' => 1,
          '31' => 1,
          '39' => 1,
          '40' => 1,
          '41' => 1,
          '42' => 1,
          '43' => 1,
          '44' => 1,
          '45' => 1,
          '46' => 1,
          '47' => 1,
          '57' => 3,
          '58' => 4,
          '70' => 1,
          '87' => 1,
          '88' => 1,
          '201' => 2,
          '202' => 2,
          '204' => 2,
          '207' => 2,
          '208' => 2,
          '611' => 3,
          '619' => 3,
          '621' => 2,
          '622' => 2,
          '915' => 1,
          'X1' =>
          {
            'count' => 3,
            'color' => 'brown',
            'code' =>
              'city=revenue:50,slots:2;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;' \
              'path=a:4,b:_0;label=Y',
          },
          'X2' =>
          {
            'count' => 2,
            'color' => 'gray',
            'code' =>
            'city=revenue:60,slots:3;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;label=Y',
          },
          'X10' =>
          {
            'count' => 1,
            'color' => 'green',
            'code' =>
              'city=revenue:40;city=revenue:40;path=a:0,b:_0;path=a:_0,b:1;path=a:3,b:_1;path=a:_1,b:4;label=O',
          },
          'X11' =>
          {
            'count' => 1,
            'color' => 'green',
            'code' =>
              'city=revenue:40;city=revenue:40;path=a:0,b:_0;path=a:_0,b:3;path=a:2,b:_1;path=a:_1,b:5;label=O',
          },
          'X13' =>
          {
            'count' => 2,
            'color' => 'brown',
            'code' =>
              'city=revenue:60,slots:3;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:5,b:_0;path=a:4,b:_0;label=O',
          },
          'X14' =>
          {
            'count' => 1,
            'color' => 'gray',
            'code' =>
              'city=revenue:70,slots:3;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;' \
              'path=a:4,b:_0;path=a:5,b:_0;label=O',
          },
          'X20' =>
          {
            'count' => 1,
            'color' => 'green',
            'code' =>
              'city=revenue:40;city=revenue:40;path=a:0,b:_0;path=a:_0,b:2;path=a:3,b:_1;path=a:_1,b:5;label=T',
          },
          'X21' =>
          {
            'count' => 1,
            'color' => 'green',
            'code' =>
              'city=revenue:40;city=revenue:40;path=a:0,b:_0;path=a:_0,b:1;path=a:3,b:_1;path=a:_1,b:4;label=T',
          },
          'X22' =>
          {
            'count' => 1,
            'color' => 'green',
            'code' =>
              'city=revenue:40;city=revenue:40;path=a:3,b:_0;path=a:_0,b:5;path=a:0,b:_1;path=a:_1,b:4;label=T',
          },
          'X23' =>
          {
            'count' => 2,
            'color' => 'brown',
            'code' =>
              'city=revenue:60,slots:3;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:5,b:_0;path=a:4,b:_0;label=T',
          },
          'X24' =>
          {
            'count' => 1,
            'color' => 'gray',
            'code' =>
              'city=revenue:80,slots:3;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;' \
              'path=a:4,b:_0;path=a:5,b:_0;label=T',
          },
        }.freeze

        LOCATION_NAMES = {
          'A11' => 'Chugoku',
          'A15' => 'Shikoku',
          'B8' => 'Maizuru',
          'B14' => 'Kobe',
          'C11' => 'Kyoto',
          'C13' => 'Osaka',
          'C15' => 'Osaka-wan',
          'D8' => 'Tsuruga',
          'D12' => 'Nara',
          'D14' => 'Sakai',
          'E5' => 'Nihon-kai',
          'E9' => 'Biwa-ko',
          'F6' => 'Kanazawa',
          'F10' => 'Nagoya',
          'F12' => 'Ise-wan',
          'G3' => 'Toyama-wan',
          'G5' => 'Toyama',
          'G7' => 'Takayama',
          'G11' => 'Hamamatsu',
          'H12' => 'Shizuoka',
          'I5' => 'Matsumoto',
          'I9' => 'Saitama',
          'I11' => 'Yokohama',
          'J4' => 'Nagano',
          'J8' => 'Takasaki',
          'J10' => 'Tokyo',
          'J12' => 'Tokyo-wan',
          'K1' => 'Niigata',
          'K9' => 'Tsukuba',
          'K11' => 'Chiba',
          'L6' => 'Fukushima',
          'M3' => 'Aomori',
          'M5' => 'Sendai',
        }.freeze

        LAYOUT = :flat

        HEXES = {
          white: {
            %w[D10 E7 E11 E13 F4 G9 K7 L4] => '',
            %w[B10 B12 C9 F8 H4 H6 H8 H10 I3 I7 J2 J6 K3 K5] => 'upgrade=cost:40,terrain:mountain',
            %w[B8 D12 D8 D14 I5 I9 J8 K9 K11 L6] => 'town=revenue:0',
            %w[G7] => 'town=revenue:0;upgrade=cost:40,terrain:mountain',
            %w[B14 F6 G5 I11 M5] => 'city=revenue:0',
            %w[C11 F10] => 'city=revenue:0;label=Y',
          },
          yellow: {
            ['C13'] =>
              'city=revenue:30;city=revenue:30;path=a:1,b:_0;path=a:3,b:_1;label=O',
            ['J10'] =>
              'city=revenue:30;city=revenue:30;path=a:1,b:_0;path=a:4,b:_1;label=T',
            ['J4'] =>
              'city=revenue:30;path=a:0,b:_0;path=a:1,b:_0;path=a:4,b:_0;label=Y',
            ['L8'] =>
              'path=a:1,b:4',
            ['M7'] =>
              'path=a:1,b:3',
          },
          gray: {
            ['A13'] => 'path=a:4,b:5',
            ['E15'] => 'path=a:2,b:3',
            ['G11'] => 'town=revenue:20;path=a:2,b:_0;path=a:_0,b:5',
            ['H12'] => 'town=revenue:20;path=a:2,b:_0;path=a:_0,b:4',
          },
          red: {
            ['A9'] =>
              'offboard=revenue:yellow_30|brown_40|gray_50,hide:1,groups:Chuugoku;path=a:4,b:_0;' \
              'path=a:5,b:_0;border=edge:0',
            ['A11'] =>
              'offboard=revenue:yellow_30|brown_40|gray_50,groups:Chuugoku;path=a:4,b:_0;path=a:5,b:_0;border=edge:3',
            ['A15'] =>
              'offboard=revenue:yellow_20|brown_30|gray_40;path=a:4,b:_0',
            ['K1'] =>
              'offboard=revenue:yellow_20|brown_30|gray_40;path=a:0,b:_0;path=a:1,b:_0',
            ['M3'] =>
              'offboard=revenue:yellow_30|brown_40|gray_50;path=a:0,b:_0;path=a:1,b:_0',
          },
          blue: {
            ['E9'] => '',
            ['C15'] => 'offboard=revenue:yellow_30|brown_40|gray_50;path=a:2,b:_0;path=a:3,b:_0',
            ['E5'] =>
              'offboard=revenue:yellow_20|brown_30|gray_40;path=a:5,b:_0',
            ['F12'] =>
              'offboard=revenue:yellow_20|brown_30|gray_40;path=a:3,b:_0',
            ['G3'] =>
              'offboard=revenue:yellow_20|brown_30|gray_40;path=a:0,b:_0',
            ['J12'] =>
              'offboard=revenue:yellow_40|brown_50|gray_80;path=a:2,b:_0;path=a:3,b:_0',
          },
        }.freeze

        PHASES = [
          {
            name: '2',
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
            tiles: %i[yellow green brown gray],
            operating_rounds: 3,
          },
        ].freeze

        TRAINS = [
          {
            name: '2',
            distance: 2,
            price: 80,
            rusts_on: '4',
            num: 7,
          },
          {
            name: '3',
            distance: 3,
            price: 180,
            rusts_on: '6',
            num: 5,
          },
          {
            name: '4',
            distance: 4,
            price: 300,
            rusts_on: 'D',
            num: 4,
          },
          {
            name: '5',
            distance: 5,
            price: 500,
            num: 3,
            events: [{ 'type' => 'close_companies' }],
          },
          { name: '6', distance: 6, price: 630, num: 2 },
          {
            name: 'D',
            distance: 999,
            price: 900,
            num: 20,
            available_on: '6',
            events: [{ 'type' => 'signal_end_game' }],
            discount: { '4' => 200, '5' => 200, '6' => 200 },
          },
        ].freeze

        EVENTS_TEXT = Base::EVENTS_TEXT.merge(
          'signal_end_game' => [
            'Triggers End Game',
            'Game ends after next set of ORs when D train purchased or exported, ' \
            'purchasing a D train triggers a stock round immediately after current OR',
          ]
        )

        COMPANIES = [
          {
            name: 'Kyoto-tetsudo',
            value: 20,
            revenue: 5,
            desc: 'No special ability. Blocks hex D10 while owned by a player.',
            sym: 'KT',
            abilities: [{ type: 'blocks_hexes', owner_type: 'player', hexes: ['D10'] }],
            color: nil,
          },
          {
            name: 'Osakayama Tunnel',
            value: 40,
            revenue: 10,
            desc: 'Reduces, for the owning corporation, the cost of laying all mountain tiles by ¥20.',
            sym: 'OT',
            abilities: [
              {
                type: 'tile_discount',
                discount: 20,
                terrain: 'mountain',
                owner_type: 'corporation',
              },
            ],
            color: nil,
          },
          {
            name: 'Fish Market',
            value: 60,
            revenue: 10,
            desc: 'The owning corporation may assign the Fish Market to any port location (C15, E5, F12, G3, or J12) ' \
                  'to add ¥20 to all routes it runs to this location until the end of the game. Pays no other revenue to ' \
                  'a corporation.',
            sym: 'FM',
            abilities: [
              { type: 'close', on_phase: 'never', owner_type: 'corporation' },
              {
                type: 'assign_hexes',
                when: 'owning_corp_or_turn',
                hexes: %w[C15 E5 F12 G3 J12],
                count: 1,
                owner_type: 'corporation',
              },
              {
                type: 'assign_corporation',
                when: 'any',
                count: 1,
                owner_type: 'corporation',
              },
            ],
            color: nil,
          },
          {
            name: 'Stationmaster Tama',
            value: 60,
            revenue: 10,
            desc: 'Provides an additional free station marker (that costs ¥0 to place) to corporation that buys this private ' \
                  'from a player, awarded at time of purchase.  Closes when purchased by a corporation.',
            sym: 'SMT',
            abilities: [
              {
                type: 'additional_token',
                count: 1,
                owner_type: 'corporation',
              },
            ],
            color: nil,
          },
          {
            name: 'Sleeper Train',
            value: 80,
            revenue: 0,
            desc: 'Adds ¥10 per city (not town, port, or connection) visited by any one train of the owning ' \
                  'corporation. Never closes once purchased by a corporation.',
            sym: 'ST',
            abilities: [{ type: 'close', on_phase: 'never', owner_type: 'corporation' }],
            color: nil,
          },
          {
            name: 'Inoue Masaru',
            value: 100,
            revenue: 0,
            desc: 'Purchasing player immediately takes a 10% share of the JGR. This does not close the private ' \
                  'company. This private company has no other special ability.',
            sym: 'IM',
            abilities: [{ type: 'shares', shares: 'JGR_1' }],
            color: nil,
          },
        ].freeze

        ASSIGNMENT_TOKENS = {
          'FM' => '/icons/18_tokaido/fm_token.svg',
        }.freeze

        def fish_market
          @@fish_market ||= company_by_id('FM')
        end

        def sleeper_train
          @sleeper_train ||= company_by_id('ST')
        end

        CORPORATIONS = [
          {
            float_percent: 60,
            sym: 'SRC',
            name: "San'yo-tetsudo",
            logo: '18_tokaido/SRC',
            simple_logo: '18_tokaido/SRC.alt',
            tokens: [0, 40, 60],
            coordinates: 'B14',
            color: '#ef8f2f',
            text_color: 'black',
            reservation_color: nil,
          },
          {
            float_percent: 60,
            sym: 'KRC',
            name: 'Kansai-tetsudo',
            logo: '18_tokaido/KRC',
            simple_logo: '18_tokaido/KRC.alt',
            tokens: [0, 40, 60],
            coordinates: 'C13',
            city: 1,
            color: '#2f7f2f',
            text_color: 'white',
            reservation_color: nil,
          },
          {
            float_percent: 60,
            sym: 'ARC',
            name: 'Aichi-tetsudo',
            logo: '18_tokaido/ARC',
            simple_logo: '18_tokaido/ARC.alt',
            tokens: [0, 40],
            coordinates: 'F10',
            color: '#2f2f9f',
            text_color: 'white',
            reservation_color: nil,
          },
          {
            float_percent: 60,
            sym: 'JGR',
            name: 'Tetsudo-sho',
            logo: '18_tokaido/JGR',
            simple_logo: '18_tokaido/JGR.alt',
            tokens: [0, 40],
            coordinates: 'I11',
            color: '#ef2f2f',
            text_color: 'white',
            reservation_color: nil,
          },
          {
            float_percent: 60,
            sym: 'NRC',
            name: 'Nippon-tetsudo',
            logo: '18_tokaido/NRC',
            simple_logo: '18_tokaido/NRC.alt',
            tokens: [0, 40, 60],
            coordinates: 'J10',
            city: 1,
            color: 'black',
            text_color: 'white',
            reservation_color: nil,
          },
          {
            float_percent: 60,
            sym: 'SR',
            name: 'Shinano-tetsudo',
            logo: '18_tokaido/SR',
            simple_logo: '18_tokaido/SR.alt',
            tokens: [0, 40, 60],
            coordinates: 'J4',
            color: '#efef4f',
            text_color: 'black',
            reservation_color: nil,
          },
        ].freeze

        def setup
          @reverse = true
          @d_train_exported = false
        end

        def init_round
          Engine::Round::Draft.new(
            self,
            [G18Tokaido::Step::DraftDistribution],
            snake_order: true
          )
        end

        def init_round_finished
          @companies.reject(&:owned_by_player?).sort_by(&:name).each do |company|
            company.close!
            @log << "#{company.name} is removed"
          end
          @draft_finished = true
        end

        def reorder_players_by_cash
          current_order = @players.dup
          if @reverse
            @reverse = false
            @players.reverse!
          else
            @players.sort_by! { |p| [p.cash, current_order.index(p)] }
          end
          @log << "Priority order: #{@players.reject(&:bankrupt).map(&:name).join(', ')}"
        end

        def priority_deal_player
          # Don't move around priority deal marker; only changes when players are reordered at beginning of stock round
          players.first
        end

        def new_stock_round
          @log << "-- #{round_description('Stock')} --"
          reorder_players_by_cash
          stock_round
        end

        SELL_BUY_ORDER = :sell_buy

        def stock_round
          Engine::Round::Stock.new(self, [
            Engine::Step::DiscardTrain,
            Engine::Step::BuySellParShares,
          ])
        end

        def operating_round(round_num)
          Engine::Round::Operating.new(self, [
            Engine::Step::Bankrupt,
            G18Tokaido::Step::BuyCompany,
            Engine::Step::Assign,
            Engine::Step::Track,
            Engine::Step::Token,
            Engine::Step::Route,
            Engine::Step::Dividend,
            Engine::Step::DiscardTrain,
            Engine::Step::BuyTrain,
            [G18Tokaido::Step::BuyCompany, { blocks: true }],
          ], round_num: round_num)
        end

        def next_round!
          @round =
            case @round
            when Engine::Round::Draft
              init_round_finished
              new_stock_round
            when Engine::Round::Stock
              @operating_rounds = @phase.operating_rounds
              @need_last_stock_round = false
              new_operating_round
            when Engine::Round::Operating
              if @need_last_stock_round
                @turn += 1
                new_stock_round
              elsif @round.round_num < @operating_rounds
                new_operating_round(@round.round_num + 1)
              else
                @turn += 1
                or_set_finished
                new_stock_round
              end
            end
        end

        GAME_END_CHECK = { bankrupt: :immediate, final_phase: :full_or }.freeze

        def event_signal_end_game!
          @need_last_stock_round = true
          game_end_check
          @log << 'First D train bought/exported, end game triggered'
        end

        def game_ending_description
          _, after = game_end_check
          return unless after

          ending_or = @need_last_stock_round && round.class.short_name != 'SR' ? turn + 1 : turn
          "Game ends at conclusion of OR #{ending_or}.#{operating_rounds}"
        end

        def end_now?(after)
          return false if @need_last_stock_round

          super
        end

        def or_set_finished
          return if @d_train_exported

          @d_train_exported = true if depot.upcoming.first.name == 'D'
          depot.export!
        end

        def best_sleeper_route(routes)
          routes.routes.reduce(nil) do |best, r|
            best.nil? || sleeper_bonus(r) > sleeper_bonus(best) ? r : best
          end
        end

        def sleeper_bonus(route)
          return 0 unless route

          route.visited_stops.count { |s| s.is_a? Engine::Part::City } * 10
        end

        def revenue_for(route, stops)
          revenue = super
          if route.train.owner.companies.include?(fish_market) && stops.find { |s| s.hex.assigned?(fish_market&.id) }
            revenue += 20
          end
          if route.train.owner.companies.include?(sleeper_train) && route == best_sleeper_route(route)
            revenue += sleeper_bonus(best_sleeper_route(route))
          end
          revenue
        end

        def revenue_str(route)
          stops = route.stops
          str = super
          if route.train.owner.companies.include?(fish_market) && stops.find { |s| s.hex.assigned?(fish_market&.id) }
            str += ' + Fish Market'
          end
          str += ' + Sleeper Train' if route.train.owner.companies.include?(sleeper_train) && route == best_sleeper_route(route)
          str
        end

        def timeline
          @timeline = [
            'At the end of each set of ORs the next available train will be exported (removed, triggering ' \
            'phase change as if purchased)',
          ]
        end
      end
    end
  end
end
