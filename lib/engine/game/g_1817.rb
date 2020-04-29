# frozen_string_literal: true

require_relative '../bank'
require_relative '../company'
require_relative '../corporation'
require_relative '../game/base'
require_relative '../hex'
require_relative '../tile'

module Engine
  module Game
    class G1817 < Base
      BANK_CASH = 99_999

      CURRENCY_FORMAT_STR = '$%d'

      CERT_LIMIT = {
        3 => 21,
        4 => 16,
        5 => 13,
        6 => 11,
        7 => 9,
      }.freeze

      HEXES = {
        red: {
          %w[A20] => 'o=yellow_20|green_30|brown_50|gray_60;p=a:4,b:_0;p=a:5,b:_0',
          %w[A28] => 'o=yellow_20|green_30|brown_50|gray_60;p=a:5,b:_0',
          %w[D1] => 'o=yellow_20|green_30|brown_50|gray_60;p=a:3,b:_0;p=a:4,b:_0',
          %w[H1] => 'o=yellow_20|green_30|brown_50|gray_60;p=a:2,b:_0;p=a:3,b:_0;p=a:4,b:_0',
          %w[J7 J15] => 'o=yellow_20|green_30|brown_50|gray_60;p=a:1,b:_0;p=a:2,b:_0',
        },
        white: {
          %w[B5 B17 C14 C22 F3 F13 F19 I16] => 'city',
          %w[D7] => 'c=r:0;u=c:20,t:water',
          %w[D19 I12] => 'c=r:0;u=c:15,t:mountain',
          %w[G6 H3 H9] => 'c=r:0;u=c:10,t:water',
          %w[B25 C20 C24 E16 E18 F15 G12 G14 H11 H13 H15 I8 I10] => 'u=c:15,t:mountain',
          %w[D13 E12 F11 G4 G10 H7] => 'u=c:10,t:water',
          %w[B9 B27 D25 D27 G20 H17] => 'u=c:20,t:water',
          %w[B3 B7 B11 B15 B19 B21 B23 C4 C6 C10 C16 C18 D3 D5 D11 D15 D17 D21 D23 E2 E4
             E6 E8 E10 E14 E20 F5 F7 F9 F17 F21 G2 G8 G16 H5 I2 I4 I6 I14] => 'blank',
        },
        gray: {
          %w[B13] => 'o=yellow_20|green_30|brown_40;t=r:0;p=a:0,b:_0;p=a:3,b:_0;p=a:4,b:_0',
          %w[D9] => 'o=yellow_30|green_40|brown_50|gray_60;c=r:0,s:2;p=a:4,b:_0;p=a:5,b:_0',
          %w[F1] => 'p=a:3,b:j;p=a:4,b:j;p=a:5,b=j',
        },
        yellow: {
          %w[C8] => 'c=r:30;p=a:3,b:_0;p=a:5,b:_0;l=B;u=c:20,t:water',
          %w[C26] => 'c=r:30;p=a:2,b:_0;p=a:4,b:_0;l=B',
          %w[E22] => 'c=r:40;c=r:40;p=a:2,b:_0;p=a:5,b:_1;l=NY;u=c:20,t:water',
          %w[G18] => 'c=r:30;p=a:3,b:_0;p=a:5,b:_0;l=B',
        },
        blue: {
          %w[C12] => 'blank',
        }
      }.freeze

      TILES = {
        '5' => 6,
        '6' => 7,
        '7' => 5,
        '8' => 20,
        '9' => 20,
        '14' => 7,
        '15' => 7,
        '54' => 1,
        '57' => 7,
        '62' => 1,
        '63' => 8,
        '80' => 7,
        '81' => 7,
        '82' => 10,
        '83' => 10,
        '448' => 4,
        '544' => 5,
        '545' => 5,
        '546' => 5,
        '592' => 4,
        '593' => 4,
        '597' => 4,
        '611' => 2,
        '619' => 8,
        'X00' => 1,
        'X30' => 1,
      }.freeze

      LOCATION_NAMES = {
        'B5' => 'Lansing',
        'B13' => 'Toronto',
        'B17' => 'Rochester',
        'C8' => 'Detroit',
        'C14' => 'Buffalo',
        'C22' => 'Albany',
        'C26' => 'Boston',
        'D7' => 'Toledo',
        'D9' => 'Cleveland',
        'D19' => 'Scranton',
        'F3' => 'Indianapolis',
        'F13' => 'Pittsburgh',
        'F19' => 'Philadelphia',
        'G6' => 'Cincinnati',
        'G18' => 'Baltimore',
        'H3' => 'Louisville',
        'H9' => 'Charleston',
        'I12' => 'Blacksburg',
        'I16' => 'Richmond',
      }.freeze

      MARKET = [].freeze

      STARTING_CASH = {
        3 => 420,
        4 => 315,
        5 => 252,
        6 => 210,
        7 => 180,
      }.freeze

      PHASES = [].freeze

      TRAINS = [
        {
          name: '2',
          distance: 2,
          price: 100,
          num: 16,
        },
        {
          name: '2+',
          distance: 2,
          price: 100,
          num: 4,
        },
        {
          name: '3',
          distance: 3,
          price: 250,
          num: 12,
        },
        {
          name: '4',
          distance: 4,
          price: 400,
          num: 8,
        },
        {
          name: '5',
          distance: 5,
          price: 600,
          num: 5,
        },
        {
          name: '6',
          distance: 6,
          price: 750,
          num: 4,
        },
        {
          name: '7',
          distance: 7,
          price: 900,
          num: 3,
        },
        {
          name: '8',
          distance: 8,
          price: 1100,
          num: 16,
        }
      ].freeze

      COMPANIES = [].freeze

      CORPORATIONS = [
        {
          sym: 'A&S',
          logo: '', # TODO
          name: 'Alton & Southern Railway',
          tokens: [0, 0, 0, 0],
          float_percent: 20,
          color: 'rgb(193,60,125)'
        },
        {
          sym: 'A&A',
          logo: '', # TODO
          name: 'Arcade and Attica',
          tokens: [0, 0, 0, 0],
          float_percent: 20,
          color: '#e09001'
        },
        {
          sym: 'Belt',
          logo: '', # TODO
          name: 'Belt Railway of Chicago',
          tokens: [0, 0, 0, 0],
          float_percent: 20,
          color: '#f58121'
        },
        {
          sym: 'Bess',
          logo: '', # TODO
          name: 'Bessemer and Lake Erie Railroad',
          tokens: [0, 0, 0, 0],
          float_percent: 20,
          color: '#110a0c'
        },
        {
          sym: 'B&A',
          logo: '', # TODO
          name: 'Boston and Albany Railroad',
          tokens: [0, 0, 0, 0],
          float_percent: 20,
          color: '#d1232a'
        },
        {
          sym: 'DL&W',
          logo: '', # TODO
          name: 'Delaware, Lackawanna and Western Railroad',
          tokens: [0, 0, 0, 0],
          float_percent: 20,
          color: '#680b26'
        },
        {
          sym: 'J',
          logo: '', # TODO
          name: 'Elgin, Joliet and Eastern Railway',
          tokens: [0, 0, 0, 0],
          float_percent: 20,
          color: '#32763f'
        },
        {
          sym: 'GT',
          logo: '', # TODO
          name: 'Grand Trunk Western Railroad',
          tokens: [0, 0, 0, 0],
          float_percent: 20,
          color: 'rgb(95,35,132)'
        },
        {
          sym: 'H',
          logo: '', # TODO
          name: 'Housatonic Railroad',
          tokens: [0, 0, 0, 0],
          float_percent: 20,
          color: '#8dd7f6'
        },
        {
          sym: 'ME',
          logo: '', # TODO
          name: 'Morristown and Erie Railway',
          tokens: [0, 0, 0, 0],
          float_percent: 20,
          color: '#ffe600'
        },
        {
          sym: 'NYOW',
          logo: '', # TODO
          name: 'New York, Ontaria and Western Railway',
          tokens: [0, 0, 0, 0],
          float_percent: 20,
          color: '#235758'
        },
        {
          sym: 'NYSW',
          logo: '', # TODO
          name: 'New York, Susquehanna and Western Railway',
          tokens: [0, 0, 0, 0],
          float_percent: 20,
          color: '#9a9a9d'
        },
        {
          sym: 'PSNR',
          logo: '', # TODO
          name: 'Pittsburg, Shawmut and Northern Railroad',
          tokens: [0, 0, 0, 0],
          float_percent: 20,
          color: 'rgb(110,192,55)'
        },
        {
          sym: 'PLE',
          logo: '', # TODO
          name: 'Pittsburg and Lake Erie Railroad',
          tokens: [0, 0, 0, 0],
          float_percent: 20,
          color: '#bdbd00'
        },
        {
          sym: 'PW',
          logo: '', # TODO
          name: 'Providence and Worcester Railroad',
          tokens: [0, 0, 0, 0],
          float_percent: 20,
          color: '#b58168'
        },
        {
          sym: 'R',
          logo: '', # TODO
          name: 'Rutland Railraod',
          tokens: [0, 0, 0, 0],
          float_percent: 20,
          color: '#025aaa'
        },
        {
          sym: 'SR',
          logo: '', # TODO
          name: 'Strasburg Railroad',
          tokens: [0, 0, 0, 0],
          float_percent: 20,
          color: '#fbf4de'
        },
        {
          sym: 'UR',
          logo: '', # TODO
          name: 'Union Railroad',
          tokens: [0, 0, 0, 0],
          float_percent: 20,
          color: '#004d95'
        },
        {
          sym: 'WT',
          logo: '', # TODO
          name: 'Warren & Trumbull Railroad',
          tokens: [0, 0, 0, 0],
          float_percent: 20,
          color: '#baa4cb'
        },
        {
          sym: 'WC',
          logo: '', # TODO
          name: 'West Chester Railroad',
          tokens: [0, 0, 0, 0],
          float_percent: 20,
          color: '#baa4cb'
        }
      ].freeze
    end
  end
end
