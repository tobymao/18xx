# frozen_string_literal: true

require_relative 'meta'
require_relative '../base'
require_relative '../../game_error'
require_relative '../g_1856/game'

module Engine
  module Game
    module G18KA
      class Game < G1856::Game
        include_meta(G18KA::Meta)

        CURRENCY_FORMAT_STR = '%sc'

        BANK_CASH = 12_000

        CERT_LIMIT = { 2 => 20, 3 => 13, 4 => 10 }.freeze
        def cert_limit(_player = nil)
          # cert limit isn't dynamic in 1836jr56
          CERT_LIMIT[@players.size]
        end

        STARTING_CASH = { 3 => 560, 4 => 420, 5 => 336, 6 => 280, 7 => 240 }.freeze

        LAYOUT = :flat
        # AXES = { x: :letter, y: :number }.freeze

        # colors
        OL_LIGHT_GREEN = '#7bb137'
        WM_CYAN = '#37b2e2'
        KM_ORANGE = '#eb6f0e'
        THARSIS_BROWN = '#881a1e'
        NM_NAVY = '#004d95'
        PMC_WHITE = '#FFF'

        NATIONAL_ = '#AA4444'
        ATLAS_VIOLET = '#8811CC'
        MARTIAN_RED = '#a1251b'
        MOUNTAIN_ENGINEER = '#daa'
        WATER_ENGINEER = '#cef'
        IPM_MAIN = '#ccc'
        JOVIAN_ORANGE = '#C99039'
        ICTN_GREEN = '#228855'
        MWM_BLUE = '#118'
        CAN_RED = '#FF0000'
        TITAN_RED = '#c43'
        ICY_WATER = '#b0e1eb'
        ASTEROID_GRAY = '#777'
        # TILE_TYPE = :lawson
        TILES = {

          '3' => 5,
          '4' => 5,
          '58' => 5,

          '5' => 4,
          '6' => 4,
          '57' => 8,

          '7' => 8,
          '8' => 16,
          '9' => 16,

          '59' => 2,

          '80' => 5,
          '81' => 5,
          '82' => 5,
          '83' => 5,

          '141' => 5,
          '142' => 5,
          '143' => 5,
          '144' => 5,

          '147' => 5,
          '146' => 5,
          '145' => 5,

          '64' => 1,
          '65' => 1,
          '66' => 1,
          '67' => 1,
          '68' => 1,

          '544' => 5,
          '545' => 5,
          '546' => 5,

          '14' => 5,
          '15' => 5,
          '619' => 5,

          '125' => 10,

          '51' => 5,
          '915' => 5,

          '60' => 5, #
          # OO tiles
          'OO1' => {
            'count' => 1,
            'color' => 'gray',
            'code' => 'city=revenue:60,slots:3;label=OO;'\
                      'path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0',
          },
          'OO2' => {
            'count' => 1,
            'color' => 'gray',
            'code' => 'city=revenue:70,loc:0;city=revenue:70,loc:3;label=OO;'\
                      'path=a:0,b:_0;path=a:1,b:_0;path=a:4,b:_0;'\
                      'path=a:2,b:_1;path=a:3,b:_1;path=a:5,b:_1',

          },
          # NNNY
          'NNNY1' => {
            'count' => 1,
            'color' => 'green',
            'code' =>
            'city=revenue:40;city=revenue:40;city=revenue:40;town=revenue:20;label=NNNY;'\
            'path=a:1,b:_0;path=a:_0,b:_3;path=a:3,b:_1;path=a:_1,b:_3;path=a:5,b:_2;path=a:_2,b:_3;',
          },
          'NNNY2' => {
            'count' => 1,
            'color' => 'brown',
            'code' =>
            'city=revenue:60;city=revenue:60;city=revenue:60;town=revenue:30,loc:center;label=NNNY;'\
            'path=a:1,b:_0;path=a:_0,b:_3;path=a:3,b:_1;path=a:_1,b:_3;path=a:5,b:_2;path=a:_2,b:_3;path=a:2,b:_3',
          },
          'NNNY3' => {
            'count' => 1,
            'color' => 'gray',
            'code' =>
            'city=revenue:80;city=revenue:80;city=revenue:80;town=revenue:40,loc:center;label=NNNY;'\
            'path=a:1,b:_0;path=a:_0,b:_3;path=a:3,b:_1;path=a:_1,b:_3;path=a:5,b:_2;path=a:_2,b:_3;'\
            'path=a:2,b:_3;path=a:4,b:_3',
          },
          # Capitol Tiles
          'CAP1' => {
            'count' => 1,
            'color' => 'green',
            'code' =>
            'city=revenue:60,loc:1.5;city=revenue:60,loc:4.5;label=C;'\
            'path=a:1,b:_0;path=a:2,b:_0;path=a:4,b:_1;path=a:5,b:_1',
          },
          'CAP2' => {
            'count' => 1,
            'color' => 'brown',
            'code' =>
            'city=revenue:80;city=revenue:80;city=revenue:40;label=C;'\
            'path=a:1,b:_0;path=a:2,b:_0;path=a:4,b:_1;path=a:5,b:_1;'\
            'path=a:0,b:_2;path=a:3,b:_2',
          },
          'CAP3' => {
            'count' => 1,
            'color' => 'gray',
            'code' =>
            'city=revenue:100;city=revenue:100;city=revenue:50,slots:2;label=C;'\
            'path=a:1,b:_0;path=a:2,b:_0;path=a:4,b:_1;path=a:5,b:_1;'\
            'path=a:0,b:_2;path=a:3,b:_2',
          },
          # Farm
          'FARM1' => {
            'count' => 1,
            'color' => 'green',
            'code' =>
            'city=revenue:40;label=F;path=a:0,b:_0;path=a:2,b:_0',
          },
          'FARM2' => {
            'count' => 1,
            'color' => 'brown',
            'code' =>
            'city=revenue:50,slots:2;label=F;path=a:0,b:_0;path=a:2,b:_0;path=a:4,b:_0',
          },
          'FARM3' => {
            'count' => 1,
            'color' => 'gray',
            'code' =>
            'city=revenue:60,slots:3;label=F;path=a:0,b:_0;path=a:2,b:_0;path=a:4,b:_0;path=a:5,b:_0',
          },
          # Space elevator
          'SE1' => {
            'count' => 1,
            'color' => 'green',
            'code' =>
            'city=revenue:50;label=SE;path=a:0,b:_0;path=a:2,b:_0;path=a:4,b:_0',
          },
          'SE2' => {
            'count' => 1,
            'color' => 'brown',
            'code' =>
            'city=revenue:70,slots:2;label=SE;path=a:0,b:_0;path=a:2,b:_0;path=a:4,b:_0;path=a:5,b:_0',
          },
          'SE3' => {
            'count' => 1,
            'color' => 'gray',
            'code' =>
            'city=revenue:90,slots:3;label=SE;path=a:0,b:_0;path=a:2,b:_0;path=a:4,b:_0;path=a:5,b:_0;path=a:3,b:_0',
          },
          # Port tile tech tree
          'PORT1' => {
            'count' => 4,
            'color' => 'yellow',
            'code' => 'city=revenue:30;label=P;path=a:0,b:_0;path=a:2,b:_0',
          },
          'PORT2a' => {
            'count' => 1,
            'color' => 'green',
            'code' => 'city=revenue:40,slots:2;label=P;path=a:0,b:_0;path=a:2,b:_0;path=a:1,b:_0;path=a:3,b:_0',
          },
          'PORT2b' => {
            'count' => 1,
            'color' => 'green',
            'code' => 'city=revenue:40;label=P;path=a:0,b:_0;path=a:2,b:_0;path=a:1,b:_0',
          },
          'PORT2c' => {
            'count' => 1,
            'color' => 'green',
            'code' => 'city=revenue:40;label=P;path=a:0,b:_0;path=a:2,b:_0;path=a:3,b:_0',
          },
          'PORT2d' => {
            'count' => 1,
            'color' => 'green',
            'code' => 'city=revenue:40;label=P;path=a:0,b:_0;path=a:2,b:_0;path=a:5,b:_0',
          },
          'PORT3' => {
            'count' => 4,
            'color' => 'brown',
            'code' => 'city=revenue:50,slots:2;label=P;path=a:0,b:_0;path=a:2,b:_0;path=a:1,b:_0;path=a:3,b:_0',
          },
          'PORT4a' => {
            'count' => 3,
            'color' => 'gray',
            'code' => 'city=revenue:60,slots:3;label=P;path=a:0,b:_0;path=a:2,b:_0;path=a:1,b:_0;path=a:3,b:_0',
          },
          'PORT4b' => {
            'count' => 3,
            'color' => 'gray',
            'code' => 'city=revenue:70,slots:2;label=P;path=a:0,b:_0;path=a:2,b:_0;path=a:1,b:_0;path=a:3,b:_0',
          },
        }.freeze

        LOCATION_NAMES = {
          'E4' => 'Arcadian Bay',
          'I4' => 'Borealis Harbor',
          'M8' => 'Chryse Gulf',
          'I10' => 'Deimos Down',
          'C12' => 'Olympus Mons',
          'F13' => 'Ascreus',
          'N15' => 'Chryse Harbor',
          'A16' => 'Elysium',
          'E16' => 'Pavis',
          'D19' => 'Arsia',
          'N21' => 'Hellas Sea',
          'E24' => 'Southern Mines',

        }.freeze

        PHASES = [
          {
            name: '2',
            train_limit: 4,
            tiles: [:yellow],
            status: %w[escrow facing_2],
            operating_rounds: 1,
          },
          {
            name: "2'",
            on: '2+1',
            train_limit: 4,
            tiles: [:yellow],
            status: %w[escrow facing_3],
            operating_rounds: 1,
          },
          {
            name: '3',
            on: '3',
            train_limit: 4,
            tiles: %i[yellow green],
            operating_rounds: 2,
            status: %w[escrow facing_3 can_buy_companies],
          },
          {
            name: "3'",
            on: "3+1'",
            train_limit: 4,
            tiles: %i[yellow green],
            operating_rounds: 2,
            status: %w[escrow facing_4 can_buy_companies],
          },
          {
            name: '4',
            on: '4',
            train_limit: 3,
            tiles: %i[yellow green],
            operating_rounds: 2,
            status: %w[escrow facing_4 can_buy_companies],
          },
          {
            name: "4'",
            on: "4+1'",
            train_limit: 3,
            tiles: %i[yellow green],
            operating_rounds: 2,
            status: %w[incremental facing_5 can_buy_companies],
          },
          {
            name: '5',
            on: '5',
            train_limit: 2,
            tiles: %i[yellow green brown],
            status: %w[incremental facing_5],
            operating_rounds: 3,
          },
          {
            name: "5'",
            on: "5'",
            train_limit: 2,
            tiles: %i[yellow green brown],
            status: %w[fullcap facing_6],
            operating_rounds: 3,
          },
          {
            name: '6',
            on: '6',
            train_limit: 2,
            tiles: %i[yellow green brown gray],
            status: %w[fullcap facing_6 upgradable_towns no_loans],
            operating_rounds: 3,
          },
          {
            name: '8',
            on: '8',
            train_limit: 2,
            tiles: %i[yellow green brown gray black],
            status: %w[fullcap facing_6 upgradable_towns no_loans],
            operating_rounds: 3,
          },
        ].freeze

        TRAINS = [{ name: '2', distance: 2, price: 100, rusts_on: '4', num: 4 },
                  {
                    name: '2+1',
                    distance: [
                      { 'nodes' => ['town'], 'pay' => 1, 'visit' => 1 },
                      { 'nodes' => %w[city offboard town], 'pay' => 2, 'visit' => 2 },
                    ],
                    price: 125,
                    obsolete_on: '4',
                    num: 1,
                  },
                  {
                    name: '2+1`',
                    distance: [
                      { 'nodes' => ['town'], 'pay' => 1, 'visit' => 1 },
                      { 'nodes' => %w[city offboard town], 'pay' => 2, 'visit' => 2 },
                    ],
                    price: 125,
                    obsolete_on: '4',
                    num: 1,
                  },
                  { name: '3', distance: 3, price: 225, rusts_on: '6', num: 3 },
                  {
                    name: '3+1',
                    distance: [
                      { 'nodes' => ['town'], 'pay' => 1, 'visit' => 1 },
                      { 'nodes' => %w[city offboard town], 'pay' => 3, 'visit' => 3 },
                    ],
                    price: 250,
                    obsolete_on: '6',
                    num: 1,
                  },
                  {
                    name: "3+1'",
                    distance: [
                      { 'nodes' => ['town'], 'pay' => 1, 'visit' => 1 },
                      { 'nodes' => %w[city offboard town], 'pay' => 3, 'visit' => 3 },
                    ],
                    price: 250,
                    obsolete_on: '6',
                    num: 1,
                  },
                  { name: '4', distance: 4, price: 350, rusts_on: '8', num: 2 },
                  {
                    name: '4+1',
                    distance: [
                      { 'nodes' => ['town'], 'pay' => 1, 'visit' => 1 },
                      { 'nodes' => %w[city offboard town], 'pay' => 4, 'visit' => 4 },
                    ],
                    price: 375,
                    obsolete_on: '8', # also D
                    num: 1,
                  },
                  {
                    name: "4+1'",
                    distance: [
                      { 'nodes' => ['town'], 'pay' => 1, 'visit' => 1 },
                      { 'nodes' => %w[city offboard town], 'pay' => 4, 'visit' => 4 },
                    ],
                    price: 375,
                    obsolete_on: '8', # also D
                    num: 1,
                  },
                  {
                    name: '5',
                    distance: 5,
                    price: 550,
                    num: 1,
                    events: [{ 'type' => 'close_companies' }],
                  },
                  {
                    name: "5'",
                    distance: 5,
                    price: 550,
                    num: 1,
                    events: [{ 'type' => 'no_more_incremental_corps' }],
                  },
                  {
                    name: '6',
                    distance: 6,
                    price: 700,
                    num: 2,
                    events: [{ 'type' => 'nationalization' }, { 'type' => 'remove_tokens' }],
                  },
                  {
                    name: '8',
                    distance: 8,
                    price: 1000,
                    num: 16,
                    available_on: '6',
                    discount: { '4' => 350, "4'" => 350, '5' => 350, "5'" => 350, '6' => 350 },
                    variants: [
                      {
                        name: 'D',
                        distance: 999,
                        price: 1250,
                        available_on: '6',
                        discount: { '4' => 350, "4'" => 350, '5' => 350, "5'" => 350, '6' => 350 },
                      },
                    ],
                  },
                  { name: '+1', distance: 0, price: 25, rusts_on: '5', available_on: '2', num: 5 },
                  { name: '+2', distance: 0, price: 50, rusts_on: '8', available_on: '3', num: 4 },
                  { name: '+3', distance: 0, price: 75, available_on: '5', num: 3 },
                  { name: '+4', distance: 0, price: 100, available_on: '6', num: 2 },
                  { name: '+5', distance: 0, price: 125, available_on: '8', num: 1 }].freeze

        EQUATOR_HEXES = %w[C16 G16 I16].freeze
        COMPANIES = [
          {
            name: 'Platinum Credit Card',
            value: 10,
            revenue: 0,
            desc: 'The owning corporation can have 1 additional outstanding loan, beyond the usual limit',
            sym: 'A',
          },
          {
            name: 'Deimos Drilling',
            value: 20,
            revenue: 5,
            desc: 'The owning corporation gets 3 mountain Engineers and 1 mining Right. Other corporations can buy '\
                  'mining Rights from this corporation for 50c',
            sym: 'B',
          },
          {
            name: 'Cosmic Corn Company',
            value: 30,
            revenue: 10,
            desc: 'The owning corporation may place the Farm (F) tile on an equitorial hex as a bonus disconnected '\
                  'tile lay. In exchange for closing this private the corporation may token it for free',
            sym: 'C',
            abilities: [
              {
                type: 'tile_lay',
                owner_type: 'corporation',
                free: false,
                hexes: EQUATOR_HEXES,
                tiles: %w[FARM1],
                when: 'track',
                count: 1,
              },
              {
                type: 'token',
                description: 'Token in the Farm tile for free',
                hexes: EQUATOR_HEXES,
                count: 1,
                price: 0,
                teleport_price: 0,
                extra_action: true,
                from_owner: true,
              },
            ],
          },
          {
            name: 'Bob\'s Better Bridges',
            value: 40,
            revenue: 10,
            desc: 'This private comes with 2 water Engineers and 2 Harbor Rights. Other corporations can buy harbor '\
                  'Rights from this corporation for 50c',
            sym: 'D',
          },
          {
            name: 'Planetary Espresso',
            value: 50,
            revenue: 10,
            desc: 'The owning corporation may close this company to upgrade the NNNY hex/tile for free and the owning '\
                  'corporation may also place a token on the NNNY hex for free, even without a connection',
            sym: 'E',
          },
          {
            name: 'Happy Happy Harbor',
            value: 60,
            revenue: 15,
            desc: 'This private comes with 1 water Engineer and 2 Harbor Rights. When bought by a corporation, '\
                  'the owning corporation may lay a second harbor marker on an harbor hex, doubling the harbor right bonus '\
                  'for that hex. Other coproraitons can buy harbor rights from this corporation for 50c',
            sym: 'F',
          },
          {
            name: 'Capitol Contract',
            value: 70,
            revenue: 15,
            desc: 'The owning corporation may place the Capitol (C) tile on an equitorial hex as a bonus disconnected '\
                  'tile lay. In exchange for closing this private the corporation may token it for free',
            sym: 'G',
            abilities: [
              {
                type: 'tile_lay',
                owner_type: 'corporation',
                free: false,
                hexes: EQUATOR_HEXES,
                tiles: %w[CAP1],
                when: 'track',
                count: 1,
              },
              {
                type: 'token',
                description: 'Token in the Captiol tile for free',
                hexes: EQUATOR_HEXES,
                count: 1,
                price: 0,
                teleport_price: 0,
                extra_action: true,
                from_owner: true,
              },
            ],
          },
          {
            name: 'Mole People',
            value: 80,
            revenue: 20,
            desc: 'The private comes with 1 mining Engineer and 2 mining Rights. THe owning corporation may close '\
                  'this private to place a mining token in an empty, connected station as a neutral token. Other '\
                  'coprorations can buy mining rights from this corproation for 50c',
            sym: 'H',
          },
          {
            name: 'Space Elevator',
            value: 90,
            revenue: 20,
            desc: 'The owning corporation may place the Space Elevator (SE) tile on an equitorial hex as a bonus '\
                  'disconnected tile lay. In exchange for closing this private the corporation may token it for free',
            sym: 'I',
            abilities: [
              {
                type: 'tile_lay',
                owner_type: 'corporation',
                free: false,
                hexes: EQUATOR_HEXES,
                tiles: %w[SE1],
                when: 'track',
                count: 1,
              },
              {
                type: 'token',
                description: 'Token in the Space Elevator tile for free',
                hexes: EQUATOR_HEXES,
                count: 1,
                price: 0,
                teleport_price: 0,
                extra_action: true,
                from_owner: true,
              },
            ],
          },
          {
            name: 'Protoype Maglev',
            value: 100,
            revenue: 25,
            desc: 'Comes with a 2T. The 2T train may be sold at any time (including SR) to any corporation '\
                  '(whose president\'s share has been bought) for any price from 1c up to 100c with consent from the '\
                  'buyer and seller. The buying company may offer IPO shares as part of the sale counting at market price '\
                  'with no monetary compensation to the selling corporation. The private is closed at the '\
                  'end of the initial private auction',
            sym: 'J',
          },
          {
            name: 'UPF Bribes',
            value: 125,
            revenue: 30,
            desc: 'This private can be exchanged as a buy action during any stock round to buy an IPO share of a '\
                  'started corporation for free, with no compensation to the corporation',
            sym: 'K',
          },
          {
            name: 'Underground Connections',
            value: 150,
            revenue: 35,
            desc: 'The owning corporation can close this company to repalce an existing token with a token of the '\
                  'corporation, with exceptions. This private may not be sold to a corporation. In a stock round this '\
                  'private can be exchanged to buy the presidency of a corporation with this private as '\
                  'the only compensation to the corporation',
            sym: 'L',
          },
        ].freeze

        ASSIGNMENT_TOKENS = {
          'RdP' => '/icons/1846/sc_token.svg',
        }.freeze
        PORT_HEXES = %w[A9 B8 B10 D6 E5 E11 F4 F10 G7 H2 H4 H6 H10 I3 I9 J6 J8 K11].freeze
        CORPORATIONS = [
          # Tier 1
          {
            sym: 'OL',
            name: 'Olympean Lines',
            logo: '18_ka/OL',
            simple_logo: '18_ka/OL.alt',
            tokens: [0, 40, 80, 120],
            coordinates: 'A12',
            color: OL_LIGHT_GREEN,
            text_color: 'black',
          },
          {
            sym: 'AF',
            name: 'Atlas Freight',
            logo: '18_ka/AF',
            simple_logo: '18_ka/AF.alt',
            tokens: [0, 40, 80, 120],
            coordinates: 'G8',
            color: ATLAS_VIOLET,
            text_color: 'white',
          },
          {
            sym: 'KM',
            name: 'Kasei Magway',
            logo: '18_ka/KM',
            simple_logo: '18_ka/KM.alt',
            tokens: [0, 40, 80, 120],
            coordinates: 'M20',
            color: KM_ORANGE,
            text_color: 'black',
          },
          {
            sym: 'WM',
            name: 'Whitney Magway',
            logo: '18_ka/WM',
            simple_logo: '18_ka/WM.alt',
            tokens: [0, 40, 80, 120],
            coordinates: 'K14',
            color: WM_CYAN,
            text_color: 'black',
          },

          # Tier 2
          {
            sym: 'C9S',
            name: 'Cloud Nine Shipping',
            logo: '18_ka/C9S',
            simple_logo: '18_ka/C9S.alt',
            tokens: [0, 40, 70, 100, 130],
            coordinates: 'M12',
            color: ICY_WATER,
            text_color: 'black',
          },
          {
            sym: 'TL',
            name: 'Tharsis Lines',
            logo: '18_ka/TL',
            simple_logo: '18_ka/TL.alt',
            tokens: [0, 40, 70, 100, 130],
            coordinates: 'E10',
            color: THARSIS_BROWN,
            text_color: 'white',
          },
          {
            sym: 'NM',
            name: 'Noctis Magways',
            logo: '18_ka/NM',
            simple_logo: '18_ka/NM.alt',
            tokens: [0, 40, 70, 100, 130],
            coordinates: 'J19',
            color: NM_NAVY,
            text_color: 'white',
          },
          {
            sym: 'ATN',
            name: 'Asteroid Transportation Network',
            logo: '18_ka/ATN',
            simple_logo: '18_ka/ATN.alt',
            tokens: [0, 40, 70, 100, 130],
            coordinates: 'D7',
            color: ASTEROID_GRAY,
            text_color: 'white',
          },
          {
            sym: 'PMC',
            name: 'Polar Mining Corporation',
            logo: '18_ka/PMC',
            simple_logo: '18_ka/PMC.alt',
            tokens: [0, 40, 70, 100, 130],
            coordinates: 'L9',
            color: PMC_WHITE,
            text_color: 'black',
          },

          # Tier 3
          {
            sym: 'CMM',
            name: 'Canadian Martian Magway',
            logo: '18_ka/CMM',
            simple_logo: '18_ka/CMM.alt',
            tokens: [0, 40, 60, 80, 100, 120],
            coordinates: 'F19',
            color: CAN_RED,
            text_color: 'black',
          },
          {
            sym: 'IPM',
            name: 'Inner Planets Magway',
            logo: '18_ka/IPM',
            simple_logo: '18_ka/IPM.alt',
            tokens: [0, 40, 60, 80, 100, 120],
            coordinates: 'C20',
            color: IPM_MAIN,
            text_color: 'black',
          },
          {
            sym: 'TiTaN',
            name: 'Tharsis Transportation Network',
            logo: '18_ka/TiTaN',
            simple_logo: '18_ka/TiTaN.alt',
            tokens: [0, 40, 60, 80, 100, 120],
            coordinates: 'F15',
            color: TITAN_RED,
            text_color: 'white',
          },
          {
            sym: 'ICTN',
            name: 'Indo-Chinese Transportation Network',
            logo: '18_ka/ICTN',
            simple_logo: '18_ka/ICTN.alt',
            tokens: [0, 40, 60, 80, 100, 120],
            coordinates: 'H13',
            color: ICTN_GREEN,
            text_color: 'white',
          },
          {
            sym: 'JA',
            name: 'Jovian Alliance',
            logo: '18_ka/JA',
            simple_logo: '18_ka/JA.alt',
            tokens: [0, 40, 60, 80, 100, 120],
            coordinates: 'H5',
            color: JOVIAN_ORANGE,
            text_color: 'black',
          },
          {
            sym: 'MWM',
            name: 'Milky Way Mining',
            logo: '18_ka/MWM',
            simple_logo: '18_ka/MWM.alt',
            tokens: [0, 40, 60, 80, 100, 120],
            coordinates: 'I8',
            color: MWM_BLUE,
            text_color: 'white',
          },

          {
            sym: 'MGM',
            logo: '18_ka/MGM',
            simple_logo: '18_ka/MGM.alt',
            name: 'Martian Global Magway',
            tokens: [],
            color: NATIONAL_,
            text_color: 'white',
            abilities: [
              {
                type: 'train_buy',
                description: 'Inter train buy/sell at face value',
                face_value: true,
              },
              {
                type: 'train_limit',
                increase: 99,
                description: '3 train limit',
              },
              {
                type: 'borrow_train',
                train_types: %w[8 D],
                description: 'May borrow a train when trainless*',
              },
            ],
            reservation_color: nil,
          },
        ].freeze
        # TODO: Make location name optional and refactor into 1856
        def create_destinations(destinations)
          @destinations = {}
          destinations.each do |corp, dest|
            dest_arr = Array(dest)
            d_goals = Array(dest_arr.first)
            d_start = dest_arr.size > 1 ? dest_arr.last : corporation_by_id(corp).coordinates
            @destination_statuses[corp] = "Dest: Connect Home (#{d_start}) to #{d_goals}"
            dest_arr.each do |d|
              # Array(d).first allows us to treat 'E5' or %[O2 N3] identically
              hex_by_id(Array(d).first).original_tile.icons << Part::Icon.new(icon_path(corp))
            end
            @destinations[corp] = [d_start, d_goals].freeze
          end
        end
        DESTINATIONS = {
          'AF' => 'I14',
          'KM' => 'K16',
          'OL' => 'E16',
          'WM' => [%w[N21 N23]],

          'ATN' => 'I10',
          'C9S' => 'H11',
          'TL' => 'F15',
          'NM' => 'N15',
          'PMC' => 'M16',

          'JA' => 'M8',
          'IPM' => 'C12',
          'ICTN' => 'G20',
          'CMM' => 'K20',
          'MWM' => [%w[D5 E4]],
          'TiTaN' => [%w[E24 F25]],
        }.freeze

        HAMILTON_HEX = 'A1' # Don't use
        HEXES = {
          gray: {
            ['A10'] => 'path=a:0,b:4',
            ['A14'] => 'path=a:5,b:3',
            ['C22'] => 'path=a:4,b:3',
            ['J21'] => 'path=a:2,b:4',
          },
          white: {
            %w[B17 C8 D15 E6 E8 E12 E20 E22 F5 F17 G22 H7 H15 H19 I6 I20 J13 J15 K10 L13 L15 L21] => 'blank',
            %w[B15 C18 C20 D7 E10 F23 F19 G6 G18 H13 J19 K14 K20 L9] => 'city=revenue:0',
            %w[H17 I18 J17 K18 L11 M10] => 'upgrade=cost:40,terrain:water',
            %w[L19] => 'town=revenue:0;upgrade=cost:40,terrain:water',
            %w[B19 J5 B9 D21 F21 F7 G12 H21 I14 K16 K12 L7 M14] => 'town=revenue:0',
            %w[C10 B13 D11 E14 D13 D17 H9 J9 I12 G14 E18 M22] => 'upgrade=cost:30,terrain:mountain',
            %w[F15 I8 H11 J11] => 'city=revenue:0;upgrade=cost:30,terrain:mountain',
            %w[K8 F9] => 'city=revenue:0;upgrade=cost:20,terrain:swamp',
            %w[J7 K6 G10 F11] => 'upgrade=cost:20,terrain:swamp',
            %w[B11 C14] => 'town=revenue:0;upgrade=cost:30,terrain:mountain',
            %w[H5 A12 M12 M16 M20] => 'city=revenue:0;label=P',
            %w[D19 E16 F13] =>
            'town=revenue:0;upgrade=cost:60,terrain:mountain;icon=image:18_ka/plus_20,sticky:1',
          },
          red: {
            ['C12'] => 'offboard=revenue:yellow_30|brown_60|black_70;path=a:5,b:_0,terminal:1;'\
                       'path=a:0,b:_0,terminal:1;path=a:1,b:_0,terminal:1;path=a:2,b:_0,terminal:1;path=a:3,b:_0,terminal:1;'\
                       'path=a:4,b:_0,terminal:1',
            ['I10'] => 'offboard=revenue:yellow_40|brown_30|black_20;path=a:5,b:_0,terminal:1;'\
                       'path=a:1,b:_0,terminal:1;path=a:3,b:_0,terminal:1;icon=image:18_ka/mine,sticky:1',
            ['D5'] =>
            'offboard=revenue:yellow_30|brown_40|black_50,hide:1,groups:Arcadian Bay;'\
            'path=a:0,b:_0,terminal:1;path=a:5,b:_0,terminal:1;border=edge:4',
            ['E4'] =>
            'offboard=revenue:yellow_30|brown_40|black_50,groups:Arcadian Bay;'\
            'path=a:0,b:_0,terminal:1;border=edge:1',
            ['A16'] =>
            'offboard=revenue:yellow_30|brown_40|black_60,hide:1,groups:Elysium;'\
            'path=a:5,b:_0,terminal:1;path=a:4,b:_0,terminal:1;border=edge:0',
            ['A18'] =>
            'offboard=revenue:yellow_30|brown_40|black_60,groups:Elysium;'\
            'path=a:5,b:_0,terminal:1;path=a:4,b:_0,terminal:1;border=edge:3',
            ['E24'] =>
            'offboard=revenue:yellow_40|brown_50|black_20,hide:1,groups:Southern Mines;'\
            'path=a:3,b:_0,terminal:1;path=a:4,b:_0,terminal:1;border=edge:5',
            ['F25'] =>
            'offboard=revenue:yellow_40|brown_50|black_20,groups:Southern Mines;'\
            'path=a:3,b:_0,terminal:1;border=edge:2;icon=image:18_ka/mine,sticky:1',
            ['N21'] =>
            'offboard=revenue:yellow_30|brown_40|black_50,hide:1,groups:Hellas Sea;'\
            'path=a:1,b:_0,terminal:1;path=a:2,b:_0,terminal:1;border=edge:0',
            ['N23'] =>
            'offboard=revenue:yellow_30|brown_40|black_50,groups:Hellas Sea;'\
            'path=a:2,b:_0,terminal:1;border=edge:3',
          },
          blue: {
            %w[A8] => 'border=edge:4',
            %w[B7] => 'border=edge:4;border=edge:1',
            %w[C6] => 'border=edge:1',
            %w[F3] => 'border=edge:5',
            %w[G4] => 'border=edge:2;border=edge:4',
            %w[H3 J3] => 'border=edge:1;border=edge:5',
            %w[K4 L5] => 'border=edge:2;border=edge:5',
            ['I4'] => 'town=revenue:yellow_10|brown_20|black_30;path=a:1,b:_0;path=a:0,b:_0;path=a:5,b:_0;'\
                      'border=edge:2;border=edge:4;icon=image:port,sticky:1',
            %w[M6] => 'border=edge:2;border=edge:0',
            ['M8'] => 'offboard=revenue:yellow_20|brown_30|black_40;path=a:1,b:_0,terminal:1;path=a:2,b:_0,terminal:1;'\
                      'border=edge:3;border=edge:5;icon=image:port,sticky:1',
            %w[N9] => 'border=edge:2;border=edge:0',
            %w[N11 N13] => 'border=edge:3;border=edge:0',
            ['N15'] => 'offboard=revenue:yellow_20|brown_30|black_60;path=a:1,b:_0,terminal:1;'\
                       'path=a:2,b:_0,terminal:1;border=edge:3;border=edge:0;icon=image:port,sticky:1',
            ['N17'] => 'border=edge:3;border=edge:1;border=edge:0',
            ['M18'] => 'border=edge:4;border=edge:5',
            ['N19'] => 'border=edge:2;border=edge:3',
          },
          yellow: {
            ['L17'] =>
            'city=revenue:20;town=revenue:20;path=a:2,b:_0;path=a:_0,b:_1;label=NNNY;upgrade=cost:40,terrain:water',
            %w[D9 G8 G20] => 'city=revenue:0;city=revenue:0;label=OO',
            %w[C16 G16] => 'city=revenue:0;label=E;',
            %w[I16] => 'city=revenue:0;label=E;upgrade=cost:40,terrain:water',
          },
        }.freeze

        EXTRA_TRAIN_PULLMAN = %w[+1 +2 +3 +4 +5].freeze
        SELL_BUY_ORDER = :sell_buy_sell
        TRACK_RESTRICTION = :permissive
        TILE_RESERVATION_BLOCKS_OTHERS = :always
        def national
          @national ||= corporation_by_id('MGM')
        end

        def port
          @port ||= company_by_id('RdP')
        end

        def company_bought(company, entity) end

        def tunnel
          raise GameError, "'tunnel' Should not be used"
        end

        def bridge
          raise GameError, "'bridge' Should not be used"
        end

        def wsrc
          raise GameError, "'wsrc' Should not be used"
        end

        def capitol_tile
          tile_by_id('CAP1-0')
        end

        def capitol_blocked?
          company_by_id('G').owned_by_player?
        end

        def farm_tile
          tile_by_id('FARM1-0')
        end

        def farm_blocked?
          company_by_id('C').owned_by_player?
        end

        def elevator_tile
          tile_by_id('SE1-0')
        end

        def elevator_blocked?
          company_by_id('I').owned_by_player?
        end

        def setup
          @straight_city ||= @tiles.find { |t| t.name == '57' }
          @sharp_city ||= @tiles.find { |t| t.name == '5' }
          @gentle_city ||= @tiles.find { |t| t.name == '6' }

          @straight_track ||= @tiles.find { |t| t.name == '9' }
          @sharp_track ||= @tiles.find { |t| t.name == '7' }
          @gentle_track ||= @tiles.find { |t| t.name == '8' }

          @x_city ||= @tiles.find { |t| t.name == '14' }
          @k_city ||= @tiles.find { |t| t.name == '15' }

          @brown_london ||= @tiles.find { |t| t.name == '126' }
          @brown_barrie ||= @tiles.find { |t| t.name == '127' }

          @gray_hamilton ||= @tiles.find { |t| t.name == '123' }

          @post_nationalization = false
          @nationalization_train_discard_trigger = false
          @national_formed = false

          @pre_national_percent_by_player = {}
          @pre_national_market_percent = 0

          @pre_national_market_prices = {}
          @nationalized_corps = []

          @bankrupted = false

          # Is the president of the national a "false" president?
          # A false president gets the presidency with only one share; in this case the president gets
          # the full president's certificate but is obligated to buy up to the full presidency in the
          # following SR unless a different player becomes rightfully president during share exchange
          # It is impossible for someone who didn't become president in
          # exchange (1 share tops) to steal the presidency in the SR because
          # they'd have to buy 2 shares in one action which is a no-no
          # nil: Presidency not awarded yet at all
          # not-nl: 1-share false presidency has been awarded to the player (value of var)
          @false_national_president = nil

          # CGR flags
          @national_ever_owned_permanent = false

          @destination_statuses = {}
          # Corp -> Borrowed Train
          @borrowed_trains = {}
          create_destinations(DESTINATIONS)
          national.add_ability(self.class::NATIONAL_IMMOBILE_SHARE_PRICE_ABILITY)
          national.add_ability(self.class::NATIONAL_FORCED_WITHHOLD_ABILITY)
        end

        def route_distance_str(route)
          towns = route.visited_stops.count(&:town?)
          cities = route_distance(route) - towns
          "#{cities}+#{towns}"
        end

        def revenue_for(route, stops)
          stops.sum { |stop| stop.route_revenue(route.phase, route.train) }
        end

        def route_trains(entity)
          entity.runnable_trains.reject { |t| pullman_train?(t) }
        end

        def pullman_train?(train)
          self.class::EXTRA_TRAIN_PULLMAN.include?(train.name)
        end

        def must_buy_train?(entity)
          entity.trains.none? { |t| !pullman_train?(t) } && @graph.route_info(entity)&.dig(:route_train_purchase)
        end

        def operating_round(round_num)
          G1856::Round::Operating.new(self, [
            G1856::Step::Bankrupt,
            G1856::Step::CashCrisis,
            # No exchanges.
            G1856::Step::Assign,
            G1856::Step::Loan,
            G1856::Step::SpecialTrack,
            G18KA::Step::SpecialToken,
            Engine::Step::BuyCompany,
            Engine::Step::HomeToken,

            # Nationalization!!
            G1856::Step::NationalizationPayoff,
            G1856::Step::RemoveTokens,
            G1856::Step::NationalizationDiscardTrains,
            # Re-enable to reenable rights
            # G1856::Step::SpecialBuy,
            G1856::Step::Track,
            G1856::Step::Escrow,
            G1856::Step::Token,
            G1856::Step::BorrowTrain,
            G18KA::Step::Route,
            # Interest - See Loan
            G1856::Step::Dividend,
            Engine::Step::DiscardTrain,
            G1856::Step::BuyTrain,
            # Repay Loans - See Loan
            [G1856::Step::BuyCompany, { blocks: true }],
          ], round_num: round_num)
        end

        def stock_round
          G1856::Round::Stock.new(self, [
            Engine::Step::DiscardTrain,
            Engine::Step::Exchange,
            Engine::Step::SpecialTrack,
            G1856::Step::BuySellParShares,
          ])
        end

        def icon_path(corp)
          super if corp == national

          "../logos/18_ka/#{corp}"
        end

        #
        # Get all possible upgrades for a tile
        # tile: The tile to be upgraded
        # tile_manifest: true/false Is this being called from the tile manifest screen
        #
        def all_potential_upgrades(tile, tile_manifest: false, selected_company: nil)
          upgrades = super
          return upgrades unless tile_manifest

          upgrades |= [farm_tile] if EQUATOR_HEXES.include?(tile.name) && !farm_blocked?
          upgrades |= [elevator_tile] if EQUATOR_HEXES.include?(tile.name) && !elevator_blocked?
          upgrades |= [capitol_tile] if EQUATOR_HEXES.include?(tile.name) && !capitol_blocked?

          upgrades
        end

        #
        # Get the currently possible upgrades for a tile
        # from: Tile - Tile to upgrade from
        # to: Tile - Tile to upgrade to
        # special - ???
        def upgrades_to?(from, to, _special = false, selected_company: nil)
          if EQUATOR_HEXES.include?(from.name) && @phase.tiles.include?(:green)
            return !farm_blocked? if to.name == farm_tile.name
            return !elevator_blocked? if to.name == elevator_tile.name
            return !capitol_blocked? if to.name == capitol_tile.name
          end

          super
        end
      end
    end
  end
end
