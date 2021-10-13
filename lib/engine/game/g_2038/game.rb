# frozen_string_literal: true

require_relative 'meta'
require_relative '../base'

module Engine
  module Game
    module G2038
      class Game < Game::Base
        include_meta(G2038::Meta)

        register_colors(red: '#d1232a',
                        orange: '#f58121',
                        black: '#110a0c',
                        blue: '#ccdeee',
                        lightBlue: '#e0ebf4',
                        yellow: '#ffe600',
                        green: '#32763f',
                        brightGreen: '#6ec037')
        TRACK_RESTRICTION = :permissive
        SELL_BUY_ORDER = :sell_buy
        SELL_AFTER = :p_any_operate
        CURRENCY_FORMAT_STR = '$%d'

        LAYOUT = :pointy

        BANK_CASH = 10_000

        CERT_LIMIT = { 3 => 22, 4 => 16, 5 => 13, 6 => 11 }.freeze

        STARTING_CASH = { 3 => 600, 4 => 450, 5 => 360, 6 => 300 }.freeze

        HOME_TOKEN_TIMING = :never

        TILES = {
          '70' => 1,
        }.freeze

        LOCATION_NAMES = {
          'A1' => 'MM',
          'B6' => 'Torch',
          'D8' => 'RU',
          'D14' => 'Drill Hound',
          'F18' => 'RCC',
          'G7' => 'Fast Buck',
          'H14' => 'Lucky',
          'J2' => 'VP',
          'J18' => 'OCP',
          'K9' => 'TSI',
          'M5' => 'Ore Crusher',
          'M13' => 'Ice Finder',
          'O1' => 'LE',
        }.freeze

        MARKET = [
          %w[71 80 90 101 113 126 140 155 171 188 206 225 245 266 288 311 335 360 386 413 441 470 500],
          %w[62 70 79 89 100p 112 125x 139 154 170 187 205 224 244 265 287 310 334 359 385 412 440 469],
          %w[54 61 69 78 88p 99 111 124 138 153 169 186 204 223 243 264],
          %w[46 53 60 68 77p 87 98 110 123 137 152 168 185],
          %w[36 45 52 59 67p 76 86 97 109 122 136],
          %w[24 35 44 51 58 66 75 85 96],
          %w[10z 23 34 43 50 57 65],
        ].freeze

        MARKET_TEXT = Base::MARKET_TEXT.merge(
          par: 'Public Corps Par',
          par_1: 'Asteroid League Par',
          par_2: 'All Growth Corps Par',
        )

        STOCKMARKET_COLORS = Base::STOCKMARKET_COLORS.merge(
          par: :grey,
          par_1: :brown,
          par_2: :blue,
        )

        PHASES = [
          {
            name: '1',
            train_limit: 4,
            tiles: [:yellow],
            operating_rounds: 2,
          },
          {
            name: '2',
            on: '4dc3',
            train_limit: 4,
            tiles: %i[yellow green],
            operating_rounds: 2,
            status: ['can_buy_companies'],
          },
          {
            name: '3',
            on: '5dc4',
            train_limit: 3,
            tiles: %i[yellow green],
            operating_rounds: 2,
            status: ['can_buy_companies'],
          },
          {
            name: '4',
            on: '6d5c',
            train_limit: 3,
            tiles: %i[yellow green brown],
            operating_rounds: 2,
          },
          {
            name: '5',
            on: '7d6c',
            train_limit: 3,
            tiles: %i[yellow green brown],
            operating_rounds: 2,
          },
          {
            name: '6',
            on: '9d7c',
            train_limit: 2,
            tiles: %i[yellow green brown],
            operating_rounds: 2,
          },
        ].freeze

        TRAINS = [
          {
            name: 'probe',
            distance: 4,
            price: 1,
            rusts_on: %w[4dc3 6d2c],
            num: 1,
          },
          {
            name: '3dc2',
            distance: 3,
            price: 100,
            rusts_on: %w[5dc4 7d3c],
            num: 10,
            variants: [
              {
                name: '5dc1',
                rusts_on: %w[5dc4 7d3c],
                distance: 5,
                price: 100,
              },
            ],
          },
          {
            name: '4dc3',
            distance: 4,
            price: 200,
            rusts_on: %w[7d6c 9d5c],
            num: 10,
            variants: [
              {
                name: '6d2c',
                rusts_on: %w[7d6c 9d5c],
                distance: 6,
                price: 175,
              },
            ],
          },
          {
            name: '5dc4',
            distance: 5,
            price: 325,
            rusts_on: 'D',
            num: 6,
            variants: [
              {
                name: '7d3c',
                distance: 7,
                price: 275,
              },
            ],
            events: [{ 'type' => 'asteroid_league_can_form' }],
          },
          {
            name: '6d5c',
            distance: 6,
            price: 450,
            num: 5,
            variants: [
              {
                name: '8d4c',
                distance: 8,
                price: 400,
              },
            ],
            events: [{ 'type' => 'close_companies' }],
          },
          {
            name: '7d6c',
            distance: 7,
            price: 600,
            num: 2,
            variants: [
              {
                name: '9d5c',
                distance: 9,
                price: 550,
              },
            ],
          },
          {
            name: '9d7c',
            distance: 9,
            price: 950,
            num: 9,
            discount: {
              '5dc4' => 700,
              '7d3c' => 700,
              '6d5c' => 700,
              '8d4c' => 700,
              '7d6c' => 700,
              '9d5c' => 700,
            },
          },
        ].freeze

        COMPANIES = [
          {
            name: 'Planetary Imports',
            sym: 'PI',
            value: 50,
            revenue: 10,
            desc: 'No special abilities',
            color: nil,
          },
          {
            name: 'Fast Buck',
            sym: 'FB',
            value: 100,
            revenue: 0,
            desc: 'May form a Growth Corporation OR join the Asteroid League for 1 share.',
            abilities: [
              { type: 'no_buy' },
              {
                type: 'exchange',
                corporations: ['AL'],
                owner_type: 'player',
                from: 'market',
                when: ['Phase 3', 'Phase 4'],
              },
          ],
            color: 'white',
          },
          {
            name: 'Ice Finder',
            sym: 'IF',
            value: 100,
            revenue: 0,
            desc: 'May form a Growth Corporation OR join the Asteroid League for 1 share.',
            abilities: [
              { type: 'no_buy' },
              {
                type: 'exchange',
                corporations: ['AL'],
                owner_type: 'player',
                from: 'market',
                when: ['Phase 3', 'Phase 4'],
              },
          ],
            color: 'white',
          },
          {
            name: 'Drill Hound',
            sym: 'DH',
            value: 100,
            revenue: 0,
            desc: 'May form a Growth Corporation OR join the Asteroid League for 1 share.',
            abilities: [
              { type: 'no_buy' },
              {
                type: 'exchange',
                corporations: ['AL'],
                owner_type: 'player',
                from: 'market',
                when: ['Phase 3', 'Phase 4'],
              },
          ],
            color: 'white',
          },
          {
            name: 'Ore Crusher',
            sym: 'OC',
            value: 100,
            revenue: 0,
            desc: 'May form a Growth Corporation OR join the Asteroid League for 1 share.',
            abilities: [
              { type: 'no_buy' },
              {
                type: 'exchange',
                corporations: ['AL'],
                owner_type: 'player',
                from: 'market',
                when: ['Phase 3', 'Phase 4'],
              },
          ],
            color: 'white',
          },
          {
            name: 'Torch',
            sym: 'TT',
            value: 100,
            revenue: 0,
            desc: 'May form a Growth Corporation OR join the Asteroid League for 1 share.',
            abilities: [
              { type: 'no_buy' },
              {
                type: 'exchange',
                corporations: ['AL'],
                owner_type: 'player',
                from: 'market',
                when: ['Phase 3', 'Phase 4'],
              },
          ],
            color: 'white',
          },
          {
            name: 'Lucky',
            sym: 'LY',
            value: 100,
            revenue: 0,
            desc: 'May form a Growth Corporation OR join the Asteroid League for 1 share.',
            abilities: [
              { type: 'no_buy' },
              {
                type: 'exchange',
                corporations: ['AL'],
                owner_type: 'player',
                from: 'market',
                when: ['Phase 3', 'Phase 4'],
              },
          ],
            color: 'white',
          },
          {
            name: 'Tunnel Systems',
            sym: 'TS',
            value: 120,
            revenue: 5,
            desc: 'Buyer recieves a TSI Share.  If owned by a corporation, may place 1 free Base on ANY'\
                  ' explored and unclaimed tile.',
            abilities: [
              { type: 'shares', shares: 'TSI_3' },
              {
                type: 'tile_lay',
                owner_type: 'corporation',
                tiles: ['1'],
                when: 'owning_corp_or_turn',
                count: 1,
              },
            ],
            color: nil,
          },
          {
            name: 'Vacuum Associates',
            sym: 'VA',
            value: 140,
            revenue: 10,
            desc: 'Buyer recieves a TSI Share.  If owned by a corporation, may place 1 free'\
                  ' Refueling Station within range.',
            abilities: [
              { type: 'shares', shares: 'TSI_2' },
              {
                type: 'tile_lay',
                owner_type: 'corporation',
                tiles: ['2'],
                when: 'owning_corp_or_turn',
                count: 1,
              },
            ],
            color: nil,
          },
          {
            name: 'Robot Smelters, Inc.',
            sym: 'RS',
            value: 160,
            revenue: 15,
            desc: 'Buyer recieves a TSI Share.  If owned by a corporation, may place 1 free Claim within range.',
            abilities: [
              { type: 'shares', shares: 'TSI_1' },
              {
                type: 'tile_lay',
                owner_type: 'corporation',
                tiles: ['3'],
                when: 'owning_corp_or_turn',
                count: 1,
              },
            ],
            color: nil,
          },
          {
            name: 'Space Transportation Co.',
            sym: 'ST',
            value: 180,
            revenue: 20,
            desc: "Buyer recieves TSI president's Share and flies probe if TSI isn't active.  May not be owned"\
                  ' by a corporation. Remove from the game after TSI buys a spaceship.',
            abilities: [
              { type: 'shares', shares: 'TSI_0' },
              { type: 'no_buy' },
              { type: 'close', when: 'bought_train', corporation: 'TSI' },
            ],
            color: nil,
          },
          {
            name: 'Asteroid Export Co.',
            sym: 'AE',
            value: 180,
            revenue: 30,
            desc: "Forms Asteroid League, receiving its President's certificate.  May not be bought by a"\
                  ' corporation.  Remove from the game after AL aquires a spaceship.',
            abilities: [
              { type: 'close', when: 'bought_train', corporation: 'AL' },
              { type: 'no_buy' },
              {
                type: 'shares',
                shares: 'AL_0',
                when: ['Phase 3', 'Phase 4'],
              },
            ],
            color: nil,
          },
        ].freeze

        MINORS = [
          {
            sym: 'FB',
            name: 'Fast Buck',
            value: 100,
            coordinates: 'G7',
            logo: '18_eu/1',
            tokens: [60, 100],
            color: 'black',
            text_color: 'white',
            abilities: [
              {
                type: 'exchange',
                corporations: %w[RU VP MM LE OPC RCC AL],
                owner_type: 'player',
                from: 'ipo',
              },
            ],
          },
          {
            sym: 'IF',
            name: 'Ice Finder',
            value: 100,
            coordinates: 'G7',
            logo: '18_eu/2',
            tokens: [60, 100],
            color: 'black',
            text_color: 'white',
            abilities: [
              {
                type: 'exchange',
                corporations: %w[RU VP MM LE OPC RCC AL],
                owner_type: 'player',
                from: 'ipo',
              },
            ],
          },
          {
            sym: 'DH',
            name: 'Drill Hound',
            value: 100,
            coordinates: 'D14',
            logo: '18_eu/3',
            tokens: [60, 100],
            color: 'black',
            text_color: 'white',
            abilities: [
              {
                type: 'exchange',
                corporations: %w[RU VP MM LE OPC RCC AL],
                owner_type: 'player',
                from: 'ipo',
              },
            ],
          },
          {
            sym: 'OC',
            name: 'Ore Crusher',
            value: 100,
            coordinates: 'M5',
            logo: '18_eu/4',
            tokens: [60, 100],
            color: 'black',
            text_color: 'white',
            abilities: [
              {
                type: 'exchange',
                corporations: %w[RU VP MM LE OPC RCC AL],
                owner_type: 'player',
                from: 'ipo',
              },
            ],
          },
          {
            sym: 'TT',
            name: 'Torch',
            value: 100,
            coordinates: 'B6',
            logo: '18_eu/5',
            tokens: [60, 100],
            color: 'black',
            text_color: 'white',
            abilities: [
              {
                type: 'exchange',
                corporations: %w[RU VP MM LE OPC RCC AL],
                owner_type: 'player',
                from: 'ipo',
              },
            ],
          },
          {
            sym: 'LY',
            name: 'Lucky',
            value: 100,
            coordinates: 'H14',
            logo: '18_eu/6',
            tokens: [60, 100],
            color: 'black',
            text_color: 'white',
            abilities: [
              {
                type: 'exchange',
                corporations: %w[RU VP MM LE OPC RCC AL],
                owner_type: 'player',
                from: 'ipo',
              },
            ],
          },
        ].freeze

        CORPORATIONS = [
          {
            float_percent: 50,
            sym: 'TSI',
            name: 'Trans-Space Incorporated',
            logo: '18_chesapeake/PRR',
            simple_logo: '1830/PRR.alt',
            tokens: [60, 100, 60, 100, 60, 100, 60, 100, 60, 100],
            coordinates: 'K9',
            color: '#40b1b9',
            type: 'group_a',
            reservation_color: nil,
          },
          {
            float_percent: 50,
            sym: 'RU',
            name: 'Resources Unlimited',
            logo: '18_chesapeake/PRR',
            simple_logo: '1830/PRR.alt',
            tokens: [0, 100, 0, 100, 0, 100, 0, 100, 0, 100, 0, 100],
            coordinates: 'D8',
            color: '#d57e59',
            type: 'group_a',
            reservation_color: nil,
          },
          {
            float_percent: 50,
            sym: 'VP',
            name: 'Venus Prospectors Limited',
            logo: '1830/NYC',
            simple_logo: '1830/NYC.alt',
            tokens: [60, 100, 60, 100, 60],
            coordinates: 'J1',
            color: :'#3eb75b',
            type: 'group_b',
            reservation_color: nil,
          },
          {
            float_percent: 50,
            sym: 'LE',
            name: 'Lunar Enterprises',
            logo: '1830/CPR',
            simple_logo: '1830/CPR.alt',
            tokens: [60, 100, 60, 100, 60, 100, 60, 100, 60],
            coordinates: 'O1',
            color: '#fefc5d',
            type: 'group_b',
            reservation_color: nil,
          },
          {
            float_percent: 50,
            sym: 'MM',
            name: 'Mars Mining',
            logo: '18_chesapeake/BO',
            simple_logo: '1830/BO.alt',
            tokens: [60, 100, 60, 100, 60, 100],
            coordinates: 'A1',
            color: '#f66936',
            type: 'group_b',
            reservation_color: nil,
          },
          {
            float_percent: 50,
            sym: 'OPC',
            name: 'Outer Planet Consortium',
            logo: '18_chesapeake/CO',
            simple_logo: '1830/CO.alt',
            tokens: [60, 100, 60, 100, 60, 100, 60],
            coordinates: 'J18',
            color: :'#cc4f8c',
            text_color: 'black',
            type: 'group_c',
            reservation_color: nil,
          },
          {
            float_percent: 50,
            sym: 'RCC',
            name: 'Ring Construction Corporation',
            logo: '1846/ERIE',
            simple_logo: '1830/ERIE.alt',
            tokens: [60, 100, 60, 100, 60, 100, 60, 100],
            coordinates: 'F18',
            color: :'#f8b34b',
            text_color: 'black',
            type: 'group_c',
            reservation_color: nil,
          },
          {
            float_percent: 50,
            sym: 'AL',
            name: 'Asteroid League',
            logo: '1830/NYNH',
            simple_logo: '1830/NYNH.alt',
            tokens: [60, 75, 100, 60, 75, 100, 60, 75, 100, 60, 75, 100, 60, 75, 100],
            coordinates: 'H10',
            color: :'#fa3d58',
            type: 'groupD',
            reservation_color: nil,
          },
        ].freeze

        GAME_HEXES = {
          black: { %w[A13 D2 H10 H18 O11] => '' },
          gray: { %w[A1 B6 D8 D14 F18 G7 H14 J2 J18 K9 M5 M13 O1] => '' },
          blue: {
            %w[
                A3 A5 A7 A9 A11 B2 B4 B8 B10 B12 B14 C1 C3 C5 C7 C9
                C11 C13 C15 D4 D6 D10 D12 D16 E3 E5 E7 E9 E11 E13 E15
                E17 F2 F4 F6 F8 F10 F12 F14 F16 G3 G5 G9 G11 G13 G15
                G17 H4 H6 H8 H12 H16 I3 I5 I7 I9 I11 I13 I15 I17 J4
                J6 J8 J10 J12 J14 J16 K3 K5 K7 K11 K13 K15 K17 L2 L4
                L6 L8 L10 L12 L14 L16 M1 M3 M7 M9 M11 M15 N2 N4 N6 N8
                N10 N12 N14 O3 O5 O7 O9 O13
            ] => '',
          },
        }.freeze

        def game_hexes
          GAME_HEXES
        end

        EVENTS_TEXT = Base::EVENTS_TEXT.merge(
          'asteroid_league_can_form' => ['Asteroid League may be formed'],
          'group_b_corps_available' => ['Group B Corporations become available'],
          'group_c_corps_available' => ['Group C Corporations become available'],
        ).freeze

        def init_bank
          return super unless optional_short_game

          Engine::Bank.new(4_000, log: @log)
        end

        def new_auction_round
          Round::Auction.new(self, [
            Engine::Step::CompanyPendingPar,
            G2038::Step::WaterfallAuction,
          ])
        end

        def next_round!
          @round =
            case @round
            when Engine::Round::Stock
              @operating_rounds = @phase.operating_rounds
              reorder_players
              new_operating_round
            when Engine::Round::Operating
              if @round.round_num < @operating_rounds
                or_round_finished
                new_operating_round(@round.round_num + 1)
              else
                @turn += 1
                or_round_finished
                or_set_finished
                new_stock_round
              end
            when init_round.class
              init_round_finished
              reorder_players
              new_stock_round
            end
        end

        def setup
          @al_corporation = corporation_by_id('AL')
          @al_corporation.capitalization = :incremental

          @corporations.reject! { |c| c.id == 'AL' }

          return if optional_variant_start_pack

          @available_corp_group = :group_a

          @corporations, @b_group_corporations = @corporations.partition do |corporation|
            corporation.type == :group_a
          end

          @b_group_corporations, @c_group_corporations = @b_group_corporations.partition do |corporation|
            corporation.type == :group_b
          end
        end

        def event_group_b_corps_available!
          @log << 'Group B corporations are now available'

          @corporations.concat(@b_group_corporations)
          @b_group_corporations = []
          @available_corp_group = :group_b
        end

        def event_group_c_corps_available!
          @log << 'Group C corporations are now available'

          @corporations.concat(@c_group_corporations)
          @c_group_corporations = []
          @available_corp_group = :group_c
        end

        def event_asteroid_league_can_form!
          @log << 'Asteroid League may now be formed'
          @corporations << @al_corporation
        end

        def event_asteroid_league_formed!
          @log << 'Asteroid League has formed'
        end

        def company_header(company)
          is_minor = @minors.find { |m| m.id == company.id }

          if is_minor
            'INDEPENDENT COMPANY'
          else
            'PRIVATE COMPANY'
          end
        end

        def after_par(corporation)
          super

          return unless @corporations.all?(&:ipoed)

          case @available_corp_group
          when :group_a
            event_group_b_corps_available!
          when :group_b
            event_group_c_corps_available!
          end
        end

        def after_buy_company(player, company, _price)
          target_price = optional_short_game ? 67 : 100
          share_price = stock_market.par_prices.find { |pp| pp.price == target_price }

          # NOTE: This should only ever be TSI
          abilities(company, :shares) do |ability|
            ability.shares.each do |share|
              if share.president
                stock_market.set_par(share.corporation, share_price)
                share_pool.buy_shares(player, share, exchange: :free)
                after_par(share.corporation)
              else
                share_pool.buy_shares(player, share, exchange: :free)
              end
            end
          end
        end

        def optional_short_game
          @optional_rules&.include?(:optional_short_game)
        end

        def optional_variant_start_pack
          @optional_rules&.include?(:optional_variant_start_pack)
        end
      end
    end
  end
end
