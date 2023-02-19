# frozen_string_literal: true

module Engine
  module Game
    module G1870
      module Entities
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
            name: 'Mississippi River Bridge Company',
            value: 40,
            revenue: 10,
            desc: 'Until this company is closed or sold to a public company, no company may bridge the Mississippi'\
                  ' River. A company may lay track along the river, but may not lay track to cross the river, or do an'\
                  ' upgrade that would cause track to cross the river. The public company that purchases the Mississippi'\
                  ' River Bridge Company may build in one of the hexes along the Mississippi River for a $40 discount.'\
                  ' This company may be purchased by one of the two companies on the Mississippi River (Missouri Pacific'\
                  ' or St.Louis Southwestern) in phase one for $20 to $40. If one of these two public companies purchases'\
                  ' this private company during their first operating round, that company can lay a tile at its starting'\
                  ' city for no cost and in addition to its normal tile lay(s). The company cannot lay a tile in their'\
                  ' starting city and upgrade it during the same operating round.',
            sym: 'MRBC',
            abilities: [
              {
                type: 'blocks_partition',
                partition_type: 'water',
                owner_type: 'player',
              },
              {
                type: 'tile_lay',
                owner_type: 'corporation',
                count: 1,
                reachable: true,
                special: false,
                when: 'track',
                discount: 40,
                hexes: %w[A16 B17 C18 D17 E18 F19 G18 H17 I16 J15 K14 L13 M14 N15 O16 O18],
                tiles: %w[1 2 3 4 5 6 7 8 9 55 56 57 58 69],
              },
            ],
            color: nil,
          },
          {
            name: 'The Southern Cattle Company',
            value: 50,
            revenue: 10,
            desc: 'This company has a token that may be placed on any city west of the Mississippi River. Cities'\
                  ' located in the same hex as any portion of the Mississippi are not eligible for this placement. This'\
                  ' increases the value of that city by $10 for that company only. Placing the token does not close the'\
                  ' company.',
            sym: 'SCC',
            abilities: [
              {
                type: 'assign_hexes',
                hexes: %w[B9 B11 D5 E12 F5 H13 J3 J5 L11 M2 M6 N7],
                when: 'owning_corp_or_turn',
                count: 1,
                owner_type: 'corporation',
              },
              {
                type: 'assign_corporation',
                when: 'sold',
                count: 1,
                owner_type: 'corporation',
              },
            ],
            color: nil,
          },
          {
            name: 'The Gulf Shipping Company',
            value: 80,
            revenue: 15,
            desc: 'This company has two tokens. One represents an open port and the other is a closed port. One (but'\
                  ' not both) of these tokens may be placed on one of the cities: Memphis (H17), Baton Rouge (M14), Mobile'\
                  ' (M20), Galveston (N7) and New Orleans (N17). Either token increases the value of the city for the owning'\
                  ' company by $20. The open port token also increases the value of the city for all other companies by $10.'\
                  ' If the president of the owning company places the closed port token, the private company is closed. If'\
                  ' the open port token is placed, it may be replaced in a later operating round by the closed port token,'\
                  ' closing the company.',
            sym: 'GSC',
            abilities: [
              {
                type: 'assign_hexes',
                hexes: %w[H17 M14 M20 N7 N17],
                count: 2,
                owner_type: 'corporation',
                when: 'owning_corp_or_turn',
              },
              {
                type: 'assign_corporation',
                when: 'sold',
                count: 1,
                owner_type: 'corporation',
              },
            ],
            color: nil,
          },
          {
            name: 'St.Louis-San Francisco Railway',
            value: 140,
            revenue: 0,
            desc: "This is the President's certificate of the St.Louis-San Francisco Railway. The purchaser sets the"\
                  ' par value of the railway. Unlike other companies, this company may operate with just 20% sold. It may'\
                  ' not be purchased by another public company.',
            sym: 'SLSF',
            abilities: [{ type: 'shares', shares: 'SLSF_0' }, { type: 'no_buy' }],
            color: nil,
          },
          {
            name: 'Missouri-Kansas-Texas Railroad',
            value: 160,
            revenue: 20,
            desc: 'Comes with a 10% share of the Missouri-Kansas-Texas Railroad.',
            sym: 'MKT',
            abilities: [{ type: 'shares', shares: 'MKT_1' }],
            color: nil,
          },
        ].freeze

        CORPORATIONS = [
          {
            float_percent: 60,
            sym: 'ATSF',
            name: 'Santa Fe',
            logo: '1870/ATSF',
            simple_logo: '1870/ATSF.alt',
            tokens: [0, 40, 100],
            abilities: [{ type: 'assign_hexes', hexes: ['N1'], count: 1 }],
            coordinates: 'B9',
            color: '#7090c9',
            text_color: 'black',
            reservation_color: nil,
          },
          {
            float_percent: 60,
            sym: 'SSW',
            name: 'Cotton',
            logo: '1870/SSW',
            simple_logo: '1870/SSW.alt',
            tokens: [0, 40],
            abilities: [{ type: 'assign_hexes', hexes: ['J3'], count: 1 }],
            coordinates: 'H17',
            color: '#111199',
            reservation_color: nil,
          },
          {
            float_percent: 60,
            sym: 'SP',
            name: 'Southern Pacific',
            logo: '1870/SP',
            simple_logo: '1870/SP.alt',
            tokens: [0, 40, 100],
            abilities: [{ type: 'assign_hexes', hexes: ['N17'], count: 1 }],
            coordinates: 'N1',
            color: '#f48221',
            reservation_color: nil,
          },
          {
            float_percent: 20,
            sym: 'SLSF',
            name: 'Frisco',
            logo: '1870/SLSF',
            simple_logo: '1870/SLSF.alt',
            tokens: [0, 40, 100],
            abilities: [{ type: 'assign_hexes', hexes: ['M22'], count: 1 }],
            coordinates: 'E12',
            color: '#d02020',
            reservation_color: nil,
          },
          {
            float_percent: 60,
            sym: 'MP',
            name: 'Missouri Pacific',
            logo: '1870/MP',
            simple_logo: '1870/MP.alt',
            tokens: [0, 40, 100],
            abilities: [{ type: 'assign_hexes', hexes: ['J5'], count: 1 }],
            coordinates: 'C18',
            color: '#5b4545',
            reservation_color: nil,
          },
          {
            float_percent: 60,
            sym: 'MKT',
            name: 'Katy',
            logo: '1870/MKT',
            simple_logo: '1870/MKT.alt',
            tokens: [0, 40, 100],
            abilities: [{ type: 'assign_hexes', hexes: ['N1'], count: 1 }],
            coordinates: 'B11',
            color: '#018471',
            reservation_color: nil,
          },
          {
            float_percent: 60,
            sym: 'IC',
            name: 'Illinois Central',
            logo: '1870/IC',
            simple_logo: '1870/IC.alt',
            tokens: [0, 40],
            abilities: [{ type: 'assign_hexes', hexes: ['A22'], count: 1 }],
            coordinates: 'K16',
            color: '#b0b030',
            reservation_color: nil,
          },
          {
            float_percent: 60,
            sym: 'GMO',
            name: 'Gulf Mobile Ohio',
            logo: '1870/GMO',
            simple_logo: '1870/GMO.alt',
            tokens: [0, 40],
            abilities: [{ type: 'assign_hexes', hexes: ['C18'], count: 1 }],
            coordinates: 'M20',
            color: '#ff4080',
            text_color: 'black',
            reservation_color: nil,
          },
          {
            float_percent: 60,
            sym: 'FW',
            name: 'Fort Worth',
            logo: '1870/FW',
            simple_logo: '1870/FW.alt',
            tokens: [0, 40],
            abilities: [{ type: 'assign_hexes', hexes: ['A2'], count: 1 }],
            coordinates: 'J3',
            color: '#56ad9a',
            text_color: 'black',
            reservation_color: nil,
          },
          {
            float_percent: 60,
            sym: 'TP',
            name: 'Texas Pacific',
            logo: '1870/TP',
            simple_logo: '1870/TP.alt',
            tokens: [0, 40],
            abilities: [{ type: 'assign_hexes', hexes: ['N17'], count: 1 }],
            coordinates: 'J5',
            color: '#37383a',
            reservation_color: nil,
          },
        ].freeze
      end
    end
  end
end
