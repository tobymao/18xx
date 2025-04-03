# frozen_string_literal: true

module Engine
  module Game
    module GSystem18
      module MapUKLimitedCustomization
        def map_uk_limited_game_tiles(tiles)
          tiles.delete('12')
          tiles.delete('13')
          tiles.delete('205')
          tiles.delete('206')

          tiles
        end

        def map_uk_limited_layout
          :pointy
        end

        def map_uk_limited_game_location_names
          {
            'B3' => 'Glasgow',
            'B5' => 'Edinburgh',
            'C6' => 'Newcastle',
            'D7' => 'York',
            'E4' => 'Liverpool & Holyhead',
            'E6' => 'Manchester',
            'F5' => 'Birmingham',
            'F7' => 'Nottingham & Peterborough',
            'G4' => 'Bristol',
            'G6' => 'Northhampton',
            'H3' => 'Exeter',
            'H5' => 'Bournemouth',
            'H7' => 'London',
          }
        end

        # rubocop:disable Layout/LineLength
        def map_uk_limited_game_hexes
          {
            gray: {
              ['A2'] => 'junction;path=a:5,b:_0,terminal:1',
              ['A4'] => 'path=a:0,b:5',
              %w[B1 H1] => 'junction;path=a:4,b:_0,terminal:1',
              ['B7'] => 'path=a:0,b:1',
              ['C2'] => 'path=a:3,b:4',
              ['C8'] => 'path=a:0,b:1',
              ['D3'] => 'path=a:3,b:4;path=a:4,b:5',
              ['F3'] => 'path=a:3,b:4;path=a:4,b:5',
              ['G2'] => 'path=a:4,b:5',
              ['H7'] => 'city=revenue:yellow_20|green_30|brown_40|gray_50,loc:1.5;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0,terminal:1',
              ['I2'] => 'junction;path=a:3,b:_0,terminal:1',
              ['I4'] => 'path=a:2,b:3',
              ['I6'] => 'junction;path=a:2,b:_0,terminal:1',
            },
            white: {
              %w[C4 D5 E8 F9 G8] => '',
              %w[D7 H3 H5] => 'city=revenue:0,outline:1',
              ['F7'] => 'town=revenue:0;town=revenue:0',
              %w[C6 G4 G6] => 'city=revenue:0',
            },
            yellow: {
              %w[E4] => 'city=revenue:0;city=revenue:0;label=OO',
              ['E6'] => 'city=revenue:30;path=a:0,b:_0;path=a:2,b:_0;path=a:4,b:_0;label=B',
              ['F5'] => 'city=revenue:30;path=a:2,b:_0;path=a:4,b:_0;label=B',
            },
            green: {
              ['B3'] => 'city=revenue:30,slots:2;path=a:0,b:_0;path=a:4,b:_0;path=a:4,b:_0;path=a:5,b:_0',
              ['B5'] => 'city=revenue:40,loc:2;city=revenue:40;path=a:1,b:_0;path=a:5,b:_1;label=OO',
            },
          }
        end
        # rubocop:enable Layout/LineLength

        def map_uk_limited_game_companies
          []
        end

        # DGN GFN PHX KKN SPX
        def map_uk_limited_game_corporations(corps)
          corps.each_with_index do |c, idx|
            c[:coordinates] = %w[F5 B5 B3 H7 E6][idx]
          end

          corps
        end

        def map_uk_limited_game_cash
          { 2 => 850, 3 => 575, 4 => 425 }
        end

        def map_uk_limited_game_cert_limit
          { 2 => 20, 3 => 13, 4 => 11 }
        end

        def map_uk_limited_game_capitalization
          :full
        end

        def map_uk_limited_game_market
          self.class::MARKET_2D
        end

        def map_uk_limited_game_trains(trains)
          # don't use 8 trains
          trains.delete(find_train(trains, '8'))
          # udpate quantities
          find_train(trains, '2')[:num] = 5
          find_train(trains, '2')[:rusts_on] = 'OR3'
          find_train(trains, '3')[:num] = 4
          find_train(trains, '3')[:rusts_on] = 'OR4'
          find_train(trains, '4')[:num] = 3
          find_train(trains, '4')[:rusts_on] = 'OR5'
          find_train(trains, '5')[:num] = 2
          find_train(trains, '6')[:num] = 1
          find_train(trains, 'D')[:num] = 10
          trains
        end

        def map_uk_limited_game_phases
          self.class::S18_FULLCAP_PHASES
        end

        def map_uk_limited_constants
          redef_const(:CURRENCY_FORMAT_STR, '£%s')
        end

        def map_uk_limited_setup
          @uk_or_count = 0
        end

        def map_uk_limited_rust_trains!(_train, _entity); end

        def map_uk_limited_rust?(train, sym)
          train.rusts_on == sym
        end

        def map_uk_limited_or_round_finished
          @uk_or_count += 1
          return unless [3, 4, 5].include?(@uk_or_count)

          rust_event = "OR#{@uk_or_count}"

          rusted_trains = []
          owners = Hash.new(0)

          trains.each do |t|
            next if t.rusted
            next unless t.rusts_on == rust_event

            rusted_trains << t.name
            owners[t.owner.name] += 1
            rust(t)
          end

          @crowded_corps = nil

          return if rusted_trains.empty?

          @log << "-- Event: #{rusted_trains.uniq.join(', ')} trains rust " \
                  "( #{owners.map { |c, t| "#{c} x#{t}" }.join(', ')}) --"
        end

        def map_uk_limited_upgrade_ignore_num_cities(from)
          return false if from.cities.none?
          return false unless from.color == :white

          from.cities[0].outline
        end

        def map_uk_limited_timeline
          @timeline ||= [
            'After the 3rd OR, all 2 trains are rusted',
            'After the 4rd OR, all 3 trains are rusted',
            'After the 5rd OR, all 4 trains are rusted',
            '(Note that the rusting occurs after a certain number of ORs, not OR sets)',
          ].freeze
          @timeline
        end
      end
    end
  end
end
