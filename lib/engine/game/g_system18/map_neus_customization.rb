# frozen_string_literal: true

module Engine
  module Game
    module GSystem18
      module MapNeusCustomization
        def map_neus_game_tiles(tiles)
          tiles.delete('5')
          tiles.delete('6')
          tiles.delete('12')
          tiles.delete('13')
          tiles.delete('205')
          tiles.delete('206')
          tiles.delete('619')
          tiles.merge!({
                         '54' => 1,
                         '62' => 1,
                         'X1' =>
            {
              'count' => 1,
              'color' => 'yellow',
              'code' =>
              'city=revenue:30;path=a:2,b:_0;path=a:4,b:_0;label=B',
            },
                         'X2' =>
            {
              'count' => 1,
              'color' => 'gray',
              'code' =>
              'city=revenue:70,slots:2;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;label=B',
            },
                         'X3' =>
              {
                'count' => 1,
                'color' => 'gray',
                'code' =>
                'city=revenue:100,slots:4;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;label=NY',
              },
                       })

          tiles
        end

        def map_neus_layout
          :pointy
        end

        def map_neus_game_location_names
          {
            'B3' => 'Chicago',
            'B5' => 'Detroit & Cleveland',
            'B7' => 'Erie',
            'B9' => 'Albany',
            'B11' => 'Boston',
            'C4' => 'Cincinnati',
            'C10' => 'New York City',
            'D9' => 'Washington DC',
          }
        end

        def map_neus_game_hexes
          {
            gray: {
              %w[A6] => 'path=a:0,b:5',
              %w[A2] => 'path=a:4,b:5',
              %w[A4] => 'path=a:1,b:5',
              %w[A8] => 'path=a:0,b:5;path=a:0,b:4',
              %w[A12] => 'path=a:0,b:1',

              %w[D3] => 'path=a:3,b:4',
              %w[D11] => 'path=a:0,b:1',
              %w[E8 E10] => 'path=a:2,b:3',
              %w[B1] => 'junction;path=a:4,b:_0,terminal:1',
              %w[C2] => 'junction;path=a:3,b:_0,terminal:1',
            },
            blue: {
              %w[B13] => 'junction;path=a:1,b:_0,terminal:1',
              %w[C12] => 'junction;path=a:2,b:_0,terminal:1',

            },
            white: {
              %w[A10] => '',
              %w[B7 C4] => 'city',
              %w[B3] => 'city=revenue:0;label=B',
              %w[B9] => 'city=revenue:0;upgrade=cost:40,terrain:mountain',
              %w[B11] => 'city=revenue:0;label=B',
              %w[C6] => 'town=revenue:0;town=revenue:0;upgrade=cost:120,terrain:mountain',
              %w[C8] => 'town=revenue:0;town=revenue:0;upgrade=cost:40,terrain:mountain',
              %w[D5] => 'upgrade=cost:40,terrain:mountain',
              %w[D7] => 'upgrade=cost:40,terrain:mountain',
            },
            yellow: {
              %w[B5] => 'city=revenue:0;city=revenue:0;label=OO',
              %w[C10] => 'city=revenue:40;city=revenue:40;path=a:2,b:_0;label=NY',
              %w[D9] => 'city=revenue:30;city=revenue:0;path=a:2,b:_0;label=OO',
            },
          }
        end

        def map_neus_game_companies
          [
            {
              name: 'Locomotive Works',
              value: 150,
              revenue: 30,
              desc: 'Does not close while owned by a player. If owned by a player '\
                    'when the first 5-train is purchased it may no longer be sold '\
                    'to a public company and the revenue is increased to 50.',
              sym: 'LW',
              abilities: [{ type: 'close', on_phase: 'never', owner_type: 'player' },
                          {
                            type: 'revenue_change',
                            revenue: 50,
                            on_phase: '5',
                            owner_type: 'player',
                          }],
              color: nil,
            },
          ]
        end

        # DGN GFN PHX KKN SPX
        def map_neus_game_corporations(corps)
          corps.each_with_index do |c, idx|
            c[:coordinates] = %w[B11 B5 C10 D9 B7][idx]
          end
          find_corp(corps, 'PHX')[:city] = 0
          find_corp(corps, 'KKN')[:city] = 0

          corps
        end

        def map_neus_game_cash
          { 2 => 850, 3 => 575, 4 => 430 }
        end

        def map_neus_game_cert_limit
          { 2 => 20, 3 => 13, 4 => 8 }
        end

        def map_neus_game_capitalization
          :full
        end

        def map_neus_game_market
          self.class::MARKET_2D
        end

        def map_neus_game_trains(trains)
          # don't use 8 trains
          trains.delete(find_train(trains, '8'))
          find_train(trains, '4')[:rusts_on] = 'D'
          # udpate quantities
          find_train(trains, '2')[:num] = 4
          find_train(trains, '3')[:num] = 3
          find_train(trains, '4')[:num] = 2
          find_train(trains, '5')[:num] = 2
          find_train(trains, '5')[:events] = [{ 'type' => 'close_companies' }]
          find_train(trains, '6')[:num] = 1
          find_train(trains, 'D')[:num] = 10
          trains
        end

        def map_neus_game_phases
          self.class::S18_FULLCAP_PHASES
        end

        def map_neus_post_game_phases(phases)
          phases[1][:status] = %w[can_buy_companies]
          phases[2][:status] = %w[can_buy_companies]
          phases
        end

        def map_neus_constants
          redef_const(:STATUS_TEXT, {
                        'can_buy_companies' =>
                        ['Can Buy Companies', 'All corporations can buy companies from players'],
                      })
        end

        def map_neus_init_round
          Engine::Round::Auction.new(self, [
            GSystem18::Step::UpwardsAuction,
          ])
        end
      end
    end
  end
end
