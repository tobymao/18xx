# frozen_string_literal: true

module Engine
  module Game
    module G1850
      module Entities
        WEST_RIVER_HEXES = %w[A4 A6 B3 B5 C2 C4 C6 D3 D5 D7 E2 E4 E6 E8 F3 F5 F7 F9 F11 G2 G4 G6 G8 G10 H3 H5 H7 H9
                              I2 I4 I6 I8 I10 J3 J5 J7 J9 K2 K4 K6 K8 K10 L3 L5 L7 L9 L11 M4 M6 M8 M10].freeze
        COMPANIES = [
        {
          name: 'Great River Shipping Company',
          value: 20,
          revenue: 5,
          desc: 'The GRSC has no special features.',
          sym: 'GRSC',
          color: nil,
        },
        {
          name: 'Crédit Mobilier',
          value: 40,
          revenue: 10,
          desc: 'If the Union Pacific purchases this private company, it may pay up to triple the face value to the'\
                ' owner of the Crédit Mobilier. If the Crédit Mobilier is owned by any corporation, the president always'\
                ' gets the $10 income. The corporation owning the Crédit Mobilier may do one extra yellow tile lay west'\
                ' of the Mississippi River.'\
                ' This company survives until phase six as a non-revenue paying company if the extra track lay has not'\
                ' yet been used.',
          sym: 'CM',
          abilities: [
            {
              type: 'tile_lay',
              owner_type: 'corporation',
              count: 1,
              reachable: true,
              special: false,
              when: 'track',
              hexes: WEST_RIVER_HEXES,
              tiles: %w[1 2 3 4 5 6 7 8 9 55 56 57 58 69],
            },
          ],
          color: nil,
        },
        {
          name: 'Mississippi River Bridge Company',
          value: 40,
          revenue: 10,
          desc: 'This private company gives the purchasing company a free bridge over the Mississippi River at'\
                ' St. Louis (i.e: a free track lay in the St. Louis hex. For the Missouri Pacific this track lay'\
                ' is in addition to and may be performed before its normal track lay/upgrade.'\
                ' This private company may be sold during phase two for from half to full face value. If a company'\
                ' uses this private to lay the St. Louis hex, it may not upgrade that hex in the same operating turn.',
          sym: 'MRB',
          abilities: [
            {
              type: 'tile_lay',
              owner_type: 'corporation',
              count: 1,
              reachable: true,
              special: false,
              when: 'track',
              hexes: ['L13'],
              discount: 40,
              tiles: %w[5 6 57],
            },
            { type: 'blocks_hexes', owner_type: 'player', hexes: %w[L13] },
          ],
          color: nil,
        },
        {
          name: 'Gant Brothers Construction Company',
          value: 50,
          revenue: 10,
          desc: 'The owning corporation may purchase an additional yellow track lay each turn for $30. The'\
                ' corporation must also pay any additional terrain costs. This track lay is in addition to any'\
                ' track lay or upgrade it is allowed to do.'\
                ' This company survives until phase six as a non-revenue paying company.',
          sym: 'GBC',
          abilities: [
            type: 'tile_lay',
            owner_type: 'corporation',
            reachable: true,
            special: false,
            when: 'track',
            hexes: [],
            tiles: %w[1 2 3 4 5 6 7 8 9 55 56 57 58 69],
            count_per_or: 1,
            cost: 30,
          ],
          color: nil,
        },
        {
          name: 'Mesabi Mining Company',
          value: 80,
          revenue: 15,
          desc: 'Comes with a Mesabi Range token.'\
                ' '\
                ' The Mesabi Mining Company gives the owning corporation a token for the Mesabi Range without further'\
                ' cost. When other corporations connect to the Mesabi Range, the corporation owning the Mesabi Mining'\
                ' Company receives $40 (half of the $80 connection fee). The owning corporation stops receiving this'\
                ' payment when the private company is closed.'\
                ' '\
                ' This company may be bought in during phase two from half to full face value. '\
                ' '\
                ' The company closes on the first 5T, but the owning corporation always has the right to the Mesabi'\
                ' Range. No corporation may connect to the Mesabi Range until the Mesabi Mining Company has been bought'\
                ' into a corporation or closed by the sale of the first 5T. There are four Mesabi Range tokens. Max one'\
                ' per corporation.',
          sym: 'MRC',
          color: nil,
        },
        {
          name: 'Western Land Grant Company',
          value: 90,
          revenue: 20,
          desc: 'The corporation owning the Western Land Grant is allowed extra construction of yellow track. During'\
                ' the track laying phase, the owning corporation is allowed to lay a second tile which must be yellow. The'\
                ' owning corporation may do this up to three times. Two of these track lays must be used west of the'\
                ' Mississippi river, one may be used anywhere on the map. If none of the track lays have been used, this'\
                ' company survives until phase six as a non-revenue company.',
          sym: 'WLG',
          abilities: [{
            type: 'tile_lay',
            owner_type: 'corporation',
            count: 3,
            count_per_or: 1,
            reachable: true,
            special: false,
            when: 'track',
            hexes: [],
            tiles: %w[1 2 3 4 5 6 7 8 9 55 56 57 58 69],
          }],
          color: nil,
        },
        {
          name: 'Mississippi and Missouri Railroad',
          value: 160,
          revenue: 20,
          desc: 'Comes with a share of the Chicago, Rock Island and Pacific Railway.',
          sym: 'MMR',
          abilities: [{
            type: 'shares',
            shares: 'RI_1',
          },
                      { type: 'blocks_hexes', owner_type: 'player', hexes: %w[I12] }],
          color: nil,
        },
        ].freeze

        CORPORATIONS = [
        {
          float_percent: 60,
          sym: 'CBQ',
          name: 'Chicago Burlington & Quincy Railroad',
          logo: '1850/CBQ',
          simple_logo: '1850/CBQ.alt',
          tokens: [0, 40, 100, 100],
          coordinates: 'I18',
          city: 1,
          color: '#37383a',
          reservation_color: nil,
        },
        {
          float_percent: 60,
          sym: 'MILW',
          name: 'Chicago Milwaukee, St. Paul & Pacific Railroad',
          logo: '1850/MILW',
          simple_logo: '1850/MILW.alt',
          tokens: [0, 40, 100],
          coordinates: 'G18',
          abilities: [{ type: 'assign_hexes', hexes: ['A2'], count: 1, cost: 50 }],
          color: '#f48221',
          reservation_color: nil,
        },
        {
          float_percent: 60,
          sym: 'RI',
          name: 'Chicago, Rock Island and Pacific Railway',
          logo: '1850/RI',
          simple_logo: '1850/RI.alt',
          tokens: [0, 40, 100, 100],
          coordinates: 'H11',
          color: '#76a042',
          reservation_color: nil,
        },
        {
          float_percent: 60,
          sym: 'GN',
          name: 'Great Northern Railway',
          logo: '1850/GN',
          simple_logo: '1850/GN.alt',
          tokens: [0, 40, 100],
          coordinates: 'D9',
          abilities: [{ type: 'assign_hexes', hexes: ['A2'], count: 1, cost: 50 }],
          color: '#d81e3e',
          reservation_color: nil,
        },
        {
          float_percent: 60,
          sym: 'KATY',
          name: 'Missouri-Kansas-Texas Railroad',
          logo: '1850/KATY',
          simple_logo: '1850/KATY.alt',
          tokens: [0, 40, 100],
          coordinates: 'K6',
          abilities: [{ type: 'assign_hexes', hexes: ['M2'], count: 1, cost: 50 }],
          color: '#00a993',
          reservation_color: nil,
        },
        {
          float_percent: 60,
          sym: 'MP',
          name: 'Missouri Pacific Railroad',
          logo: '1850/MP',
          simple_logo: '1850/MP.alt',
          tokens: [0, 40, 100],
          coordinates: 'L13',
          color: '#0189d1',
          reservation_color: nil,
        },
        {
          float_percent: 60,
          sym: 'NP',
          name: 'Northern Pacific Railway',
          logo: '1850/NP',
          simple_logo: '1850/NP.alt',
          tokens: [0, 40, 100],
          coordinates: 'B11',
          abilities: [{ type: 'assign_hexes', hexes: ['A2'], count: 1, cost: 50 },
                      {
                        type: 'assign_corporation',
                        count: 1,
                      }],
          color: '#7b352a',
          reservation_color: nil,
        },
        {
          float_percent: 60,
          sym: 'SOO',
          name: 'Soo Line Railroad',
          logo: '1850/SOO',
          simple_logo: '1850/SOO.alt',
          tokens: [0, 40, 100],
          coordinates: 'F13',
          abilities: [{ type: 'assign_hexes', hexes: ['C20'], count: 1, cost: 50 }],
          color: '#7b352a',
          reservation_color: nil,
        },
        {
          float_percent: 60,
          sym: 'UP',
          name: 'Union Pacific Railroad',
          logo: '1850/UP',
          simple_logo: '1850/UP.alt',
          tokens: [0, 40, 100],
          coordinates: 'I4',
          abilities: [{ type: 'assign_hexes', hexes: ['F1'], count: 1, cost: 50 }],
          color: '#7b352a',
          reservation_color: nil,
        },
        ].freeze
      end
    end
  end
end
