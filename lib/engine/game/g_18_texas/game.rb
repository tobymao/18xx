# frozen_string_literal: true

# add rules: 1/2 tile lays, half/full pay,
# sell/buy certs from bank, no sales until complete OR

require_relative 'meta'
require_relative '../base'

module Engine
  module Game
    module G18Texas
      class Game < Game::Base
        include_meta(G18Texas::Meta)

        CURRENCY_FORMAT_STR = '$%d'
        BANK_CASH = 8_000
        CERT_LIMIT = { 2 => 21, 3 => 15, 4 => 12, 5 => 10 }.freeze
        STARTING_CASH = { 2 => 670, 3 => 500, 4 => 430, 5 => 400 }.freeze
        CAPITALIZATION = :incremental
        HOME_TOKEN_TIMING = :float
        TRACK_RESTRICTION = :semi_restrictive
        LAYOUT = :pointy
        AXES = { x: :number, y: :letter }.freeze
        SELL_BUY_ORDER = :sell_buy

        # rubocop:disable Layout/LineLength
        TILES = {
          '5' => 4,
          '6' => 4,
          '7' => 5,
          '8' => 18,
          '9' => 18,
          '57' => 4,
          '202' => 3,
          '14' => 3,
          '15' => 4,
          '16' => 1,
          '17' => 1,
          '18' => 1,
          '19' => 1,
          '20' => 1,
          '21' => 1,
          '22' => 1,
          '23' => 4,
          '24' => 4,
          '25' => 2,
          '26' => 1,
          '27' => 1,
          '28' => 1,
          '29' => 1,
          '30' => 1,
          '31' => 1,
          '619' => 3,
          '624' => 1,
          '625' => 1,
          '626' => 1,
          '39' => 1,
          '40' => 1,
          '41' => 3,
          '42' => 3,
          '43' => 2,
          '44' => 1,
          '45' => 2,
          '46' => 2,
          '47' => 1,
          '70' => 1,
          '216' => 3,
          '611' => 5,
          '627' => 1,
          '628' => 1,
          '629' => 1,
          '511' =>
          {
            'count' => 4,
            'color' => 'green',
            'code' => 'city=revenue:40,slots:2;label=Y;path=a:0,b:_0;path=a:2,b:_0;path=a:4,b:_0',
          },
          '512' =>
          {
            'count' => 1,
            'color' => 'gray',
            'code' => 'city=revenue:60,slots:3;label=Y;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0',
          },
        }.freeze
        # rubocop:enable Layout/LineLength

        MARKET = [
          %w[82 90 100 110 122 135 150 165 180 200 220 245 270 300 330 360 400],
          %w[82 90 100 110 122 135 150 165 180 200 220 245 270],
          %w[70 75 82 90 100p 110 122 135 150 165 180],
          %w[65 70 75 82p 90p 100 110 122],
          %w[60 65 70p 75p 82 90],
          %w[50 60 65 70 75],
          %w[40 50 60 65],
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
        },
        {
          name: '4',
          on: '4',
          train_limit: 3,
          tiles: %i[yellow green],
          operating_rounds: 2,
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
          name: '8',
          on: '8',
          train_limit: 2,
          tiles: %i[yellow green brown gray],
          operating_rounds: 3,
        },
      ].freeze

        TRAINS = [
          {
            name: '2',
            distance: 2,
            price: 100,
            rusts_on: '4',
            num: 5,
          },
          {
            name: '3',
            distance: 3,
            price: 200,
            rusts_on: '6',
            num: 4,
          },
          {
            name: '4',
            distance: 4,
            price: 300,
            rusts_on: '8',
            num: 3,
          },
          {
            name: '5',
            distance: 5,
            price: 500,
            num: 2,
            events: [{ 'type' => 'close_companies' }],
          },
          { name: '6', distance: 6, price: 600, num: 2 },
          { name: '8', distance: 8, price: 800, num: 4 },
        ].freeze

        COMPANIES = [
          {
            name: 'A',
            value: 50,
            revenue: 10,
            desc: 'No special ability',
            sym: 'A',
          },
          {
            name: 'B',
            value: 80,
            revenue: 15,
            desc: 'No special ability',
            sym: 'B',
          },          {
            name: 'C',
            value: 200,
            revenue: 5,
            desc: 'The purchaser of this private company receives the president\'s certificate of '\
                  'the T&P Railroad and must immediately set its par value. The T&P automatically '\
                  'floats once this private company is purchased and is an exception to the normal '\
                  'rule.',
            abilities: [{ type: 'shares', shares: 'T&P_0' }],
            sym: 'C',
          },          {
            name: 'D',
            value: 210,
            revenue: 20,
            desc: 'The purchaser of this private company receives a share of '\
                  'the T&P Railroad.',
            abilities: [{ type: 'shares', shares: 'T&P_1' }],
            sym: 'D',
          },          {
            name: 'E',
            value: 240,
            revenue: 25,
            desc: 'The purchaser of this private company receives a share of '\
                  'the T&P Railroad.',
            abilities: [{ type: 'shares', shares: 'T&P_2' }],
            sym: 'E',
          }
        ].freeze

        CORPORATIONS = [
         {
           float_percent: 50,
           sym: 'T&P',
           name: 'Texas and Pacific Railway',
           logo: '18_texas/TP',
           token_fee: 100,
           tokens: [0, 0, 0],
           coordinates: 'D9',
           city: 1,
           color: 'darkmagenta',
           text_color: 'white',
           reservation_color: nil,
         },
         {
           float_percent: 50,
           sym: 'MKT',
           name: 'Missouri–Kansas–Texas Railway',
           logo: '18_texas/MKT',
           token_fee: 100,
           tokens: [0, 0, 0],
           coordinates: 'B11',
           color: 'green',
           text_color: 'white',
           reservation_color: nil,
         },
         {
           float_percent: 50,
           sym: 'SP',
           name: 'Southern Pacific Railroad',
           logo: '18_texas/SP',
           token_fee: 100,
           tokens: [0, 0, 0, 0],
           coordinates: 'I14',
           color: 'orange',
           text_color: 'white',
           reservation_color: nil,
         },
         {
           float_percent: 50,
           sym: 'MP',
           name: 'Missouri Pacific Railroad',
           logo: '18_texas/MP',
           token_fee: 100,
           tokens: [0, 0, 0, 0],
           coordinates: 'G10',
           color: 'indigo',
           text_color: 'white',
           reservation_color: nil,
         },
         {
           float_percent: 50,
           sym: 'SSW',
           name: 'St. Louis Southwestern Railway',
           logo: '18_texas/SSW',
           token_fee: 100,
           tokens: [0, 0, 0, 0],
           coordinates: 'D13',
           color: 'mediumpurple',
           text_color: 'white',
           reservation_color: nil,
         },
         {
           float_percent: 50,
           sym: 'SAA',
           name: 'San Antonio and Aransas Pass',
           logo: '18_texas/SAA',
           token_fee: 100,
           tokens: [0, 0, 0],
           coordinates: 'J5',
           color: 'black',
           text_color: 'white',
           reservation_color: nil,
         },
       ].freeze

        LOCATION_NAMES = {
          'A12' => 'Oklahoma City',
          'A18' => 'Little Rock',
          'B11' => 'Denison',
          'C16' => 'Texarkana',
          'D1' => 'El Paso',
          'D9' => 'Fort Worth & Dallas',
          'D15' => 'Marshall',
          'D17' => 'Shreveport',
          'D19' => 'Jackson',
          'F9' => 'Waco',
          'F13' => 'Palestine',
          'G10' => 'College Station',
          'H7' => 'Austin',
          'H19' => 'Lafayette',
          'I14' => 'Houston',
          'J1' => 'Piedras Negras',
          'J5' => 'San Antonio',
          'J15' => 'Galveston',
          'M2' => 'Laredo',
          'M8' => 'Corpus Christi',
          'N1' => 'Monterrey',
        }.freeze

        HEXES = {
          white: {
            %w[
            B9
            B13
            B15
            B17
            B19
            C8
            C10
            C12
            C18
            D3
            D5
            D11
            E2
            E4
            E6
            E8
            E10
            E12
            E14
            E16
            E18
            F3
            F5
            F7
            F11
            F15
            F17
            G4
            G6
            G8
            G12
            G14
            G16
            G18
            H3
            H5
            H9
            H13
            H15
            H17
            I2
            I4
            I8
            I10
            I16
            I18
            J3
            J7
            J9
            J11
            J13
            K2
            K4
            K6
            K8
            K10
            K12
            L1
            L3
            L5
            L7
            L9
            M4
            M6
            N3
            N5
            ] => '',
            %w['C14
               D7
               F13
               H11
               I6
               I12'] => 'town=revenue:0',
            %w['B11
               C16
               D9
               D13
               D15
               D17
               F9
               G10
               H7
               I14
               J5
               J15
               M2
               M8'] => 'city=revenue:0',
          },
          red: {
            ['A12'] => 'offboard=revenue:yellow_10|brown_40;path=a:0,b:_0;path=a:5,b:_0',
            ['A18'] => 'offboard=revenue:yellow_20|brown_40;path=a:0,b:_0;path=a:5,b:_0',
            ['D1'] => 'offboard=revenue:yellow_40|brown_60;path=a:4,b:_0;path=a:5,b:_0',
            ['D19'] => 'offboard=revenue:yellow_40|brown_60;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0',
            ['H19'] => 'offboard=revenue:yellow_40|brown_50;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0',
            ['J1'] => 'offboard=revenue:yellow_40|brown_50;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0',
            ['N1'] => 'offboard=revenue:yellow_40|brown_50;path=a:3,b:_0;path=a:4,b:_0',
          },
        }.freeze
      end
    end
  end
end
