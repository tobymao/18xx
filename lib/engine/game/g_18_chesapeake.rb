# frozen_string_literal: true

require_relative '../bank'
require_relative '../company'
require_relative '../corporation'
require_relative '../game/base'
require_relative '../hex'
require_relative '../tile'

module Engine
  module Game
    class G18Chesapeake < Base
      BANK_CASH = 8000

      CURRENCY_FORMAT_STR = '$%d'

      CERT_LIMIT = {
        2 => 20,
        3 => 20,
        4 => 16,
        5 => 13,
        6 => 11,
      }.freeze

      HEXES = {
        white: {
          %w[B6 B8 B10 C3 C7 C9 C11 E7 E9 E13 F6 F12 G7 I7 J8 J10 L4 F4 G5 H2 I3] => 'blank',
          %w[B12 D4 D6 D10 E5] => 'mtn80',
          %w[F10 G9 G11 H12] => 'wtr40',
          # TODO: %w[B4 K3 K5] => 't=r:0;t=r:0',
          %w[C5 D12 E3 F2 G13 J2] => 'city',
          %w[C13 D2 D8] => 'c=r:0;u=c:80,t:mountain',
          %w[E11] => 'town',
          %w[F8] => 'c=r:0;l=DC',
          %w[G3 I5] => 't=r:0;u=c:40,t:water',
          %w[H4 J6] => 'c=r:0;u=c:40,t:water',
        },
        red: {
          %w[A1 A15] => 'blank',
          %w[A3] => 'c=r:0;p=a:5,b:_0',
          %w[B2] => 'o=yellow_40|green_50|brown_60|gray_80;p=a:0,b:_0',
          %w[A7] => 'o=yellow_40|green_60|brown_80|gray_100;p=a:4,b:_0;p=a:5,b:_0',
          %w[A13] => 'o=yellow_40|green_60|brown_80|gray_100;p=a:4,b:_0',
          %w[B14] => 'o=yellow_40|green_60|brown_90|gray_100;p=a:3,b:_0;p=a:4,b:_0',
          %w[H14] => 'o=yellow_20|green_40|brown_50|gray_60;p=a:2,b:_0',
          %w[L2] => 'o=yellow_40|green_60|brown_80|gray_100;p=a:0,b:_0;p=a:1,b:_0',
        },
        gray: {
          %w[E1] => 'p=a:1,b:5',
          %w[F14] => 'p=a:3,b:4',
          %w[G1] => 'p=a:1,b:5;p=a:0,b:1',
          %w[I9] => 't=r:30;p=a:3,b:_0;p=a:_0,b:5',
          %w[K1] => 't=r:30;p=a:0,b:_0;p=a:_0,b:1',
          %w[K7] => 'p=a:2,b:3',
        },
        yellow: {
          %w[H6] => 'c=r:30;c=r:30;p=a:1,b:_0;p=a:4,b:_1;l=OO;u=c:40,t:water',
          %w[J4] => 'c=r:30;c=r:30;p=a:0,b:_0;p=a:3,b:_1;l=OO',
        }
      }.freeze

      TILES = {
        '1' => 1,
        '2' => 1,
        '3' => 2,
        '4' => 2,
        '7' => 2,
        '8' => 12,
        '9' => 9,
        '14' => 5,
        '15' => 6,
        '16' => 1,
        '19' => 1,
        '20' => 1,
        '23' => 3,
        '24' => 3,
        '25' => 2,
        '26' => 1,
        '27' => 1,
        '28' => 1,
        '29' => 1,
        '39' => 1,
        '40' => 1,
        '41' => 1,
        '42' => 1,
        '43' => 2,
        '44' => 1,
        '45' => 1,
        '46' => 1,
        '47' => 2,
        '55' => 1,
        '56' => 1,
        '57' => 7,
        '58' => 2,
        '69' => 1,
        '70' => 1,
        '611' => 5,
        # 'CC51' => 1,
        # 'CC1' => 1,
        # 'CC2' => 1,
        # 'CC3' => 1,
        # 'CC4' => 1,
        # 'CC5' => 1,
        # 'CC6' => 1,
        # 'CC7' => 2,
        # 'CC8' => 1,
        # 'CC9' => 1,
      }.freeze

      LOCATION_NAMES = {
        'B4' => 'Charleroi & Connellsville',
        'C5' => 'Green Spring',
        'C13' => 'Lynchburg',
        'D2' => 'Berlin',
        'D8' => 'Leesburg',
        'D12' => 'Charlottesville',
        'E3' => 'Hagerstown',
        'E11' => 'Fredericksburg',
        'F2' => 'Harrisburg',
        'F8' => 'Washington DC',
        'G3' => 'Columbia',
        'G13' => 'Richmond',
        'H4' => 'Strasburg',
        'H6' => 'Baltimore',
        'I5' => 'Wilmington',
        'J2' => 'Allentown',
        'J4' => 'Philadelphia',
        'J6' => 'Camden',
        'K3' => 'Trenton & Amboy',
        'K5' => 'Burlington & Princeton',
      }.freeze

      MARKET = [
        %w[80 85 90 100 110 125 140 160 180 200 225 250 275 300 325 350 375],
        %w[75 80 85 90 100 110 125 140 160 180 200 225 250 275 300 325 350],
        %w[70 75 80 85 95p 105 115 130 145 160 180 185 200],
        %w[65 70 75 80p 85 95 105 115 130 145],
        %w[60 65 70p 75 80 85 90 95 105],
        %w[55 60 65 70 75 80],
        %w[50 55 60 65],
        %w[40 45 50],
      ].freeze

      STARTING_CASH = {
        2 => 1200,
        3 => 800,
        4 => 600,
        5 => 480,
        6 => 400,
      }.freeze

      PHASES = [
        Phase::TWO,
        Phase::THREE,
        Phase::FOUR,
        Phase::FIVE,
        Phase::SIX,
        Phase::D,
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
          num: 6,
        },
        {
          name: '4',
          distance: 4,
          price: 300,
          rusts_on: 'D',
          num: 5,
        },
        {
          name: '5',
          distance: 5,
          price: 500,
          num: 3,
        },
        {
          name: '6',
          distance: 6,
          price: 630,
          num: 2,
        },
        {
          name: 'D',
          distance: 999,
          price: 900,
          num: 6,
          available_on: '6',
          discount: {
            '4' => 300,
            '5' => 300,
            '6' => 300,
            'D' => 300,
          }
        }
      ].freeze

      # rubocop:disable Layout/LineLength
      COMPANIES = [
        {
          name: 'Delaware and Raritan Canal',
          value: 20,
          revenue: 5,
          sym: 'DRC',
          desc: 'No special ability. Blocks hex K3 while owned by a player. Companies may purchase P1 - P5 from a player for half to double the face value.',
          abilities: [
            # TODO
          ],
        },
        {
          name: 'Columbia - Philadelphia Railroad',
          value: 40,
          revenue: 10,
          sym: 'CPR',
          desc: 'Blocks hexes H2 and I3 while owned by a player. The owning company may lay two connected tiles in hexes H2 and I3. Only #8 and #9 tiles may be used. If any tiles are played in these hexes other than by using this ability, the ability is forfeit. These tiles may be placed even if the owning company does not have a route to the hexes. These tiles are laid during the tile laying step and are in addition to the company’s tile placement action.',
          abilities: [
            # TODO
          ],
        },
        {
          name: 'Baltimore and Susquehanna Railroad',
          value: 50,
          revenue: 10,
          sym: 'BSR',
          desc: 'Blocks hexes F4 and G5 while owned by a player. The owning company may lay two connected tiles in hexes F4 and G5. Only #8 and #9 tiles may be used. If any tiles are played in these hexes other than by using this ability, the ability is forfeit. These tiles may be placed even if the owning company does not have a route to the hexes. These tiles are laid during the tile laying step and are in addition to the company’s tile placement action.',
          abilities: [
            # TODO
          ],
        },
        {
          name: 'Chesapeake and Ohio Canal',
          value: 80,
          revenue: 15,
          sym: 'COC',
          desc: 'Blocks hex D2 while owned by a player.Owning company may place a tile in hex D2.The company does not need to have a route to this hex.The tile placed counts as the company’ s tile lay action and the company must pay the terrain cost.The company may then immediately place a station token free of charge.',
          abilities: [
            # TODO
          ],
        },
        {
          name: 'Baltimore & Ohio Railroad',
          value: 100,
          revenue: 0,
          sym: 'B&OR',
          desc: 'During game setup place one share of the Baltimore & Ohio public company with this certificate.The player purchasing this private immediately takes both the private company and the B & O share.This private company has no other special ability.',
          abilities: [
            # TODO
          ],
        },
        {
          name: 'Cornelius Vanderbilt',
          value: 200,
          revenue: 30,
          sym: 'CV',
          desc: 'During game setup select a random president’s certificate and place it with this certificate.The player purchasing this private company takes both this certificate and the randomly selected president’ s certificate.The player immediately sets the par value of the public company.This private closes when the associated public company buys it’s first train.',
          abilities: [
            # TODO
          ],
        },
      ].freeze
      # rubocop:enable Layout/LineLength

      CORPORATIONS = [
        {
          sym: 'PRR',
          logo: '18_chesapeake/PRR',
          name: 'Pennsylvania Railroad',
          tokens: [0, 40, 60, 80],
          float_percent: 60,
          coordinates: 'F2',
          color: '#32763f'
        },
        {
          sym: 'PLE',
          logo: '18_chesapeake/PLE',
          name: 'Pittsburgh and Lake Erie Railroad',
          tokens: [0, 40, 60],
          float_percent: 60,
          coordinates: 'A3',
          color: '#9a9a9d'
        },
        {
          sym: 'SRR',
          logo: '18_chesapeake/SRR',
          name: 'Strasburg Rail Road',
          tokens: [0, 40, 60],
          float_percent: 60,
          coordinates: 'H4',
          color: '#d1232a'
        },
        {
          sym: 'B&O',
          logo: '18_chesapeake/BO',
          name: 'Baltimore & Ohio Railroad',
          tokens: [0, 40, 60],
          float_percent: 60,
          color: '#025aaa'
        },
        {
          sym: 'C&O',
          logo: '18_chesapeake/CO',
          name: 'Chesapeake & Ohio Railroad',
          tokens: [0, 40, 60, 80],
          float_percent: 60,
          color: '#8dd7f6'
        },
        {
          sym: 'LV',
          logo: '18_chesapeake/LV',
          name: 'Lehigh Valley Railroad',
          tokens: [0, 40],
          float_percent: 60,
          coordinates: 'J2',
          color: '#ffe600'
        },
        {
          sym: 'C&A',
          logo: '18_chesapeake/CA',
          name: 'Camden & Amboy Railroad',
          tokens: [0, 40],
          float_percent: 60,
          color: '#f58121'
        },
        {
          sym: 'NW',
          logo: '18_chesapeake/NW',
          name: 'Norfolk & Western Railway',
          tokens: [0, 40, 60],
          float_percent: 60,
          coordinates: 'C13',
          color: '#680b26'
        }
      ].freeze
    end
  end
end
