# frozen_string_literal: true

module Engine
  module Game
    module G18Chesapeake
      module Entities
        COMPANIES = [
          {
            name: 'Delaware and Raritan Canal',
            value: 20,
            revenue: 5,
            desc: 'No special ability. Blocks hex K3 while owned by a player.',
            sym: 'D&R',
            abilities: [{ type: 'blocks_hexes', owner_type: 'player', hexes: ['K3'] }],
            color: nil,
          },
          {
            name: 'Columbia - Philadelphia Railroad',
            value: 40,
            revenue: 10,
            desc: 'Blocks hexes H2 and I3 while owned by a player. The owning corporation may lay two connected tiles in hexes '\
                  'H2 and I3. Only #8 and #9 tiles may be used. If any tiles are played in these hexes other than by using '\
                  'this ability, the ability is forfeit. These tiles may be placed even if the owning corporation does not '\
                  'have a route to the hexes. These tiles are laid during the tile laying step and are in addition to the '\
                  'corporation’s tile placement action.',
            sym: 'C-P',
            abilities: [{ type: 'blocks_hexes', owner_type: 'player', hexes: %w[H2 I3] },
                        {
                          type: 'tile_lay',
                          owner_type: 'corporation',
                          must_lay_together: true,
                          must_lay_all: true,
                          hexes: %w[H2 I3],
                          tiles: %w[8 9],
                          when: 'track',
                          count: 2,
                        }],
            color: nil,
          },
          {
            name: 'Baltimore and Susquehanna Railroad',
            value: 50,
            revenue: 10,
            desc: 'Blocks hexes F4 and G5 while owned by a player. The owning corporation may lay two connected tiles in hexes '\
                  'F4 and G5. Only #8 and #9 tiles may be used. If any tiles are played in these hexes other than by using this '\
                  'ability, the ability is forfeit. These tiles may be placed even if the owning corporation does not have a '\
                  'route to the hexes. These tiles are laid during the tile laying step and are in addition to the corporation’s'\
                  ' tile placement action.',
            sym: 'B&S',
            abilities: [{ type: 'blocks_hexes', owner_type: 'player', hexes: %w[F4 G5] },
                        {
                          type: 'tile_lay',
                          owner_type: 'corporation',
                          must_lay_together: true,
                          must_lay_all: true,
                          hexes: %w[F4 G5],
                          tiles: %w[8 9],
                          when: 'track',
                          count: 2,
                        }],
            color: nil,
          },
          {
            name: 'Chesapeake and Ohio Canal',
            value: 80,
            revenue: 15,
            desc: 'Blocks hex D2 while owned by a player. The owning corporation may place a tile in hex D2. The corporation '\
                  'does not need to have a route to this hex. The tile placed counts as the corporation’s tile lay action and '\
                  'the corporation must pay the terrain cost. The corporation may then immediately place a station token free '\
                  'of charge.',
            sym: 'C&OC',
            abilities: [{ type: 'blocks_hexes', owner_type: 'player', hexes: ['D2'] },
                        {
                          type: 'teleport',
                          owner_type: 'corporation',
                          tiles: ['57'],
                          hexes: ['D2'],
                        }],
            color: nil,
          },
          {
            name: 'Baltimore & Ohio Railroad',
            value: 100,
            revenue: 0,
            desc: 'Purchasing player immediately takes a 10% share of the B&O. This does not close the private company. This '\
                  'private company has no other special ability.',
            sym: 'B&OR',
            abilities: [{ type: 'shares', shares: 'B&O_1' }],
            color: nil,
          },
          {
            name: 'Cornelius Vanderbilt',
            value: 200,
            revenue: 30,
            desc: 'This private closes when the associated corporation buys its first train. It cannot be bought by a '\
                  'corporation.',
            sym: 'CV',
            abilities: [{ type: 'shares', shares: 'random_president' },
                        { type: 'no_buy' }],
            color: nil,
          },
        ].freeze

        CORPORATIONS = [
          {
            float_percent: 60,
            sym: 'PRR',
            name: 'Pennsylvania Railroad',
            logo: '18_chesapeake/PRR',
            simple_logo: '18_chesapeake/PRR.alt',
            tokens: [0, 40, 60, 80],
            coordinates: 'F2',
            color: '#237333',
            reservation_color: nil,
          },
          {
            float_percent: 60,
            sym: 'PLE',
            name: 'Pittsburgh and Lake Erie Railroad',
            logo: '18_chesapeake/PLE',
            simple_logo: '18_chesapeake/PLE.alt',
            tokens: [0, 40, 60],
            coordinates: 'A3',
            color: :black,
            reservation_color: nil,
          },
          {
            float_percent: 60,
            sym: 'SRR',
            name: 'Strasburg Rail Road',
            logo: '18_chesapeake/SRR',
            simple_logo: '18_chesapeake/SRR.alt',
            tokens: [0, 40],
            coordinates: 'H4',
            color: '#d81e3e',
            reservation_color: nil,
          },
          {
            float_percent: 60,
            sym: 'B&O',
            name: 'Baltimore & Ohio Railroad',
            logo: '18_chesapeake/BO',
            simple_logo: '18_chesapeake/BO.alt',
            tokens: [0, 40, 60],
            coordinates: 'H6',
            city: 0,
            color: '#0189d1',
            reservation_color: nil,
          },
          {
            float_percent: 60,
            sym: 'C&O',
            name: 'Chesapeake & Ohio Railroad',
            logo: '18_chesapeake/CO',
            simple_logo: '18_chesapeake/CO.alt',
            tokens: [0, 40, 60, 80],
            coordinates: 'G13',
            color: '#a2dced',
            text_color: 'black',
            reservation_color: nil,
          },
          {
            float_percent: 60,
            sym: 'LV',
            name: 'Lehigh Valley Railroad',
            logo: '18_chesapeake/LV',
            simple_logo: '18_chesapeake/LV.alt',
            tokens: [0, 40],
            coordinates: 'J2',
            color: '#FFF500',
            text_color: 'black',
            reservation_color: nil,
          },
          {
            float_percent: 60,
            sym: 'C&A',
            name: 'Camden & Amboy Railroad',
            logo: '18_chesapeake/CA',
            simple_logo: '18_chesapeake/CA.alt',
            tokens: [0, 40],
            coordinates: 'J6',
            color: '#f48221',
            reservation_color: nil,
          },
          {
            float_percent: 60,
            sym: 'N&W',
            name: 'Norfolk & Western Railway',
            logo: '18_chesapeake/NW',
            simple_logo: '18_chesapeake/NW.alt',
            tokens: [0, 40, 60],
            coordinates: 'C13',
            color: '#7b352a',
            reservation_color: nil,
          },
        ].freeze
      end
    end
  end
end
