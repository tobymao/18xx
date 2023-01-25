# frozen_string_literal: true

require_relative 'meta'
require_relative 'step/special_track'
require_relative '../base'

module Engine
  module Game
    module G1889
      class Game < Game::Base
        include_meta(G1889::Meta)

        register_colors(black: '#37383a',
                        orange: '#f48221',
                        brightGreen: '#76a042',
                        red: '#d81e3e',
                        turquoise: '#00a993',
                        blue: '#0189d1',
                        brown: '#7b352a')

        CURRENCY_FORMAT_STR = '¥%s'

        BANK_CASH = 7000

        CERT_LIMIT = { 2 => 25, 3 => 19, 4 => 14, 5 => 12, 6 => 11 }.freeze

        STARTING_CASH = { 2 => 420, 3 => 420, 4 => 420, 5 => 390, 6 => 390 }.freeze

        CAPITALIZATION = :full

        MUST_SELL_IN_BLOCKS = true

        TILES = {
          '3' => 2,
          '5' => 2,
          '6' => 2,
          '7' => 2,
          '8' => 5,
          '9' => 5,
          '12' => 1,
          '13' => 1,
          '14' => 1,
          '15' => 3,
          '16' => 1,
          '19' => 1,
          '20' => 1,
          '23' => 2,
          '24' => 2,
          '25' => 1,
          '26' => 1,
          '27' => 1,
          '28' => 1,
          '29' => 1,
          '39' => 1,
          '40' => 1,
          '41' => 1,
          '42' => 1,
          '45' => 1,
          '46' => 1,
          '47' => 1,
          '57' => 2,
          '58' => 3,
          '205' => 1,
          '206' => 1,
          '437' => 1,
          '438' => 1,
          '439' => 1,
          '440' => 1,
          '448' => 4,
          '465' => 1,
          '466' => 1,
          '492' => 1,
          '611' => 2,
          'Beg6' => {
            'count' => 2,
            'color' => 'yellow',
            'code' => 'city=revenue:20;path=a:0,b:_0;path=a:2,b:_0',
          },
          'Beg7' => {
            'count' => 1,
            'color' => 'yellow',
            'code' => 'path=a:0,b:1',
          },
          'Beg8' => {
            'count' => 1,
            'color' => 'yellow',
            'code' => 'path=a:0,b:2',
          },
          'Beg9' => {
            'count' => 1,
            'color' => 'yellow',
            'code' => 'path=a:0,b:3',
          },
          'Beg23' => {
            'count' => 1,
            'color' => 'green',
            'code' => 'path=a:0,b:3;path=a:0,b:4',
          },
          'Beg24' => {
            'count' => 1,
            'color' => 'green',
            'code' => 'path=a:0,b:3;path=a:0,b:2',
          },
        }.freeze

        LOCATION_NAMES = {
          'F3' => 'Saijou',
          'G4' => 'Niihama',
          'H7' => 'Ikeda',
          'A10' => 'Sukumo',
          'J11' => 'Anan',
          'G12' => 'Nahari',
          'E2' => 'Matsuyama',
          'I2' => 'Marugame',
          'K8' => 'Tokushima',
          'C10' => 'Kubokawa',
          'J5' => 'Ritsurin Kouen',
          'G10' => 'Nangoku',
          'J9' => 'Komatsujima',
          'I12' => 'Muki',
          'B11' => 'Nakamura',
          'I4' => 'Kotohira',
          'C4' => 'Ohzu',
          'K4' => 'Takamatsu',
          'B7' => 'Uwajima',
          'B3' => 'Yawatahama',
          'G14' => 'Muroto',
          'F1' => 'Imabari',
          'J1' => 'Sakaide & Okayama',
          'L7' => 'Naruto & Awaji',
          'F9' => 'Kouchi',
        }.freeze

        MARKET = [
          %w[75 80 90 100p 110 125 140 155 175 200 225 255 285 315 350],
          %w[70 75 80 90p 100 110 125 140 155 175 200 225 255 285 315],
          %w[65 70 75 80p 90 100 110 125 140 155 175 200],
          %w[60 65 70 75p 80 90 100 110 125 140],
          %w[55 60 65 70p 75 80 90 100],
          %w[50y 55 60 65p 70 75 80],
          %w[45y 50y 55 60 65 70],
          %w[40y 45y 50y 55 60],
          %w[30o 40y 45y 50y],
          %w[20o 30o 40y 45y],
          %w[10o 20o 30o 40y],
        ].freeze

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
            tiles: %i[yellow green brown],
            operating_rounds: 3,
          },
        ].freeze

        TRAINS = [
          {
            name: '2',
            distance: 2,
            price: 80,
            rusts_on: '4',
            num: 6,
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
            price: 450,
            num: 3,
            events: [{ 'type' => 'close_companies' }],
          },
          { name: '6', distance: 6, price: 630, num: 2 },
          {
            name: 'D',
            distance: 999,
            price: 1100,
            num: 20,
            available_on: '6',
            discount: { '4' => 300, '5' => 300, '6' => 300 },
          },
].freeze

        COMPANIES = [
          {
            name: 'Takamatsu E-Railroad',
            value: 20,
            revenue: 5,
            desc: 'Blocks Takamatsu (K4) while owned by a player.',
            sym: 'TR',
            abilities: [{ type: 'blocks_hexes', owner_type: 'player', hexes: ['K4'] }],
            color: nil,
          },
          {
            name: 'Mitsubishi Ferry',
            value: 30,
            revenue: 5,
            desc: 'Player owner may place the port tile on a coastal town (B11,'\
                  ' G10, I12, or J9) without a tile on it already, outside of '\
                  'the operating rounds of a corporation controlled by another '\
                  'player. The player need not control a corporation or have '\
                  'connectivity to the placed tile from one of their '\
                  'corporations. This does not close the company.',
            sym: 'MF',
            abilities: [
              {
                type: 'tile_lay',
                when: %w[stock_round owning_player_track or_between_turns],
                hexes: %w[B11 G10 I12 J9],
                tiles: ['437'],
                owner_type: 'player',
                count: 1,
              },
            ],
            color: nil,
          },
          {
            name: 'Ehime Railway',
            value: 40,
            revenue: 10,
            desc: 'When this company is sold to a corporation, the selling '\
                  'player may immediately place a green tile on Ohzu (C4), '\
                  'in addition to any tile which it may lay during the same '\
                  'operating round. This does not close the company. Blocks '\
                  'C4 while owned by a player.',
            sym: 'ER',
            abilities: [{ type: 'blocks_hexes', owner_type: 'player', hexes: ['C4'] },
                        {
                          type: 'tile_lay',
                          hexes: ['C4'],
                          tiles: %w[12 13 14 15 205 206],
                          when: 'sold',
                          owner_type: 'corporation',
                          count: 1,
                        }],
            color: nil,
          },
          {
            name: 'Sumitomo Mines Railway',
            value: 50,
            revenue: 15,
            desc: 'Owning corporation may ignore building cost for mountain '\
                  'hexes which do not also contain rivers. This does not close '\
                  'the company.',
            sym: 'SMR',
            abilities: [
              {
                type: 'tile_discount',
                discount: 80,
                terrain: 'mountain',
                owner_type: 'corporation',
              },
            ],
            color: nil,
          },
          {
            name: 'Dougo Railway',
            value: 60,
            revenue: 15,
            desc: 'Owning player may exchange this private company for a 10% '\
                  'share of Iyo Railway from the initial offering.',
            sym: 'DR',
            abilities: [
              {
                type: 'exchange',
                corporations: ['IR'],
                owner_type: 'player',
                when: 'any',
                from: 'ipo',
              },
            ],
            color: nil,
          },
          {
            name: 'South Iyo Railway',
            value: 80,
            revenue: 20,
            desc: 'No special abilities.',
            sym: 'SIR',
            color: nil,
          },
          {
            name: 'Uno-Takamatsu Ferry',
            value: 150,
            revenue: 30,
            desc: 'Does not close while owned by a player. If owned by a player '\
                  'when the first 5-train is purchased it may no longer be sold '\
                  'to a public company and the revenue is increased to 50.',
            sym: 'UTF',
            min_players: 4,
            abilities: [{ type: 'close', on_phase: 'never', owner_type: 'player' },
                        {
                          type: 'revenue_change',
                          revenue: 50,
                          on_phase: '5',
                          owner_type: 'player',
                        }],
            color: nil,
          },
        ].freeze

        CORPORATIONS = [
          {
            float_percent: 50,
            sym: 'AR',
            name: 'Awa Railroad',
            logo: '1889/AR',
            simple_logo: '1889/AR.alt',
            tokens: [0, 40],
            coordinates: 'K8',
            color: '#37383a',
            reservation_color: nil,
          },
          {
            float_percent: 50,
            sym: 'IR',
            name: 'Iyo Railway',
            logo: '1889/IR',
            simple_logo: '1889/IR.alt',
            tokens: [0, 40],
            coordinates: 'E2',
            color: '#f48221',
            reservation_color: nil,
          },
          {
            float_percent: 50,
            sym: 'SR',
            name: 'Sanuki Railway',
            logo: '1889/SR',
            simple_logo: '1889/SR.alt',
            tokens: [0, 40],
            coordinates: 'I2',
            color: '#76a042',
            reservation_color: nil,
          },
          {
            float_percent: 50,
            sym: 'KO',
            name: 'Takamatsu & Kotohira Electric Railway',
            logo: '1889/KO',
            simple_logo: '1889/KO.alt',
            tokens: [0, 40],
            coordinates: 'K4',
            color: '#d81e3e',
            reservation_color: nil,
          },
          {
            float_percent: 50,
            sym: 'TR',
            name: 'Tosa Electric Railway',
            logo: '1889/TR',
            simple_logo: '1889/TR.alt',
            tokens: [0, 40, 40],
            coordinates: 'F9',
            color: '#00a993',
            reservation_color: nil,
          },
          {
            float_percent: 50,
            sym: 'KU',
            name: 'Tosa Kuroshio Railway',
            logo: '1889/KU',
            simple_logo: '1889/KU.alt',
            tokens: [0],
            coordinates: 'C10',
            color: '#0189d1',
            reservation_color: nil,
          },
          {
            float_percent: 50,
            sym: 'UR',
            name: 'Uwajima Railway',
            logo: '1889/UR',
            simple_logo: '1889/UR.alt',
            tokens: [0, 40, 40],
            coordinates: 'B7',
            color: '#6f533e',
            reservation_color: nil,
          },
        ].freeze

        HEXES = {
          white: {
            %w[D3 H3 J3 B5 C8 E8 I8 D9 I10] => '',
            %w[F3 G4 H7 A10 J11 G12 E2 I2 K8 C10] => 'city=revenue:0',
            ['J5'] => 'town=revenue:0',
            %w[B11 G10 I12 J9] => 'town=revenue:0;icon=image:port',
            ['K6'] => 'upgrade=cost:80,terrain:water',
            %w[H5 I6] => 'upgrade=cost:80,terrain:water|mountain',
            %w[E4 D5 F5 C6 E6 G6 D7 F7 A8 G8 B9 H9 H11 H13] => 'upgrade=cost:80,terrain:mountain',
            ['I4'] => 'city=revenue:0;label=H;upgrade=cost:80',
          },
          yellow: {
            ['C4'] => 'city=revenue:20;path=a:2,b:_0',
            ['K4'] => 'city=revenue:30;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;label=T',
          },
          gray: {
            ['B7'] => 'city=revenue:40,slots:2;path=a:1,b:_0;path=a:3,b:_0;path=a:5,b:_0',
            ['B3'] => 'town=revenue:20;path=a:0,b:_0;path=a:_0,b:5',
            ['G14'] => 'town=revenue:20;path=a:3,b:_0;path=a:_0,b:4',
            ['J7'] => 'path=a:1,b:5',
          },
          red: {
            ['F1'] => 'offboard=revenue:yellow_30|brown_60|diesel_100;path=a:0,b:_0;path=a:1,b:_0',
            ['J1'] => 'offboard=revenue:yellow_20|brown_40|diesel_80;path=a:0,b:_0;path=a:1,b:_0',
            ['L7'] => 'offboard=revenue:yellow_20|brown_40|diesel_80;path=a:1,b:_0;path=a:2,b:_0',
          },
          green: {
            ['F9'] => 'city=revenue:30,slots:2;path=a:2,b:_0;path=a:3,b:_0;'\
                      'path=a:4,b:_0;path=a:5,b:_0;label=K;upgrade=cost:80,terrain:water',
          },
        }.freeze

        LAYOUT = :flat

        EBUY_PRES_SWAP = false # allow presidential swaps of other corps when ebuying
        EBUY_OTHER_VALUE = false # allow ebuying other corp trains for up to face
        HOME_TOKEN_TIMING = :operating_round

        BEGINNER_GAME_PRIVATES = {
          2 => %w[DR SIR],
          3 => %w[DR SIR ER],
          4 => %w[DR SIR ER SMR],
          5 => %w[DR SIR ER SMR TR],
          6 => %w[DR SIR ER SMR TR MF],
        }.freeze

        BEGINNER_GAME_PRIVATE_REVENUES = {
          'TR' => 5,
          'MF' => 15,
          'ER' => 15,
          'SMR' => 20,
          'DR' => 20,
          'SIR' => 25,
        }.freeze

        BEGINNER_GAME_PRIVATE_VALUES = {
          'TR' => 20,
          'MF' => 40,
          'ER' => 40,
          'SMR' => 60,
          'DR' => 60,
          'SIR' => 90,
        }.freeze

        def setup
          remove_company(company_by_id('SIR')) if two_player? && !beginner_game?
          return unless beginner_game?

          neuter_private_companies
          close_unused_privates
          remove_blockers_and_icons

          # companies are randomly distributed to players and they buy their company
          @companies.sort_by! { rand }
          @players.zip(@companies).each { |p, c| buy_company(p, c) }
        end

        def operating_round(round_num)
          Round::Operating.new(self, [
            Engine::Step::Bankrupt,
            Engine::Step::Exchange,
            G1889::Step::SpecialTrack,
            Engine::Step::BuyCompany,
            Engine::Step::Track,
            Engine::Step::Token,
            Engine::Step::Route,
            Engine::Step::Dividend,
            Engine::Step::DiscardTrain,
            Engine::Step::BuyTrain,
            [Engine::Step::BuyCompany, { blocks: true }],
          ], round_num: round_num)
        end

        def init_round
          return super unless beginner_game?

          stock_round
        end

        def optional_tiles
          remove_beginner_tiles unless beginner_game?
        end

        def active_players
          return super if @finished

          company = company_by_id('ER')
          current_entity == company ? [@round.company_sellers[company]] : super
        end

        def beginner_game?
          @optional_rules.include?(:beginner_game)
        end

        def remove_beginner_tiles
          @tiles.reject! { |tile| tile.id.start_with?('Beg') }
          @all_tiles.reject! { |tile| tile.id.start_with?('Beg') }
        end

        def remove_blockers_and_icons
          %w[C4 K4 B11 G10 I12 J9].each do |coords|
            hex = hex_by_id(coords)
            hex.tile.blockers.reject! { true }
            hex.tile.icons.reject! { true }
          end
        end

        def neuter_private_companies
          @companies.each { |c| neuter_company(c) }
        end

        def neuter_company(company)
          company_abilities = company.abilities.dup
          company_abilities.each { |ability| company.remove_ability(ability) }
          company.desc = 'Closes when the first 5 train is bought. Cannot be purchased by a corporation'
          company.value = BEGINNER_GAME_PRIVATE_VALUES[company.sym]
          company.revenue = BEGINNER_GAME_PRIVATE_REVENUES[company.sym]
          company.add_ability(Ability::NoBuy.new(type: 'no_buy'))
        end

        def close_unused_privates
          companies_dup = @companies.dup
          companies_dup.each { |c| remove_company(c) unless BEGINNER_GAME_PRIVATES[@players.size].include?(c.sym) }
        end

        def remove_company(company)
          company.close!
          @round.active_step.companies.delete(company) unless beginner_game?
          @companies.delete(company)
        end

        def buy_company(player, company)
          price = company.value
          company.owner = player
          player.companies << company
          player.spend(price, @bank)
          @log << "#{player.name} buys #{company.name} for #{format_currency(price)}"
        end
      end
    end
  end
end
