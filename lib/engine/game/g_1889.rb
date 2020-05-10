# frozen_string_literal: true

require_relative 'base'

module Engine
  module Game
    class G1889 < Base
      BANK_CASH = 7_000

      CURRENCY_FORMAT_STR = '¥%d'

      CERT_LIMIT = {
        2 => 25,
        3 => 19,
        4 => 14,
        5 => 12,
        6 => 11,
      }.freeze

      HEXES = {
        white: {
          %w[B5 C8 D3 D9 E8 H3 I8 I10 J3] => 'blank',
          %w[B11 G10 I12 J5 J9] => 'town',
          %w[A10 C10 E2 F3 G4 G12 H7 I2 J11 K8] => 'city',
          %w[A8 B9 C6 D5 D7 E4 E6 F5 F7 G6 G8 H9 H11 H13] => 'mtn80',
          %w[K6] => 'wtr80',
          %w[H5 I6] => 'mtn+wtr80',

          %w[I4] => 'c=r:0;l=H;u=c:80',
        },
        yellow: {
          %w[C4] => 'c=r:20;p=a:2,b:_0',
          %w[K4] => 'c=r:30;p=a:0,b:_0;p=a:1,b:_0;p=a:2,b:_0;l=T',
        },
        green: {
          %w[F9] => 'c=r:30,s:2;p=a:2,b:_0;p=a:3,b:_0;p=a:4,b:_0;p=a:5,b:_0;l=K;u=c:80',
        },
        gray: {
          %w[B3] => 't=r:20;p=a:0,b:_0;p=a:_0,b:5',
          %w[B7] => 'c=r:40,s:2;p=a:1,b:_0;p=a:3,b:_0;p=a:5,b:_0',
          %w[G14] => 't=r:20;p=a:3,b:_0;p=a:_0,b:4', # TODO?: reference B3 tile, but with rotation
          %w[J7] => 'p=a:1,b:5',
        },
        red: {
          %w[F1] => 'o=r:yellow_30|brown_60|diesel_100;p=a:0,b:_0;p=a:1,b:_0',
          %w[J1] => 'o=r:yellow_20|brown_40|diesel_80;p=a:0,b:_0;p=a:1,b:_0',
          %w[L7] => 'o=r:yellow_20|brown_40|diesel_80;p=a:1,b:_0;p=a:2,b:_0',
        }
      }.freeze

      TILES = {
        '3' => { count: 2 },
        '5' => { count: 2 },
        '6' => { count: 2 },
        '7' => { count: 2 },
        '8' => { count: 5 },
        '9' => { count: 5 },
        '12' => { count: 1 },
        '13' => { count: 1 },
        '14' => { count: 1 },
        '15' => { count: 3 },
        '16' => { count: 1 },
        '19' => { count: 1 },
        '20' => { count: 1 },
        '23' => { count: 2 },
        '24' => { count: 2 },
        '25' => { count: 1 },
        '26' => { count: 1 },
        '27' => { count: 1 },
        '28' => { count: 1 },
        '29' => { count: 1 },
        '39' => { count: 1 },
        '40' => { count: 1 },
        '41' => { count: 1 },
        '42' => { count: 1 },
        '45' => { count: 1 },
        '46' => { count: 1 },
        '47' => { count: 1 },
        '57' => { count: 2 },
        '58' => { count: 3 },
        '205' => { count: 1 },
        '206' => { count: 1 },
        '437' => { count: 1 },
        '438' => { count: 1 },
        '439' => { count: 1 },
        '440' => { count: 1 },
        '448' => { count: 4 },
        '465' => { count: 1 },
        '466' => { count: 1 },
        '492' => { count: 1 },
        '611' => { count: 2 },
      }.freeze

      LOCATION_NAMES = {
        'A10' => 'Sukumo',
        'B11' => 'Nakamura',
        'B3' => 'Yawatahama',
        'B7' => 'Uwajima',
        'C10' => 'Kubokawa',
        'C4' => 'Ohzu',
        'E2' => 'Matsuyama',
        'F1' => 'Imabari',
        'F3' => 'Saijou',
        'F9' => 'Kouchi',
        'G10' => 'Nangoku',
        'G12' => 'Nahari',
        'G14' => 'Muroto',
        'G4' => 'Niihama',
        'H7' => 'Ikeda',
        'I12' => 'Muki',
        'I2' => 'Marugame',
        'I4' => 'Kotohira',
        'J1' => 'Sakaide & Okoyama',
        'J11' => 'Anan',
        'J5' => 'Ritsurin Kouen',
        'J9' => 'Komatsujima',
        'K4' => 'Takamatsu',
        'K8' => 'Tokushima',
        'L7' => 'Naruoto & Awaji',
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

      STARTING_CASH = {
        2 => 420,
        3 => 420,
        4 => 420,
        5 => 390,
        6 => 390,
      }.freeze

      COMPANIES = [
        {
          name: 'Takamatsu E-Railroad',
          value: 20,
          revenue: 5,
          sym: 'TR',
          desc: 'Blocks laying track in Takamatsu (K4).
          If all players pass during the initial stock round and this company has not been purchased,
          its price is reduced by ¥5.  If it is reduced to ¥0, the next player must take it for free.',
          abilities: [
            { type: :blocks_hexes, hexes: ['K4'] },
          ],
        },
        {
          name: 'Mitsubishi Ferry',
          value: 30,
          revenue: 5,
          sym: 'MF',
          desc: 'Player owner may place the port tile on a coastal village (B11, G10, I12 or J9).  This does not close
          the company.',
          abilities: [
            {
              type: :tile_lay,
              tiles: %w[437],
              hexes: %w[B11 G10 I12 J9],
              owner_type: :player,
            },
          ],
        },
        {
          name: 'Ehime Railway',
          value: 40,
          revenue: 10,
          sym: 'ER',
          desc: 'When this company is sold to a corporation, the selling player may place a green tile on Ohzu.  This
          does not close the company.',
          abilities: [
            { type: :blocks_hexes, hexes: ['C4'] },
            {
              type: :tile_lay,
              tiles: %w[12 13 14 15 205 206],
              hexes: %w[C4],
              when: :sold,
              owner_type: :corporation,
            },
          ],
        },
        {
          name: 'Sumitomo Mines Railway',
          value: 50,
          revenue: 15,
          desc: 'Owning corporation may ignore building costs for mountain hexes which do not contain rivers.  This
          does not close the company.',
          abilities: [
            {
              type: :ignore_terrain,
              terrain: :mountain,
              owner_type: :corporation,
            },
          ],
        },
        {
          name: 'Dougo Railway',
          value: 60,
          revenue: 15,
          desc: 'Owning player may exchange this private company for a 10% share of Iyo Railway from IPO.',
          abilities: [
            {
              type: :exchange,
              corporation: 'IR',
              owner_type: :player,
            },
          ],
        },
        {
          name: 'South Iyo Railway',
          value: 80,
          revenue: 20,
          min_players: 3,
          desc: 'No special abilities.'
        },
        {
          name: 'Uno-Takamatsu Ferry',
          value: 150,
          revenue: 30,
          min_players: 4,
          desc: 'Does not close while owned by a player.  After the purchase of the first 5-train, revenue becomes ¥50
          and this company may no longer be sold to a corporation.',
          abilities: [
            {
              type: :never_closes,
              owner_type: :player,
            },
            {
              type: :revenue_change,
              revenue: 50,
              when: '5',
              owner_type: :player,
            },
          ],
        },
      ].freeze

      CORPORATIONS = [
        {
          sym: 'AR',
          logo: '1889/AR',
          name: 'Awa Railroad',
          tokens: [0, 40],
          float_percent: 50,
          coordinates: 'K8',
          color: '#38383a'
        },
        {
          sym: 'IR',
          logo: '1889/IR',
          name: 'Iyo Railway',
          tokens: [0, 40],
          float_percent: 50,
          coordinates: 'E2',
          color: '#f68121'
        },
        {
          sym: 'SR',
          logo: '1889/SR',
          name: 'Sanuki Railway',
          tokens: [0, 40],
          float_percent: 50,
          coordinates: 'I2',
          color: '#79a242'
        },
        {
          sym: 'KO',
          logo: '1889/KO',
          name: 'Takamatsu & Kotohira Electric Railway',
          tokens: [0, 40],
          float_percent: 50,
          coordinates: 'K4',
          color: '#da1f3e'
        },
        {
          sym: 'TR',
          logo: '1889/TR',
          name: 'Tosa Electric Railway',
          tokens: [0, 40, 40],
          float_percent: 50,
          coordinates: 'F9',
          color: '#01a89e'
        },
        {
          sym: 'KU',
          logo: '1889/KU',
          name: 'Tosa Kuroshio Railway',
          tokens: [0],
          float_percent: 50,
          coordinates: 'C10',
          color: '#0089d1'
        },
        {
          sym: 'UR',
          logo: '1889/UR',
          name: 'Uwajima Railway',
          tokens: [0, 40, 40],
          float_percent: 50,
          coordinates: 'B7',
          color: '#7d3529'
        },
      ].freeze
    end
  end
end
