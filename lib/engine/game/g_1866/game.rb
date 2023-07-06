# frozen_string_literal: true

require_relative 'meta'
require_relative 'entities'
require_relative 'map'
require_relative '../base'
require_relative '../../loan'
require_relative '../interest_on_loans'
require_relative '../cities_plus_towns_route_distance_str'

module Engine
  module Game
    module G1866
      class Game < Game::Base
        include_meta(G1866::Meta)
        include G1866::Entities
        include G1866::Map
        include InterestOnLoans
        include CitiesPlusTownsRouteDistanceStr

        GAME_END_CHECK = {
          stock_market: :current_round,
          stock_market_st: :three_rounds,
          final_phase: :three_rounds,
        }.freeze
        GAME_END_REASONS_TEXT = {
          stock_market: 'Corporation enters end game trigger on stock market',
          stock_market_st: 'Stock Turn Token enters end game trigger on stock market',
          final_phase: 'When the first 10/6E train is purchased',
        }.freeze
        GAME_END_REASONS_TIMING_TEXT = {
          three_rounds: 'Third OR after the current OR',
          current_round: 'End of the current OR',
        }.freeze

        BANKRUPTCY_ALLOWED = false
        CURRENCY_FORMAT_STR = '£%s'
        BANK_CASH = 99_999

        CAPITALIZATION = :incremental

        EBUY_CAN_SELL_SHARES = false
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
          %w[0c 10 20 30 40p 45p 50p 55p 60x 65x 70x 75x 80x 90x 100z 110z 120z 135z 150w 165w 180
             200 220 240 260 280 300 325 350 375 400 430 460e 490e 520e 560e 600e],
          %w[0c 10 20 30 40 45 50p 55p 60p 65p 70p 75p 80x 90x 100x 110x 120z 135z 150z 165w 180w
             200 220 240 260 280 300 325 350 375 400 430 460e 490e 520e 560e 600e],
          %w[0c 10 20 30 40 45 50 55 60p 65p 70p 75p 80p 90p 100p 110x 120x 135x 150z 165z 180w
             200w 220 240 260 280 300 325 350 375 400 430 460e 490e 520e 560e 600e],
          %w[0P 0P 0P 0P 0P 0P 0P 0P 0P 0P],
        ].freeze

        EVENTS_TEXT = {
          'green_ferries' => ['Green ferries', 'The green ferry lines opens up.'],
          'brown_ferries' => ['Brown ferries', 'The brown ferry lines opens up.'],
          'formation' => ['Formation', 'Forced formation of Major Nationals. Order of forming is: '\
                                       'Switzerland, Spain, Benelux, Austro-Hungarian Empire, Italy, France, '\
                                       'Germany, Great Britain.'],
          'infrastructure_h' => ['Transit Hub', 'The H, transit hub infrastructure, will be available for purchase. '\
                                                'The transit hub, gives one tokened city value to the treasury '\
                                                '(when included on a route).'],
          'infrastructure_p' => ['Palace Car', 'The P, palace car infrastructure, will be available for purchase. '\
                                               'The palace car counts 10 for each town for one train, paid to the treasury.'],
          'infrastructure_m' => ['Mail', 'The M, mail infrastructure, will be available for purchase. The mail, counts '\
                                         'the sum value of the start and end locations of a route to the treasury.'],
        }.freeze

        MARKET_TEXT = Base::MARKET_TEXT.merge(par_overlap: 'Minor nationals',
                                              par: 'Yellow phase (L/2) par',
                                              par_1: 'Green phase (3/4) par',
                                              par_2: 'Brown phase (5/6) par',
                                              par_3: 'Gray phase (8/10) par').freeze

        STATUS_TEXT = Base::STATUS_TEXT.merge(
          'can_buy_trains' => ['Buy trains', 'Can buy trains from other corporations'],
          'can_convert_corporation' => ['Convert Corporation', 'Corporations can convert from 5 shares to 10 shares.'],
          'can_convert_major' => ['Convert Major National', 'President of PRU and K2S can form Germany or Italy Major '\
                                                            'National.'],
        ).freeze

        STOCKMARKET_COLORS = Base::STOCKMARKET_COLORS.merge(par_overlap: :white,
                                                            par: :yellow,
                                                            par_1: :green,
                                                            par_2: :brown,
                                                            par_3: :gray,
                                                            close: :red).freeze

        PHASES = [
          {
            name: 'L/2',
            on: '',
            train_limit: { share_5: 4 },
            tiles: [:yellow],
            operating_rounds: 99,
          },
          {
            name: '3',
            on: '3',
            train_limit: { share_5: 3, share_10: 4 },
            tiles: %i[yellow green],
            operating_rounds: 99,
            status: %w[can_buy_trains can_convert_corporation can_convert_major],
          },
          {
            name: '4',
            on: '4',
            train_limit: { share_5: 3, share_10: 4 },
            tiles: %i[yellow green],
            operating_rounds: 99,
            status: %w[can_buy_trains can_convert_corporation can_convert_major],
          },
          {
            name: '5',
            on: '5',
            train_limit: { share_5: 2, share_10: 3 },
            tiles: %i[yellow green brown],
            operating_rounds: 99,
            status: %w[can_buy_trains can_convert_corporation],
          },
          {
            name: '6',
            on: '6',
            train_limit: { share_5: 2, share_10: 3 },
            tiles: %i[yellow green brown],
            operating_rounds: 99,
            status: %w[can_buy_trains can_convert_corporation],
          },
          {
            name: '8',
            on: '8',
            train_limit: { share_5: 1, share_10: 2 },
            tiles: %i[yellow green brown gray],
            operating_rounds: 99,
            status: %w[can_buy_trains can_convert_corporation],
          },
          {
            name: '10',
            on: '10',
            train_limit: { share_5: 1, share_10: 2 },
            tiles: %i[yellow green brown gray],
            operating_rounds: 99,
            status: %w[can_buy_trains can_convert_corporation],
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
            price: 50,
            rusts_on: '3',
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
                rusts_on: '4',
              },
            ],
            events: [
              {
                'type' => 'infrastructure_p',
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
            price: 200,
            rusts_on: '6',
            events: [
              {
                'type' => 'green_ferries',
              },
              {
                'type' => 'infrastructure_h',
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
            price: 300,
            rusts_on: '8',
            events: [
              {
                'type' => 'infrastructure_m',
              },
            ],
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
            price: 500,
            events: [
              {
                'type' => 'brown_ferries',
              },
              {
                'type' => 'formation',
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
            price: 0,
            reserved: true,
          },
          {
            name: 'P',
            distance: 99,
            price: 75,
          },
          {
            name: 'H',
            distance: 99,
            price: 140,
          },
          {
            name: 'M',
            distance: 99,
            price: 200,
          },
        ].freeze

        # *********** 1866 Specific constants ***********
        SCENARIO = {
          'full' => {
            'cert_limit' => {
              3 => 33,
              4 => 28,
              5 => 23,
              6 => 19,
            },
            'starting_cash' => {
              3 => 900,
              4 => 675,
              5 => 540,
              6 => 450,
            },
            'train_count' => {
              'L' => 20,
              '3' => 6,
              '4' => 5,
              '5' => 5,
              '6' => 3,
              '8' => 2,
              '10' => 20,
              'INF' => 18,
              'P' => 5,
              'H' => 5,
              'M' => 5,
            },
            'infrastructure_count' => 5,
            'companies' => %w[C1 C2 C3 C4 C5 C6 M1 M2 M3 M4 M5 M6 M7 M8 M9 M10 ST1 ST2 ST3 ST4 ST5 ST6],
            'corporations' => %w[LNWR GWR NBR PLM MIDI OU CPS KPS BY KHS SB BH KFN SSFL IFT SFAI SBB GL NRS ZPB MZA L],
            'national_corporations' => %w[GB FR AHE BNL ESP CH DE PRU HAN BAV WTB SAX IT K2S SAR LV PAP TUS],
            'corporation_count' => 13,
            'region_corporations' => {
              'GB' => %w[LNWR GWR NBR],
              'FR' => %w[PLM MIDI OU CPS],
              'AHE' => %w[SB BH KFN],
              'DE' => %w[KPS BY KHS],
              'IT' => %w[SSFL IFT SFAI],
            },
            'region_corporations_maxcount' => {
              'GB' => 3,
              'FR' => 3,
              'AHE' => 3,
              'DE' => 3,
              'IT' => 3,
            },
          },
          'nes' => {
            'cert_limit' => {
              3 => 28,
              4 => 21,
              5 => 17,
              6 => 14,
            },
            'starting_cash' => {
              3 => 800,
              4 => 600,
              5 => 480,
              6 => 400,
            },
            'train_count' => {
              'L' => 20,
              '3' => 4,
              '4' => 3,
              '5' => 3,
              '6' => 2,
              '8' => 2,
              '10' => 20,
              'INF' => 10,
              'P' => 3,
              'H' => 3,
              'M' => 3,
            },
            'infrastructure_count' => 3,
            'companies' => %w[C1 C2 C4 C6 M1 M2 M3 M4 M5 ST1 ST2 ST3 ST4 ST5 ST6],
            'corporations' => %w[LNWR GWR NBR PLM MIDI OU CPS KPS BY KHS SBB GL NRS L],
            'national_corporations' => %w[GB FR BNL CH DE PRU HAN BAV WTB SAX],
            'corporation_count' => 9,
            'region_corporations' => {
              'GB' => %w[LNWR GWR NBR],
              'FR' => %w[PLM MIDI OU CPS],
              'DE' => %w[KPS BY KHS],
              'BNL' => %w[GL NRS],
            },
            'region_corporations_maxcount' => {
              'GB' => 3,
              'FR' => 3,
              'DE' => 3,
            },
          },
          'ces' => {
            'cert_limit' => {
              3 => 28,
              4 => 21,
              5 => 17,
              6 => 14,
            },
            'starting_cash' => {
              3 => 800,
              4 => 600,
              5 => 480,
              6 => 400,
            },
            'train_count' => {
              'L' => 20,
              '3' => 4,
              '4' => 3,
              '5' => 3,
              '6' => 2,
              '8' => 2,
              '10' => 20,
              'INF' => 15,
              'P' => 3,
              'H' => 3,
              'M' => 3,
            },
            'infrastructure_count' => 3,
            'companies' => %w[C3 C4 C6 M1 M2 M3 M4 M5 M6 M7 M8 M9 M10 ST1 ST2 ST3 ST4 ST5 ST6],
            'corporations' => %w[KPS BY KHS SB BH KFN SSFL IFT SFAI SBB GL NRS],
            'national_corporations' => %w[AHE BNL CH DE PRU HAN BAV WTB SAX IT K2S SAR LV PAP TUS],
            'corporation_count' => 9,
            'region_corporations' => {
              'DE' => %w[KPS BY KHS],
              'AHE' => %w[SB BH KFN],
              'IT' => %w[SSFL IFT SFAI],
            },
            'region_corporations_maxcount' => {
              'AHE' => 3,
              'DE' => 3,
              'IT' => 3,
            },
          },
          'ses' => {
            'cert_limit' => {
              3 => 28,
              4 => 21,
              5 => 17,
              6 => 14,
            },
            'starting_cash' => {
              3 => 800,
              4 => 600,
              5 => 480,
              6 => 400,
            },
            'train_count' => {
              'L' => 20,
              '3' => 4,
              '4' => 3,
              '5' => 3,
              '6' => 2,
              '8' => 2,
              '10' => 20,
              'INF' => 10,
              'P' => 3,
              'H' => 3,
              'M' => 3,
            },
            'infrastructure_count' => 3,
            'companies' => %w[C2 C3 C5 C6 M6 M7 M8 M9 M10 ST1 ST2 ST3 ST4 ST5 ST6],
            'corporations' => %w[PLM MIDI OU CPS SB BH KFN SSFL IFT SFAI SBB ZPB MZA],
            'national_corporations' => %w[FR AHE ESP CH IT K2S SAR LV PAP TUS],
            'corporation_count' => 9,
            'region_corporations' => {
              'FR' => %w[PLM MIDI OU CPS],
              'ESP' => %w[ZPB MZA],
              'AHE' => %w[SB BH KFN],
              'IT' => %w[SSFL IFT SFAI],
            },
            'region_corporations_maxcount' => {
              'FR' => 3,
              'AHE' => 3,
              'IT' => 3,
            },
          },
        }.freeze

        C_TILE_UPGRADE = {
          'C1' => 'C7',
          'C2' => 'C8',
          'C3' => 'C9',
          'C4' => 'C10',
          'C5' => 'C11',
          'C6' => 'C12',
          'C7' => 'C13',
          'C8' => 'C14',
          'C9' => 'C15',
          'C10' => 'C16',
          'C11' => 'C17',
          'C12' => 'C18',
          'C13' => 'C19',
          'C14' => 'C20',
          'C15' => 'C21',
          'C16' => 'C22',
          'C17' => 'C23',
          'C18' => 'C24',
        }.freeze

        COMPANY_STARTING_BID = {
          'C1' => 10,
          'C2' => 10,
          'C3' => 10,
          'C4' => 10,
          'C5' => 10,
          'C6' => 10,
          'M1' => 80,
          'M2' => 60,
          'M3' => 60,
          'M4' => 60,
          'M5' => 60,
          'M6' => 80,
          'M7' => 60,
          'M8' => 60,
          'M9' => 60,
          'M10' => 30,
        }.freeze

        COMPANY_SHORT_NAME = {
          'C1' => 'GB',
          'C2' => 'FR',
          'C3' => 'AHE',
          'C4' => 'BNL',
          'C5' => 'ESP',
          'C6' => 'CH',
          'M1' => 'G1-PRU',
          'M2' => 'G2-HAN',
          'M3' => 'G3-BAV',
          'M4' => 'G4-WTB',
          'M5' => 'G5-SAX',
          'M6' => 'I1-K2S',
          'M7' => 'I2-SAR',
          'M8' => 'I3-LV',
          'M9' => 'I4-PAP',
          'M10' => 'I5-TUS',
        }.freeze

        CORPORATIONS_OPERATING_RIGHTS = {
          'LNWR' => 'GB',
          'GWR' => 'GB',
          'NBR' => 'GB',
          'PLM' => 'FR',
          'MIDI' => 'FR',
          'OU' => 'FR',
          'CPS' => 'FR',
          'KPS' => %w[DE PRU],
          'BY' => %w[DE BAV],
          'KHS' => %w[DE HAN],
          'SB' => 'AHE',
          'BH' => 'AHE',
          'KFN' => 'AHE',
          'SSFL' => %w[IT TUS],
          'IFT' => %w[IT K2S],
          'SFAI' => %w[IT LV],
          'SBB' => 'CH',
          'GL' => 'BNL',
          'NRS' => 'BNL',
          'ZPB' => 'ESP',
          'MZA' => 'ESP',
        }.freeze

        DOUBLE_HEX = %w[G15 G19 J12 J18 K5].freeze
        E_TRAINS = %w[3E 4E 5E 6E].freeze

        ENTITY_STATUS_TEXT = {
          'DE' => 'Converted by PRU president or force convert in phase 5',
          'IT' => 'Converted by K2S president or force convert in phase 5',
          'PRU' => 'Min bid 80 | Converted to a German share',
          'HAN' => 'Min bid 60 | Converted to a German share',
          'BAV' => 'Min bid 60 | Converted to a German share',
          'WTB' => 'Min bid 60 | Converted to a German share',
          'SAX' => 'Min bid 60 | Converted to a German share',
          'K2S' => 'Min bid 80 | Converted to a Italian share',
          'SAR' => 'Min bid 60 | Converted to a Italian share',
          'LV' => 'Min bid 60 | Converted to a Italian share',
          'PAP' => 'Min bid 60 | Converted to a Italian share',
          'TUS' => 'Min bid 30 | Converted to a Italian share',
        }.freeze

        FERRY_TILE_G7 = 'border=edge:2,type:impassable;border=edge:4,type:impassable;path=a:1,b:5'
        FERRY_TILE_S25 = 'border=edge:0,type:impassable;path=a:1,b:2'
        FERRY_TILE_F8 = 'border=edge:1,type:impassable;border=edge:5,type:impassable;path=a:2,b:4'
        FERRY_TILE_H4 = 'border=edge:3,type:impassable;border=edge:5,type:impassable;path=a:0,b:2'

        GERMANY_NATIONAL = 'DE'
        ITALY_NATIONAL = 'IT'

        INFRASTRUCTURE_TRAINS = %w[H P M].freeze
        INFRASTRUCTURE_HUB = 'H'
        INFRASTRUCTURE_PALACE = 'P'
        INFRASTRUCTURE_MAIL = 'M'

        LOCAL_TRAIN = 'L'

        LONDON_HEX = 'F6'
        LONDON_TILE = 'L1'

        MINOR_COMPANIES = %w[M1 M2 M3 M4 M5 M6 M7 M8 M9 M10].freeze
        MINOR_COMPANY_CORPORATION = {
          'M1' => 'PRU',
          'M2' => 'HAN',
          'M3' => 'BAV',
          'M4' => 'WTB',
          'M5' => 'SAX',
          'M6' => 'K2S',
          'M7' => 'SAR',
          'M8' => 'LV',
          'M9' => 'PAP',
          'M10' => 'TUS',
        }.freeze
        MINOR_GERMANY_COMPANIES = %w[M1 M2 M3 M4 M5].freeze
        MINOR_ITALY_COMPANIES = %w[M6 M7 M8 M9 M10].freeze
        MINOR_NATIONAL_PAR_ROWS = {
          'PRU' => [3, 0],
          'HAN' => [3, 1],
          'BAV' => [3, 2],
          'WTB' => [3, 3],
          'SAX' => [3, 4],
          'K2S' => [3, 5],
          'SAR' => [3, 6],
          'LV' => [3, 7],
          'PAP' => [3, 8],
          'TUS' => [3, 9],
        }.freeze

        NATIONAL_MARKET_SHARE_LIMIT = 90
        NATIONAL_COMPANIES = %w[C1 C2 C3 C4 C5 C6].freeze
        NATIONAL_REGION_HEXES = {
          'PRU' => %w[E23 E25 F20 F22 F24 F26 G15 G17 G19 G21 G23 G25 H14 H16 H18 H24 H26 I25],
          'HAN' => %w[D18 E15 E17 E19 E21 F16 F18],
          'BAV' => %w[I17 I19 J16 J18 J20 K17 K19 K21],
          'WTB' => %w[I13 I15 J14 K15],
          'SAX' => %w[H20 H22 I21 I23],
          'K2S' => %w[S21 S23 T20 T22 T24 U21 V18 V20 W19],
          'SAR' => %w[N12 O13 O15 P14 Q15 R14 S13 T12],
          'LV' => %w[M17 N14 N16 N18 N20 O17 P18],
          'PAP' => %w[Q19 R18 R20 S19],
          'TUS' => %w[P16 Q17],
          'AHE' => %w[J22 J24 J26 K23 K25 L18 L20 L22 L24 L26 M19 M21 M23 M25 N22 N24 N26 O21 O23 O25
                      P22 P24 P26 Q23 Q25 R24 S25],
          'BNL' => %w[E13 F8 F10 F12 F14 G9 G11 G13 H10 H12 I11],
          'FR' => %w[G7 H4 H8 I1 I3 I5 I7 I9 J0 J2 J4 J6 J8 J10 J12 K1 K3 K5 K7 K9 K11 K13 L2 L4 L6 L8 L10
                     M3 M5 M7 M9 M11 N2 N4 N6 N8 N10 O3 O5 O7 O9 O11 P6 P8 P10 P12 Q13 R12],
          'GB' => %w[A3 B2 B4 C3 C5 D2 D4 D6 E1 E3 E5 E7 F2 F4 F6 F8 G1 G3 G5 G7 H4],
          'ESP' => %w[O1 P0 P2 P4 Q1 Q3 Q5 R0 R2 R4 S1 S3 T0 T2 U1],
          'CH' => %w[L12 L14 L16 M13 M15],
          'DE' => %w[E23 E25 F20 F22 F24 F26 G15 G17 G19 G21 G23 G25 H14 H16 H18 H24 H26 I25 D18 E15 E17
                     E19 E21 F16 F18 I17 I19 J16 J18 J20 K17 K19 K21 I13 I15 J14 K15 H20 H22 I21 I23],
          'IT' => %w[R12 S21 S23 S25 T20 T22 T24 U21 V18 V20 W19 N12 O13 O15 P14 Q15 R14 S13 S15 S17 T12 T14 T16 T18 M17
                     N14 N16 N18 N20 O17 P18 Q19 R18 R20 S19 P16 Q17],
        }.freeze

        NATIONAL_PREPRINTED_TILES = %w[AHE DE ESP].freeze

        MINOR_NATIONAL_TILE_LAYS = [{ lay: true, upgrade: true, cost: 0 }].freeze
        NATIONAL_TILE_LAYS = [
          { lay: true, upgrade: true, cost: 0 },
          { lay: :not_if_upgraded, upgrade: false, cost: 0 },
        ].freeze
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

        SHARE_PRICE_SUFFIX = ['T', 'M', 'B', ''].freeze

        STOCK_TURN_TOKEN_PREFIX = 'ST'

        attr_reader :scenario, :game_end_triggered_corporation, :game_end_triggered_round,
                    :major_national_formed, :major_national_formed_round, :player_sold_shares

        def action_processed(_action); end

        def bank_sort(corporations)
          return super unless @round.operating?

          corporations.reject { |c| minor_national_corporation?(c) }.sort_by(&:name)
        end

        def can_par?(corporation, parrer)
          return false if corporation.id == self.class::GERMANY_NATIONAL && corporation_by_id('PRU').owner != parrer
          return false if corporation.id == self.class::ITALY_NATIONAL && corporation_by_id('K2S').owner != parrer

          super
        end

        def can_run_route?(entity)
          national_corporation?(entity) || entity.trains.any? { |t| local_train?(t) } || super
        end

        def check_connected(route, corporation)
          return if national_corporation?(corporation)

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

        def company_header(company)
          if self.class::NATIONAL_COMPANIES.include?(company.id)
            'CONCESSION'
          elsif self.class::MINOR_COMPANIES.include?(company.id)
            'MINOR'
          else
            'PRIVATE COMPANY'
          end
        end

        def compute_other_paths(routes, route)
          routes.flat_map do |r|
            next if r == route || train_type(route.train) != train_type(r.train)

            r.paths
          end
        end

        def corporation_show_loans?(corporation)
          corporation?(corporation)
        end

        def crowded_corps
          @crowded_corps ||= corporations.select do |c|
            trains = c.trains.count { |t| !t.obsolete && !infrastructure_train?(t) }
            trains > train_limit(c) && !national_corporation?(c)
          end
        end

        def emergency_issuable_bundles(entity)
          min_price = @depot.min_depot_price
          if !entity.corporation? || !corporation?(entity) || !trains_empty?(entity) || entity.num_ipo_shares.zero? ||
            entity.cash >= min_price || game_end_corporation_operated?(entity)
            return []
          end

          remaining = min_price - entity.cash
          bundles_for_corporation(entity, entity).select do |bundle|
            max_shares = (remaining / bundle.price_per_share).ceil
            @share_pool.fit_in_bank?(bundle) && bundle.num_shares <= max_shares
          end
        end

        def end_game!(player_initiated: false)
          return if @finished

          @corporations.each do |corporation|
            next if !corporation?(corporation) || corporation.loans.size.zero?

            game_end_loan = corporation.loans.size * loan_value * 2
            corporation_cash = corporation.cash - game_end_loan
            loan_str = "#{corporation.name} loans double in value (#{format_currency(game_end_loan)})."
            if corporation_cash.negative?
              player = corporation.owner
              @log << "#{loan_str} #{corporation.name} pays #{format_currency(corporation.cash)}, and #{player.name}"\
                      " have to contribute #{format_currency(corporation_cash.abs)}"
              player_spend(player, corporation_cash.abs)
              corporation.spend(corporation.cash, @bank) if corporation.cash.positive?
            else
              @log << "#{loan_str} #{corporation.name} pays #{format_currency(game_end_loan)}"
              corporation.spend(game_end_loan, @bank)
            end
            corporation.loans.clear
          end
          super
        end

        def end_now?(after)
          return false unless after
          return true if after == :current_round

          @round.round_num == @final_round
        end

        def entity_can_use_company?(entity, company)
          entity == company.owner
        end

        def float_str(_entity)
          ''
        end

        def game_cert_limit
          @scenario['cert_limit']
        end

        def game_companies
          companies = @scenario['companies']
          self.class::COMPANIES.select { |c| companies.include?(c[:sym]) }
        end

        def game_corporations
          corporations = @scenario['corporations'] + @scenario['national_corporations']
          self.class::CORPORATIONS.select { |c| corporations.include?(c[:sym]) }
        end

        def game_end_check
          @corp_max_reached ||= @corporations.any? do |c|
            reached = corporation?(c) && c.floated? && c.share_price.end_game_trigger?
            @game_end_triggered_corporation ||= c if reached
            reached
          end
          @st_max_reached ||= @stock_turn_token_in_play.values.flatten.any? do |c|
            reached = !c.closed? && c.share_price.end_game_trigger?
            @game_end_triggered_corporation ||= c if reached
            reached
          end
          phase_trigger = @phase.phases.last == @phase.current
          @game_end_triggered_corporation ||= @round.active_entities[0] if phase_trigger

          triggers = {
            stock_market: @corp_max_reached,
            stock_market_st: @st_max_reached,
            final_phase: phase_trigger,
          }.select { |_, t| t }

          %i[three_rounds current_round].each do |after|
            triggers.keys.each do |reason|
              next unless game_end_check_values[reason] == after

              game_end_triggered = game_end_triggered?
              @final_round ||= @round.round_num + (after == :three_rounds ? 3 : 0)
              @game_end_triggered_round ||= @round.round_num
              @game_end_three_rounds ||= after == :three_rounds
              update_stock_turn_token_names if game_end_triggered != game_end_triggered?
              return [reason, after]
            end
          end

          nil
        end

        def game_ending_description
          reason, after = game_end_check
          return unless after

          after_text = ''
          unless @finished
            after_text = case after
                         when :current_round
                           " : Game Ends at conclusion of this OR (#{@round.round_num})"
                         when :three_rounds
                           " : Game Ends at conclusion of #{round_end.short_name} #{@final_round}"
                         end
          end

          reason_map = {
            stock_market: 'Corporation hit end game triggered stock value',
            stock_market_st: 'Stock Turn Token hit end game triggered stock value',
            final_phase: 'A 10/6E train was bought and triggered end game',
          }
          "#{reason_map[reason]}#{after_text}"
        end

        def graph_for_entity(entity)
          national_corporation?(entity) ? @national_graph : @graph
        end

        def graph_skip_paths(entity)
          skip_paths = {}
          @hexes.each do |hex|
            add_skip_paths = (national_corporation?(entity) && !hex_within_national_region?(entity, hex)) ||
              (corporation?(entity) && !hex_operating_rights?(entity, hex))
            hex.tile.paths.each { |path| skip_paths[path] = true } if add_skip_paths
          end
          skip_paths.empty? ? nil : skip_paths
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

        def init_loans
          @loan_value = 100

          # 13 corporations * 10 loans
          Array.new(130) { |id| Loan.new(id, @loan_value) }
        end

        def init_optional_rules(optional_rules)
          opt_rules = super
          @scenario = init_scenario(opt_rules)
          opt_rules
        end

        def init_share_pool
          G1866::SharePool.new(self)
        end

        def init_starting_cash(players, bank)
          cash = @scenario['starting_cash'][players.size]
          players.each do |player|
            bank.spend(cash, player)
          end
        end

        def init_stock_market
          G1866::StockMarket.new(game_market, self.class::CERT_LIMIT_TYPES,
                                 multiple_buy_types: self.class::MULTIPLE_BUY_TYPES)
        end

        def interest_rate
          20
        end

        def ipo_name(_entity)
          'Treasury'
        end

        def ipo_reserved_name(_entity = nil)
          'Reserved'
        end

        def issuable_shares(entity)
          return [] if !entity.corporation? || !corporation?(entity) || entity.num_ipo_shares.zero?

          bundles_for_corporation(entity, entity).select { |bundle| @share_pool.fit_in_bank?(bundle) }
        end

        def local_length
          99
        end

        def loan_value(_entity = nil)
          @loan_value
        end

        def maximum_loans(entity)
          entity.total_shares
        end

        def must_buy_train?(entity)
          entity.trains.none? { |t| !infrastructure_train?(t) } && !depot.depot_trains.empty?
        end

        def next_round!
          @round =
            case @round
            when G1866::Round::Operating
              or_round_finished
              new_operating_round(@round.round_num + 1)
            when Engine::Round::Auction
              @operating_rounds = @phase.operating_rounds
              new_operating_round
            end
          update_stock_turn_token_names
        end

        def new_auction_round
          Engine::Round::Auction.new(self, [
            G1866::Step::SingleItemAuction,
          ])
        end

        def num_certs(entity)
          # All players have a Stock Turn Company, this shouldnt count towards the cert limit.
          super - 1
        end

        def num_trains(train)
          @scenario['train_count'][train[:name]]
        end

        def operating_order
          floated = @corporations.select(&:floated?)
          minor_nationals, corporations = floated.partition { |c| minor_national_corporation?(c) }

          minor_nationals + (corporations + @stock_turn_token_in_play.values.flatten).sort
        end

        def operating_round(round_num)
          initialize_sold_shares
          @current_turn = "OR#{round_num}"
          @turn = round_num
          G1866::Round::Operating.new(self, [
            G1866::Step::StockTurnToken,
            Engine::Step::HomeToken,
            G1866::Step::FirstTurnHousekeeping,
            G1866::Step::Convert,
            G1866::Step::Track,
            G1866::Step::Token,
            G1866::Step::Route,
            G1866::Step::Dividend,
            G1866::Step::DiscardTrain,
            G1866::Step::BuyTrain,
            G1866::Step::BuyInfrastructure,
            G1866::Step::LoanInterestPayment,
            G1866::Step::LoanRepayment,
            G1866::Step::IssueShares,
            G1866::Step::CloseCorporation,
          ], round_num: round_num)
        end

        def or_round_finished
          # Export all L/2 trains at the end of OR2
          @depot.export_all!(self.class::LOCAL_TRAIN) if @round.round_num == 2 && local_train?(@depot.upcoming.first)
          stock_turn_token_remove!
        end

        def par_price_str(share_price)
          "#{format_currency(share_price.price)}#{share_price_suffix(share_price)}"
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

        def player_value(player)
          player.value - @player_debts[player]
        end

        def price_movement_chart
          [
            ['Market Action', 'Movement'],
            ['ST action pass', '2 →'],
            ['ST action sell or buy', '1 →'],
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

        def redeemable_shares(entity)
          return [] if !entity.corporation? || !corporation?(entity) || @player_sold_shares[entity.owner][entity]

          bundles_for_corporation(share_pool, entity)
            .reject { |bundle| bundle.shares.size > 1 || entity.cash < bundle.price }
        end

        def reservation_corporations
          @corporations.reject { |c| national_corporation?(c) }
        end

        def revenue_for(route, stops)
          route.hexes.group_by(&:itself).each do |k, v|
            next if v.size < 2 || self.class::DOUBLE_HEX.include?(k.name)

            raise GameError, "Route visits same hex #{k.name} twice"
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
          revenue
        end

        def revenue_str(route)
          rev_str = super
          rev_str += ' (Obsolete)' if route.train.obsolete
          rev_str
        end

        def round_description(name, round_number = nil)
          round_number ||= @round.round_num
          "#{name} Round #{round_number}"
        end

        def routes_subsidy(routes)
          return 0 if routes.empty?

          entity = routes.first.train.owner
          subsidy = 0
          subsidy += port_token_bonus(entity, routes)&.sum { |v| v[:subsidy] } || 0
          subsidy += infrastructure_bonus(entity, routes).sum { |v| v[:subsidy] }
          subsidy
        end

        def route_trains(entity)
          entity.runnable_trains.reject { |t| infrastructure_train?(t) }
        end

        def sell_shares_and_change_price(bundle, allow_president_change: true, swap: nil, movement: nil)
          corporation = bundle.corporation
          before_share_price = corporation.share_price
          was_president = corporation.president?(bundle.owner) || bundle.owner == corporation
          @share_pool.sell_shares(bundle, allow_president_change: allow_president_change, swap: swap)
          if was_president
            bundle.num_shares.times { @stock_market.move_left(corporation) }
          else
            bundle.num_shares.times { @stock_market.move_down(corporation) }
          end
          log_share_price_row(corporation, before_share_price)
        end

        def setup
          @stock_turn_token_count = {}
          @stock_turn_token_in_play = {}
          @stock_turn_token_number = {}
          @stock_turn_token_remove = []
          @player_setup_order = @players.dup
          @player_setup_order.each_with_index do |player, index|
            @log << "#{player.name} have stock turn tokens with number #{index + 1}"
            @stock_turn_token_count[player] = starting_stock_turn_tokens
            @stock_turn_token_in_play[player] = []
            @stock_turn_token_number[player] = 0
          end

          # Initialize the player depts, if player have to take an emergency loan
          @player_debts = Hash.new { |h, k| h[k] = 0 }

          @london_reservation_entity = corporation_by_id('L')
          @corporations.delete(@london_reservation_entity)

          @current_turn = 'ISR'

          @major_national_formed = {}
          @major_national_formed[self.class::GERMANY_NATIONAL] = false
          @major_national_formed[self.class::ITALY_NATIONAL] = false
          @major_national_formed_round = {}

          # Setup the nationals graph
          @national_graph = Graph.new(self, home_as_token: true, no_blocking: true)

          # Setup the nationals infinite trains
          @scenario['national_corporations'].each_with_index do |national, index|
            train = train_by_id("INF-#{index}")
            @depot.remove_train(train)
            train.buyable = false
            train.instance_variable_set(:@local, true)

            corporation = corporation_by_id(national)
            train.owner = corporation
            corporation.trains << train

            # Before Italy is formed AHE can access the Lombardy-Venetia region
            corporation.coordinates.concat(corporation_by_id('LV').coordinates) if national == 'AHE'
          end

          # Setup the infrastructure depot
          @depot_infrastructures = []
          @infrastructure_trains_h = []
          @infrastructure_trains_p = []
          @infrastructure_trains_m = []
          @scenario['infrastructure_count'].times.each do |index|
            h_train = train_by_id("H-#{index}")
            @infrastructure_trains_h << h_train

            p_train = train_by_id("P-#{index}")
            @infrastructure_trains_p << p_train

            m_train = train_by_id("M-#{index}")
            @infrastructure_trains_m << m_train
          end

          # Randomize and setup the corporations
          setup_corporations

          # Set up the national shares
          setup_nationals

          # Give all players stock turn token and remove unused
          setup_stock_turn_token

          # Initialize the sold shares variables
          initialize_sold_shares

          @final_round = nil
          @game_end_three_rounds = nil
          @game_end_triggered_corporation = nil
          @game_end_triggered_round = nil
        end

        def setup_preround
          # Make sure the start player order is randomized
          @players.sort_by! { rand }
        end

        def sorted_corporations
          ipoed, others = @corporations.reject { |c| minor_national_corporation?(c) }.partition(&:ipoed)

          # Remove Germany and Italy if we cant form them
          others.reject! { |c| germany_or_italy_national?(c) } unless convert_major_national?

          ipoed.sort + others
        end

        def status_array(corporation)
          return if !corporation?(corporation) || !corporation.floated?

          status = []
          status << ["#{corporation.type == :share_5 ? '5' : '10'}-share corporation", 'bold']
          status << ['Can not redeem', 'bold'] if @player_sold_shares[corporation.owner][corporation]
          if game_end_triggered?
            status << if game_end_corporation_operated?(corporation)
                        ['No share actions', 'bold']
                      else
                        ['Last share actions', 'bold']
                      end
          end
          status
        end

        def status_str(corporation)
          return if corporation.floated?

          self.class::ENTITY_STATUS_TEXT[corporation.id]
        end

        def tile_lays(entity)
          return self.class::MINOR_NATIONAL_TILE_LAYS if minor_national_corporation?(entity)
          return self.class::NATIONAL_TILE_LAYS if major_national_corporation?(entity)

          self.class::TILE_LAYS
        end

        def timeline
          [
            'OR2: When OR2 is complete all remaining L/2 are exported.',
            'Minor nationals tile lay: 1 yellow or 1 upgrade. No costs involved.',
            'Nationals tile lay: 2 yellow or 1 upgrade. No costs involved.',
            "Corporations tile lay: 4 tracks, first is free, second cost #{format_currency(10)}, "\
            "third cost #{format_currency(20)} and fourth cost #{format_currency(30)}. "\
            "With a total of #{format_currency(60)} if all four is used.",
            'Corporations tile lay phase 3 & 4: 4 tracks, max 1 upgrade. Can be done in any order.',
            'Corporations tile lay phase 5 & 6: 4 tracks, max 2 upgrades. Can be done in any order. Can upgrade the '\
            'same tile.',
            'Corporations tile lay phase 8: 4 tracks, max 3 upgrades. Can be done in any order. Can upgrade the same '\
            'tile.',
            'Corporations tile lay phase 10: 4 tracks, max 4 upgrades. Can be done in any order. Can upgrade the same '\
            'tile.',
          ]
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

          if corporation?(entity) && @phase.current[:name] != 'L/2'
            help << 'When a port city is used as a terminus in a run it pays the port bonus to the treasury. '\
                    'Each port token can be only used once in an OR'
          end

          if entity.trains.any? { |t| t.name == self.class::INFRASTRUCTURE_HUB }
            help << 'The H, transit hub, gives one tokened city value to the treasury (when included on a route)'
          end
          if entity.trains.any? { |t| t.name == self.class::INFRASTRUCTURE_PALACE }
            help << 'The P, palace car, counts 10 for each city for one train, paid to the treasury'
          end
          if entity.trains.any? { |t| t.name == self.class::INFRASTRUCTURE_MAIL }
            help << 'The M, mail, counts the sum value of the start and end tokened city value of a route '\
                    'to the treasury'
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

          # C-tiles
          return C_TILE_UPGRADE[from.name] == to.name if from.label.to_s == 'C' && %i[yellow green brown].include?(from.color)

          super
        end

        def all_corporation_token_rights(player)
          player.shares_by_corporation.each { |c, _| corporation_token_rights!(c) if corporation?(c) && c.president?(player) }
        end

        def after_lay_tile(corporation)
          @graph.clear if national_corporation?(corporation)
          @national_graph.clear if corporation?(corporation)
        end

        def add_new_share(share)
          owner = share.owner
          corporation = share.corporation
          corporation.share_holders[owner] += share.percent if owner
          owner.shares_by_corporation[corporation] << share
          @_shares[share.id] = share
        end

        def buy_infrastructure(entity, train)
          take_loan(entity) while entity.cash < train.price
          entity.spend(train.price, @bank)
          @depot_infrastructures.delete(train)
          @depot.remove_train(train)
          train.owner = entity
          entity.trains << train

          @log << "#{entity.name} buys a #{train.name} infrastructure for #{format_currency(train.price)}"
        end

        def buyable_infrastructure
          @depot_infrastructures.uniq(&:name)
        end

        def buying_power_with_loans(entity)
          loans = maximum_loans(entity) - entity.loans.size
          entity.cash + (loans * loan_value(entity))
        end

        def can_par_share_price?(share_price, corporation)
          return share_price.corporations.empty? unless corporation

          share_price.corporations.none? { |c| c.type != :stock_turn_corporation }
        end

        def can_take_loan?(entity)
          entity.corporation? && entity.loans.size < maximum_loans(entity)
        end

        def convert_corporation?
          @phase.status.include?('can_convert_corporation')
        end

        def convert_major_national?
          @phase.status.include?('can_convert_major')
        end

        def corporation?(corporation)
          return false unless corporation

          corporation.type == :share_5 || corporation.type == :share_10
        end

        def corporation_closes(corporation)
          @log << "#{corporation.name} have share price of #{format_currency(0)}, and will close"

          if corporation.loans.size.positive?
            loan = corporation.loans.size * loan_value
            @log << "The bank settles #{corporation.name} loans of value #{format_currency(loan)}"
            corporation.loans.dup.each do |l|
              corporation.loans.delete(l)
              @loans << l
            end
          end

          tokens = []
          corporation.tokens.each do |token|
            next unless token.used

            if token.price.zero?
              tokens << token
            else
              token.remove!
            end
          end
          corporation.close!
          corporation = reset_corporation(corporation)
          tokens.each do |token|
            city = token.city
            token.remove!
            city.place_token(corporation, corporation&.next_token, free: true, check_tokenable: false)
          end
        end

        def corporation_token_rights!(corporation)
          return if !corporation?(corporation) || !corporation.floated?

          corporation.placed_tokens.dup.each do |token|
            next if hex_operating_rights?(corporation, token.hex)

            next_token = corporation.placed_tokens.last
            @log << "#{corporation.name} doesn't have operations right to the hex #{token.hex.name}, it's token "\
                    ' comes back to the charter'
            token.remove!
            next if token == next_token

            price = token.price
            token.price = next_token.price
            next_token.price = price
            corporation.tokens.sort_by!(&:price)
          end
        end

        def event_brown_ferries!
          @log << '-- Event: Brown Ferries --'

          update_ferry_hex('F8', self.class::FERRY_TILE_F8, [{ hex: 'E7', edge: 5 }, { hex: 'F10', edge: 1 }])
          update_ferry_hex('H4', self.class::FERRY_TILE_H4, [{ hex: 'G3', edge: 5 }, { hex: 'I3', edge: 3 }])
        end

        def event_formation!
          @log << '-- Event: Forced formation of Major Nationals --'

          # Order: Switzerland, Spain, Benelux, Austro-Hungarian Empire, Italy, France, Germany, Great Britain
          forced_formation_national(corporation_by_id('CH'))
          forced_formation_national(corporation_by_id('ESP'))
          forced_formation_national(corporation_by_id('BNL'))
          forced_formation_national(corporation_by_id('AHE'))
          forced_formation_major(corporation_by_id(self.class::ITALY_NATIONAL), %w[K2S SAR LV PAP TUS])
          forced_formation_national(corporation_by_id('FR'))
          forced_formation_major(corporation_by_id(self.class::GERMANY_NATIONAL), %w[PRU HAN BAV WTB SAX])
          forced_formation_national(corporation_by_id('GB'))

          @graph.clear
          @round.check_operating_order!
        end

        def event_green_ferries!
          @log << '-- Event: Green Ferries --'

          update_ferry_hex('G7', self.class::FERRY_TILE_G7, [{ hex: 'G5', edge: 4 }, { hex: 'H8', edge: 2 }])
          update_ferry_hex('S25', self.class::FERRY_TILE_S25, [{ hex: 'R24', edge: 5 }, { hex: 'S23', edge: 4 }])
        end

        def event_infrastructure_h!
          @log << '-- Event: The H, transit hub infrastructure, will be available for purchase --'

          @depot_infrastructures.concat(@infrastructure_trains_h)
        end

        def event_infrastructure_m!
          @log << '-- Event: The M, mail infrastructure, will be available for purchase --'

          @depot_infrastructures.concat(@infrastructure_trains_m)
        end

        def event_infrastructure_p!
          @log << '-- Event: The P, palace car infrastructure, will be available for purchase --'

          @depot_infrastructures.concat(@infrastructure_trains_p)
        end

        def forced_formation_major(corporation, minors)
          return if !corporation || @major_national_formed[corporation.id]

          share_price = forced_formation_par_prices(corporation).last
          @stock_market.set_par(corporation, share_price)
          @log << "#{corporation.name} #{ipo_verb(corporation)} at #{format_currency(share_price.price)}"

          # Find the share holders to give a share, then close the minor
          minor_corporations = []
          minors.each do |m|
            minor_corporations << corporation_by_id(m)
          end

          minor_corporations.group_by(&:owner).each do |player, player_minors|
            player_minors.each do |minor|
              @share_pool.transfer_shares(corporation.ipo_shares.first.to_bundle, player) if player

              close_corporation(minor)
            end
          end

          # Move the rest of the shares into the market
          corporation_shares = corporation.shares_of(corporation).select(&:buyable)
          @share_pool.transfer_shares(ShareBundle.new(corporation_shares), @share_pool) unless corporation_shares.empty?

          corporation.ipoed = true
          @major_national_formed[corporation.id] = true
          @major_national_formed_round[corporation.id] = @round.round_num
          return unless corporation.id == self.class::ITALY_NATIONAL

          # Remove the coordinates for AHE in Lombardy-Venetia region
          minor_lv = corporation_by_id('LV')
          corporation_by_id('AHE').coordinates.reject! { |coordinate| minor_lv.coordinates.include?(coordinate) }

          # Check if any of the AH corporations have tokened in Lombardy-Venetia
          @scenario['region_corporations']['AHE'].each { |c| corporation_token_rights!(corporation_by_id(c)) }
        end

        def forced_formation_national(corporation)
          return if !corporation || corporation.floated?

          # Set the correct par price
          share_price = forced_formation_par_prices(corporation).last
          @stock_market.set_par(corporation, share_price)

          # Find the president and give player the share, and spend the money. The player can go into debt
          player = corporation.par_via_exchange.owner
          share = corporation.ipo_shares.first
          @log << "#{corporation.name} #{ipo_verb(corporation)} at #{format_currency(share_price.price)}"
          if player
            @share_pool.transfer_shares(share.to_bundle, player, price: 0)
            player_spend(player, share_price.price)
          end
          corporation.ipoed = true

          # Move the rest of the shares into the market
          @share_pool.transfer_shares(ShareBundle.new(corporation.shares_of(corporation).select(&:buyable)), @share_pool)

          # Close the concession
          corporation.par_via_exchange.close!
        end

        def forced_formation_par_prices(corporation)
          par_type = phase_par_type
          par_prices_sorted.select do |p|
            p.types.include?(par_type) && can_par_share_price?(p, corporation)
          end
        end

        def hex_is_port?(hex)
          hex.tile.icons.any? { |i| i.name == 'port' }
        end

        def game_end_corporation_operated(corporarion)
          @game_end_corporation_operated[corporarion] = true
        end

        def game_end_corporation_operated?(corporarion)
          return false unless game_end_triggered?

          @game_end_corporation_operated[corporarion] || false
        end

        def game_end_triggered?
          !@final_round.nil?
        end

        def game_end_triggered_last_round?
          game_end_triggered? && @game_end_three_rounds && @final_round == @round.round_num
        end

        def hex_operating_rights?(entity, hex)
          nationals = operating_rights(entity)
          nationals.any? { |national| national_hexes(national).include?(hex.name) }
        end

        def hex_within_national_region?(entity, hex)
          national_hexes(entity.id).include?(hex.name)
        end

        def infrastructure_bonus(entity, routes)
          transit_hubs = entity.trains.any? { |t| t.name == self.class::INFRASTRUCTURE_HUB }
          palace_cars = entity.trains.any? { |t| t.name == self.class::INFRASTRUCTURE_PALACE }
          mail_contracts = entity.trains.any? { |t| t.name == self.class::INFRASTRUCTURE_MAIL }
          return [] if !transit_hubs && !palace_cars && !mail_contracts

          transit_hub_bonus = []
          palace_car_bonus = []
          mail_contract_bonus = []
          routes.each do |route|
            stops = route.visited_stops
            phase = route.phase
            train = route.train
            train_multiplier = train.obsolete ? 0.5 : 1

            # Transit hub & palace_car
            transist_hub_revenue = 0
            palace_car_revenue = 0
            stops.each do |stop|
              next unless stop

              palace_car_revenue += 10 if stop.town?
              next if !stop.city? || !stop.tokened_by?(entity)

              stop_base_revenue = stop.route_base_revenue(phase, train)
              transist_hub_revenue = stop_base_revenue if stop_base_revenue > transist_hub_revenue
            end
            transit_hub_bonus << { route: route, subsidy: transist_hub_revenue * train_multiplier }
            palace_car_bonus << { route: route, subsidy: palace_car_revenue * train_multiplier }

            # Mail contract
            mail_first_stop = stops.first
            mail_last_stop = stops.last
            first_stop_revenue = if mail_first_stop.city? && mail_first_stop.tokened_by?(entity)
                                   mail_first_stop.route_base_revenue(phase, train)
                                 else
                                   0
                                 end
            last_last_revenue = if stops.size > 1 && mail_first_stop != mail_last_stop && mail_last_stop.city? &&
                                  mail_last_stop.tokened_by?(entity)
                                  mail_last_stop.route_base_revenue(phase, train)
                                else
                                  0
                                end
            mail_contract_bonus << { route: route, subsidy: (first_stop_revenue + last_last_revenue) * train_multiplier }
          end

          infrastructure_bonus = []
          infrastructure_bonus << transit_hub_bonus.sort_by { |v| v[:subsidy] }.reverse[0] if transit_hubs
          infrastructure_bonus << palace_car_bonus.sort_by { |v| v[:subsidy] }.reverse[0] if palace_cars
          infrastructure_bonus << mail_contract_bonus.sort_by { |v| v[:subsidy] }.reverse[0] if mail_contracts
          infrastructure_bonus
        end

        def infrastructure_limit(corporation)
          corporation.type == :share_5 ? 1 : 2
        end

        def infrastructure_train?(train)
          self.class::INFRASTRUCTURE_TRAINS.include?(train.name)
        end

        def init_scenario(optional_rules)
          scenario_name = 'full'
          scenario_name = 'nes' if optional_rules.include?(:nes)
          scenario_name = 'ces' if optional_rules.include?(:ces)
          scenario_name = 'ses' if optional_rules.include?(:ses)

          self.class::SCENARIO[scenario_name]
        end

        def initialize_sold_shares
          @player_sold_shares = Hash.new { |h, k| h[k] = Hash.new { |h2, k2| h2[k2] = false } }
        end

        def interest_owed(entity)
          interest_owed_for_loans(entity.loans.size)
        end

        def interest_owed_for_loans(loans)
          interest_rate * loans
        end

        def local_train?(train)
          self.class::LOCAL_TRAIN == train.name
        end

        def loans_due_interest(entity)
          entity&.loans&.size || 0
        end

        def log_share_price_row(entity, from_share_price)
          from_suffix = share_price_suffix(from_share_price)
          to_suffix = share_price_suffix(entity.share_price)
          from_price = from_share_price.price
          to_price = entity.share_price.price
          return if from_price == to_price && from_suffix == to_suffix

          from = "#{format_currency(from_price)}#{from_suffix == to_suffix ? '' : from_suffix}"
          to = "#{format_currency(to_price)}#{from_suffix == to_suffix ? '' : to_suffix}"
          @log << "#{entity.name}'s share price changes from #{from} to #{to}"
        end

        def germany_or_italy_national?(corporation)
          return false unless corporation

          corporation.id == self.class::GERMANY_NATIONAL || corporation.id == self.class::ITALY_NATIONAL
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

        def national_hexes(corporation_id)
          hexes = self.class::NATIONAL_REGION_HEXES[corporation_id].dup
          # Special case for AHE
          if corporation_id == 'AHE' && !@major_national_formed[self.class::ITALY_NATIONAL]
            hexes.concat(self.class::NATIONAL_REGION_HEXES['LV'])
          end
          hexes
        end

        def national_upgraded?(corporation)
          return true if self.class::NATIONAL_PREPRINTED_TILES.include?(corporation.id)

          hexes = national_hexes(corporation.id)
          hexes.any? do |h|
            hex = hex_by_id(h)
            next unless hex.tile.cities.size.positive?

            hex.tile != hex.original_tile
          end
        end

        def operating_rights(entity)
          player = entity.owner
          national_shares = player.shares_by_corporation.select { |c, s| national_corporation?(c) && !s.empty? }

          rights = self.class::CORPORATIONS_OPERATING_RIGHTS[entity.id]
          corporation_rights = rights.is_a?(Array) ? rights.dup : [rights]
          unless @major_national_formed[self.class::GERMANY_NATIONAL]
            corporation_rights.reject! { |o| o == self.class::GERMANY_NATIONAL }
          end
          unless @major_national_formed[self.class::ITALY_NATIONAL]
            corporation_rights.reject! { |o| o == self.class::ITALY_NATIONAL }
          end

          (national_shares.keys.map(&:id) + corporation_rights).uniq
        end

        def par_prices_sorted
          @stock_market.par_prices.sort_by do |p|
            r, = p.coordinates
            [p.price, -r]
          end.reverse
        end

        def payoff_loan(entity, loan)
          raise GameError, "Loan doesn't belong to that entity" unless entity.loans.include?(loan)

          amount = loan.amount
          @log << "#{entity.name} pays off a loan for #{format_currency(amount)}"
          entity.spend(amount, @bank)

          entity.loans.delete(loan)
          @loans << loan

          before_share_price = entity.share_price
          @stock_market.move_up(entity)
          log_share_price_row(entity, before_share_price)
        end

        def payoff_player_loan(player)
          if player.cash >= @player_debts[player]
            player.cash -= @player_debts[player]
            @log << "#{player.name} pays off their loan of #{format_currency(@player_debts[player])}"
            @player_debts[player] = 0
          else
            @player_debts[player] -= player.cash
            @log << "#{player.name} decreases their loan by #{format_currency(player.cash)} "\
                    "(#{format_currency(@player_debts[player])})"
            player.cash = 0
          end
        end

        def port_token_bonus(entity, routes)
          # Find all the port hexes and see which route pays the most
          port_hexes = {}
          routes.each do |route|
            train = route.train
            stops = route.visited_stops
            train_multiplier = train.obsolete ? 0.5 : 1

            ptb = [stops.first]
            ptb << stops.last unless stops.first == stops.last
            ptb.each do |stop|
              next if !stop || !stop.city? || !stop.tokened_by?(entity) || !hex_is_port?(stop.hex)

              revenue = self.class::PORT_TOKEN_BONUS[route.phase.name] * train_multiplier
              if !port_hexes[stop.hex] || revenue > port_hexes[stop.hex][:revenue]
                port_hexes[stop.hex] = { route: route, revenue: revenue }
              end
            end
          end

          port_hexes.map do |_, r|
            next unless r[:revenue].positive?

            { route: r[:route], subsidy: r[:revenue] }
          end.compact
        end

        def phase_par_type
          self.class::PHASE_PAR_TYPES[@phase.name]
        end

        def place_starting_token(corporation, token, hex_coordinates)
          hex = hex_by_id(hex_coordinates)
          city = hex.tile.cities.first
          city.place_token(corporation, token, free: true, check_tokenable: false)
        end

        def player_debt(player)
          @player_debts[player] || 0
        end

        def player_loan_interest(loan)
          loan
        end

        def player_spend(player, cash)
          # Check if player needs a loan
          remaining = (player.cash.positive? ? player.cash : 0) - cash
          if remaining.negative?
            remaining = remaining.abs
            take_player_loan(player, remaining)
            @log << "#{player.name} takes a loan of #{format_currency(remaining)} with "\
                    "#{format_currency(player_loan_interest(remaining))} in interest"
          end

          # Spend the money
          player.spend(cash, @bank, check_cash: false)
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
            color: 'white',
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
          @log << "#{player.name} buys a stock turn token at #{format_currency(share_price.price)}"

          @stock_turn_token_in_play[player] << corporation
          @stock_turn_token_number[player] += 1
          @stock_turn_token_count[player] -= 1
        end

        def setup_corporations
          # Randomize from preset seed to get same order
          corps = @corporations.select { |c| c.type == :share_5 }.sort_by { rand }
          removed_corporations = []

          # Select one of the three corporations based in each of GB, France, A-H, Germany & Italy
          starting_corps = []
          germany_italy = [self.class::GERMANY_NATIONAL, self.class::ITALY_NATIONAL]
          region_corporation_count = Hash.new { |h, k| h[k] = 0 }
          @scenario['region_corporations'].each do |_, v|
            corp = corps.find { |c| v.include?(c.name) }

            rights = self.class::CORPORATIONS_OPERATING_RIGHTS[corp.id]
            corporation_rights = rights.is_a?(Array) ? rights.find { |r| germany_italy.include?(r) } : rights
            region_corporation_count[corporation_rights] += 1

            starting_corps << corp
            corps.delete(corp)
          end

          # Include the next 8 corporations in the game
          corps_count = @scenario['corporation_count'] - @scenario['region_corporations'].size
          corps.each_with_index do |c, index|
            if index < corps_count
              rights = self.class::CORPORATIONS_OPERATING_RIGHTS[c.id]
              corporation_rights = rights.is_a?(Array) ? rights.find { |r| germany_italy.include?(r) } : rights
              region_max = @scenario['region_corporations_maxcount'][corporation_rights] || 99
              if region_corporation_count[corporation_rights] < region_max
                starting_corps << c
                region_corporation_count[corporation_rights] += 1
              else
                removed_corporations << c
                @corporations.delete(c)
                corps_count += 1
              end
            else
              removed_corporations << c
              @corporations.delete(c)
            end
          end

          # Put down the home tokens of all the starting corporations
          starting_corps.each do |corp|
            Array(corp.coordinates).each do |coord|
              place_starting_token(corp, corp.find_token_by_type, coord)
            end
          end

          # Put down the home tokens of all the removed corporations
          removed_corporations.each do |corp|
            Array(corp.coordinates).each do |coord|
              token = Engine::Token.new(corp, logo: "/logos/1866/#{corp.name}_REMOVED.svg",
                                              simple_logo: "/logos/1866/#{corp.name}_REMOVED.svg",
                                              type: :removed)

              place_starting_token(corp, token, coord)
            end
            @log << "#{corp.name} - #{corp.full_name} is removed from the game"
          end

          @game_end_corporation_operated = Hash.new { |h, k| h[k] = false }
        end

        def setup_nationals
          @corporations.each do |corporation|
            next unless major_national_corporation?(corporation)

            corporation.shares.each { |share| share.buyable = false if share.index > 4 }
          end
        end

        def sell_stock_turn_token(corporation)
          player = corporation.owner
          price = corporation.share_price.price
          @bank.spend(price, player)
          @log << "#{player.name} sells a stock turn token at #{format_currency(price)}"

          corporation.share_holders.keys.each do |share_holder|
            share_holder.shares_by_corporation.delete(corporation)
          end
          @share_pool.shares_by_corporation.delete(corporation)
          corporation.share_price&.corporations&.delete(corporation)

          @stock_turn_token_in_play[player].delete(corporation)
          @stock_turn_token_remove << corporation
        end

        def setup_stock_turn_token
          # Give each player a stock turn company
          @players.each_with_index do |player, index|
            company = @companies.find { |c| c.id == "#{self.class::STOCK_TURN_TOKEN_PREFIX}#{index + 1}" }
            company.owner = player
            stock_turn_token_name!(company)
            player.companies << company
          end

          # Remove the unused stock turn companies
          @companies.dup.each do |company|
            next if !stock_turn_token_company?(company) || company.owner

            @companies.delete(company)
          end
        end

        def share_price_suffix(share_price)
          row, = share_price.coordinates
          self.class::SHARE_PRICE_SUFFIX[row]
        end

        def starting_stock_turn_tokens
          player_size = @players.size
          case player_size
          when 3
            5
          when 4
            4
          when 5, 6
            3
          end
        end

        def stock_turn_corporation?(corporation)
          return false unless corporation

          corporation.type == :stock_turn_corporation
        end

        def stock_turn_token_company?(company)
          company.id[0..1] == self.class::STOCK_TURN_TOKEN_PREFIX
        end

        def stock_turn_token?(player)
          @stock_turn_token_count[player].positive?
        end

        def stock_turn_token_name!(company)
          player = company.owner
          name = if game_end_triggered?
                   'ST token (ENDGAME)'
                 else
                   "ST token (#{@stock_turn_token_count[player]})"
                 end

          company.name = name
          company.desc = if @round.operating?
                           'Buy/Sell a stock turn token, it enters play as already operated. T = Top row, M = Middle '\
                             'row and B = Bottom row.'
                         else
                           'Buy a stock turn token. T = Top row, M = Middle row and B = Bottom row.'
                         end
        end

        def stock_turn_token_remove!
          @stock_turn_token_remove.dup.each do |st|
            close_corporation(st, quiet: true)
            @stock_turn_token_remove.delete(st)
          end
        end

        def stock_turn_token_removed?(corporation)
          @stock_turn_token_remove.any? { |st| st == corporation }
        end

        def take_loan(entity, loan = loans.first)
          raise GameError, "Cannot take more than #{maximum_loans(entity)} loans" unless can_take_loan?(entity)

          amount = loan_value(entity)
          @log << "#{entity.name} takes a loan and receives #{format_currency(amount)}"
          @bank.spend(amount, entity)
          entity.loans << loan
          @loans.delete(loan)

          before_share_price = entity.share_price
          @stock_market.move_down(entity)
          log_share_price_row(entity, before_share_price)
        end

        def take_player_loan(player, loan)
          player.cash += loan
          @player_debts[player] += loan + player_loan_interest(loan)
        end

        def train_type(train)
          train.name.include?('E') ? :etrain : :normal
        end

        def trains_empty?(entity)
          return false unless entity.operator?

          entity.trains.none? { |t| !infrastructure_train?(t) }
        end

        def update_ferry_hex(hex_name, tile_code, hex_borders)
          hex = hex_by_id(hex_name)
          hex_tile = Engine::Tile.from_code(hex_name, :blue, tile_code)
          hex.tile = hex_tile

          hex_borders.each do |border|
            hex_border = hex_by_id(border[:hex])
            border = hex_border.tile.borders.find { |b| b.edge == border[:edge] }
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

        def update_stock_turn_token_names
          @players.each do |player|
            st_company = player.companies.find { |c| stock_turn_token_company?(c) }
            stock_turn_token_name!(st_company)
          end
        end

        def visits_operating_rights?(entity, visits)
          nationals = operating_rights(entity)

          count = visits.count do |v|
            nationals.any? { |national| national_hexes(national).include?(v.hex.name) }
          end

          count == visits.size
        end

        def visits_within_national_region?(entity, visits)
          hexes = national_hexes(entity.id)
          visits.count { |v| hexes.include?(v.hex.name) } == visits.size
        end
      end
    end
  end
end
