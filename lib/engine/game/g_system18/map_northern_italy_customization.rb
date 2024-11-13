# frozen_string_literal: true

module Engine
  module Game
    module GSystem18
      module MapNorthernItalyCustomization
        NORTHERN_ITALY_REGION_HEXES = {
          'Piemonte' => %w[B3 B5 C4 D3 D5 E4],
          'Lombarida-Veneto' => %w[B7 B9 B11 C6 C8 C10 C12],
          'Emilia-Romagra' => %w[D7 D9 D11 E12],
          'Tuscana' => %w[E8 E10 F11],
        }.freeze

        NORTHERN_ITALY_CORP_REGIONS = {
          'SPX' => 'Emilia-Romagra',
          'PHX' => 'Piemonte',
          'GFN' => 'Lombarida-Veneto',
          'DGN' => 'Lombarida-Veneto',
          'KKN' => 'Tuscana',
        }.freeze

        def map_northern_italy_game_tiles(tiles)
          tiles.delete('12')
          tiles.delete('13')
          tiles.delete('205')
          tiles.delete('206')
          tiles['8'] = 4
          tiles.merge!({
                         'X1' =>
            {
              'count' => 1,
              'color' => 'gray',
              'code' => 'city=revenue:70,slots:2;path=a:0,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;'\
                        'path=a:5,b:_0;label=To',
            },
                         'X2' =>
            {
              'count' => 1,
              'color' => 'gray',
              'code' => 'city=revenue:90,slots:2;path=a:0,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;'\
                        'path=a:5,b:_0;label=Mi',
            },
                         'X3' =>
            {
              'count' => 1,
              'color' => 'gray',
              'code' => 'city=revenue:60,slots:2;path=a:0,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;'\
                        'path=a:5,b:_0;label=OO',
            },
                         '513' =>
            {
              'count' => 1,
              'color' => 'gray',
              'code' => 'city=revenue:60,slots:3;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;'\
                        'path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0',

            },
                         '895' =>
              {
                'count' => 1,
                'color' => 'gray',
                'code' => 'city=revenue:50,slots:2;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;'\
                          'path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0',
              },
                       })
        end

        def map_northern_italy_layout
          :pointy
        end

        def map_northern_italy_game_location_names
          {
            'A4' => 'Switzerland',
            'B7' => 'Bergamo',
            'B9' => '(Lombardia-Veneto)',
            'B11' => 'Trento & Vicenza',
            'B13' => 'Trieste',
            'C2' => 'France',
            'C4' => 'Torino',
            'C6' => 'Milano',
            'C8' => 'Brescia',
            'C10' => 'Verona',
            'C12' => 'Padova & Venezia',
            'D5' => 'Genova',
            'D7' => '(Emilia-Romagna)',
            'D9' => 'Parma & Modena',
            'D11' => 'Bologna',
            'E2' => 'France',
            'E4' => '(Piemonte)',
            'E8' => 'La Spezia & Livorno',
            'E10' => 'Firenze',
            'E12' => 'Ravenna & Rimini',
            'F9' => 'Roma',
            'F11' => '(Toscana)',
            'F13' => 'Ancona',
          }
        end

        # rubocop:disable Layout/LineLength
        def map_northern_italy_game_hexes
          {
            gray: {
              %w[A8] => 'junction;path=a:0,b:_0,terminal:1',
              %w[A10] => 'junction;path=a:5,b:_0,terminal:1',
              %w[D13] => 'path=a:0,b:1;path=a:1,b:2',
            },

            red: {
              %w[A4] => 'offboard=revenue:yellow_30|green_40|brown_50|gray_70,hide:1,groups:Switzerland;path=a:5,b:_0',
              %w[A6] => 'offboard=revenue:yellow_30|green_40|brown_50|gray_70,groups:Switzerland;path=a:5,b:_0;path=a:0,b:_0',
              %w[B13] => 'offboard=revenue:yellow_30|green_40|brown_50|gray_60;path=a:0,b:_0;path=a:1,b:_0',
              %w[C2] => 'offboard=revenue:yellow_30|green_40|brown_50|gray_70,groups:France;path=a:4,b:_0',
              %w[E2] => 'offboard=revenue:yellow_30|green_40|brown_50|gray_70,hide:1,groups:France;path=a:3,b:_0,terminal:1;path=a:4,b:_0',
              %w[F9] => 'offboard=revenue:yellow_30|green_50|brown_70|gray_100;path=a:2,b:_0;path=a:3,b:_0',
              %w[F13] => 'offboard=revenue:yellow_20|green_30|brown_40|gray_50;path=a:2,b:_0',
            },
            white: {
              %w[B3] => 'upgrade=cost:120,terrain:mountain',
              %w[B7 D5] => 'city=revenue:0;upgrade=cost:40,terrain:mountain',
              %w[B5] => 'upgrade=cost:40,terrain:mountain;border=type:province,color:red,edge:4',
              %w[B9 D3] => 'upgrade=cost:80,terrain:mountain',
              %w[B11] => 'town=revenue:0;town=revenue:0;upgrade=cost:40,terrain:mountain',
              %w[C8 C10] => 'city=revenue:0;upgrade=cost:20,terrain:water',
              %w[D7] => 'upgrade=cost:40,terrain:mountain;border=type:province,color:red,edge:1;border=type:province,color:red,edge:2;border=type:province,color:red,edge:3',
              %w[D9] => 'town=revenue:0;town=revenue:0;border=type:province,color:red,edge:2;border=type:province,color:red,edge:3;border=edge:0,type:mountain,cost:40;border=edge:5,type:mountain,cost:40',
              %w[D11] => 'city=revenue:0;upgrade=cost:20,terrain:water;border=type:province,color:red,edge:0;border=type:province,color:red,edge:2;border=edge:0,type:mountain,cost:40',
              %w[E4] => '',
              %w[E8] => 'town=revenue:0;town=revenue:0;border=type:province,color:red,edge:3;border=edge:3,type:mountain,cost:40;border=type:province,color:red,edge:2',
              %w[E6] => 'border=type:impassable,color:black,edge:1;border=type:province,color:red,edge:3;border=type:province,color:red,edge:4',
              %w[E10] => 'city=revenue:0;border=type:province,color:red,edge:2;border=edge:2,type:mountain,cost:40;border=type:province,color:red,edge:3;border=edge:3,type:mountain,cost:40;border=edge:4,type:mountain,cost:40',
              %w[E12] => 'town=revenue:0;town=revenue:0;border=type:province,color:red,edge:1;border=edge:1,type:mountain,cost:40',
              %w[F11] => 'upgrade=cost:40,terrain:mountain;border=type:province,color:red,edge:3',
            },
            yellow: {
              %w[C12] => 'city=revenue:30,loc:0;city=revenue:30,loc:2;path=a:1,b:_0;border=type:province,color:red,edge:0;border=type:province,color:red,edge:5;label=OO',
              %w[C6] => 'city=revenue:30;path=a:4,b:_0;border=type:province,color:red,edge:0;border=type:province,color:red,edge:2;future_label=label:Mi,color:gray;label=B',
              %w[C4] => 'city=revenue:30;path=a:5,b:_0;border=type:province,color:red,edge:4;future_label=label:To,color:gray;label=B',
            },
          }
        end
        # rubocop:enable Layout/LineLength

        def map_northern_italy_game_companies
          [
            {
              name: 'DGN Charter',
              sym: 'DGN',
              value: 0,
              revenue: 0,
              desc: 'Allows opening DGN corporation',
              color: '#50c878',
            },
            {
              name: 'GFN Charter',
              sym: 'GFN',
              value: 0,
              revenue: 0,
              desc: 'Allows opening GFN corporation',
              color: '#999999',
            },
            {
              name: 'PHX Charter',
              sym: 'PHX',
              value: 0,
              revenue: 0,
              desc: 'Allows opening PHX corporation',
              color: '#ff7518',
              text_color: 'black',
            },
            {
              name: 'KKN Charter',
              sym: 'KKN',
              value: 0,
              revenue: 0,
              desc: 'Allows opening KKN corporation',
              color: '#0096ff',
            },
            {
              name: 'SPX Charter',
              sym: 'SPX',
              value: 0,
              revenue: 0,
              desc: 'Allows opening SPX corporation',
              color: '#fafa33',
              text_color: 'black',
            },
          ]
        end

        # DGN GFN PHX KKN SPX
        def map_northern_italy_game_corporations(corps)
          corps.each_with_index do |c, idx|
            c[:float_percent] = 20
            c[:always_market_price] = true
            c[:coordinates] = %w[C6 C12 C4 E10 D11][idx]
            c[:city] = [nil, 0, nil, nil, nil][idx]
          end
          corps
        end

        def map_northern_italy_game_cash
          { 2 => 480, 3 => 320, 4 => 240 }
        end

        def map_northern_italy_game_cert_limit
          { 2 => 20, 3 => 13, 4 => 10 }
        end

        def map_northern_italy_game_capitalization
          :incremental
        end

        def map_northern_italy_half_dividend
          false
        end

        def map_northern_italy_share_price_for_dividend_change_as_full_cap
          true
        end

        def map_northern_italy_movement_type_at_emr_share_issue
          :down_share
        end

        def map_northern_italy_game_market
          self.class::MARKET_2D
        end

        def map_northern_italy_game_trains(trains)
          # rusting
          find_train(trains, '3')[:rusts_on] = '5'
          find_train(trains, '4')[:rusts_on] = '8'
          find_train(trains, '5')[:rusts_on] = 'D'
          # price
          find_train(trains, '5')[:price] = 450
          # discount
          find_train(trains, 'D')[:discount] = { '5' => 200, '6' => 200, '8' => 200 }
          # update quantities
          find_train(trains, '2')[:num] = 5
          find_train(trains, '3')[:num] = 4
          find_train(trains, '4')[:num] = 3
          find_train(trains, '5')[:num] = 2
          find_train(trains, '6')[:num] = 1
          find_train(trains, '8')[:num] = 1
          find_train(trains, 'D')[:num] = 10
          trains
        end

        def map_northern_italy_game_phases
          phases = Array.new(self.class::S18_INCCAP_PHASES)
          phases[0][:status] = ['local_tokens'] # 2
          phases[1][:status] = ['local_tokens'] # 3
          phases[2][:status] = ['local_tokens'] # 4

          phases << {
            name: 'D',
            on: 'D',
            train_limit: 2,
            tiles: %i[yellow green brown gray],
            operating_rounds: 2,
          }

          phases
        end

        def map_northern_italy_constants
          redef_const(:CURRENCY_FORMAT_STR, '$%s')
          redef_const(:STATUS_TEXT, { 'local_tokens' => ['Local Tokens', 'Can only token in home region'] })
          redef_const(:SELL_MOVEMENT, :down_share)
          redef_const(:SOLD_OUT_INCREASE, true)
        end

        def map_northern_italy_company_header(_company)
          'CHARTER'
        end

        def map_northern_italy_init_round
          map_northern_italy_new_parliament_round
        end

        def map_northern_italy_new_parliament_round
          @log << "-- Parliament Round #{@turn} -- "
          GSystem18::Round::Parliament.new(self, [
            GSystem18::Step::CharterAuction,
          ])
        end

        def map_northern_italy_next_round!
          @round =
            case @round
            when Engine::Round::Stock
              map_northern_italy_stock_round_finished
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
                map_northern_italy_new_parliament_round
              end
            else # Parliament Round
              init_round_finished
              new_stock_round
            end
        end

        # remove un-excersized charters from players
        def map_northern_italy_stock_round_finished
          @players.each do |player|
            player.companies.dup.each do |c|
              @log << "Right to open #{c.sym} lapses for #{player.name}"
              player.companies.delete(c)
              c.owner = nil
            end
          end
        end

        def map_northern_italy_can_par?(corporation, entity)
          !corporation.ipoed && entity.companies.find { |c| c.sym == corporation.name }
        end

        def map_northern_italy_after_par(corporation)
          entity = corporation.owner

          company = entity.companies.find { |c| c.sym == corporation.name }
          raise GameError, 'Logic error, no matching company found' unless company

          entity.companies.delete(company)
          company.close!
        end

        def map_northern_italy_tokener_check_connected(entity, _city, hex)
          return true if map_northern_italy_legal_token_hex?(entity, hex)

          region = NORTHERN_ITALY_CORP_REGIONS[entity&.name]
          raise GameError, "#{entity.name} can only place tokens in #{region} until phase 5"
        end

        def map_northern_italy_tokener_available_hex(entity, hex)
          map_northern_italy_legal_token_hex?(entity, hex)
        end

        def map_northern_italy_legal_token_hex?(entity, hex)
          return true unless @phase.name.to_i < 5
          return true if @phase.name == 'D'

          region = NORTHERN_ITALY_CORP_REGIONS[entity&.name]
          NORTHERN_ITALY_REGION_HEXES[region].include?(hex&.id)
        end

        def map_northern_italy_operating_steps
          [
            GSystem18::Step::Bankrupt,
            Engine::Step::Exchange,
            Engine::Step::SpecialTrack,
            Engine::Step::SpecialToken,
            Engine::Step::BuyCompany,
            Engine::Step::HomeToken,
            GSystem18::Step::Track,
            GSystem18::Step::Token,
            Engine::Step::Route,
            GSystem18::Step::Dividend,
            Engine::Step::DiscardTrain,
            GSystem18::Step::BuyTrain,
            GSystem18::Step::IssueShares,
          ]
        end

        # FIXME: add reopen! method to Engine::Company
        #
        # open company associated with closed corporation
        # def map_northern_italy_close_corporation_extra(corporation)
        #  company = companies.find { |c| c.sym == corporation.name }
        #  company.reopen!
        # end
      end
    end
  end
end
