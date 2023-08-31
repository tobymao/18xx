# frozen_string_literal: true

module Engine
  module Game
    module G18ChristmasEve
      module Entities
        COMPANIES = [
          {
            name: 'Stair Case Cleanup Co',
            value: 20,
            revenue: 5,
            desc: 'Blocks hex H9 while owned by a player.',
            sym: 'SCCC',
            abilities: [{ type: 'blocks_hexes', owner_type: 'player', hexes: ['H9'] }],
            color: nil,
          },
          {
            name: 'Dumbwaiter Excavation',
            value: 50,
            revenue: 10,
            desc: 'Blocks building a station at F3 while owned by a player.',
            sym: 'DW',
            abilities: [{ type: 'reservation', remove: 'sold', hex: 'F3' }],
            color: nil,
          },
          {
            name: "Dad's Intervention",
            value: 100,
            revenue: 0,
            desc: 'The player purchasing this cert also gains a 10% share of Baltimore and Ohio.',
            sym: 'DI',
            abilities: [{ type: 'shares', shares: 'B&O_1' }],
            color: nil,
          },
          {
            name: '"Santa"?',
            value: 200,
            revenue: 30,
            desc: 'This private closes when the associated corporation buys its first train. It cannot be bought by a '\
                  'corporation.',
            sym: 'SC',
            abilities: [{ type: 'shares', shares: 'random_president' },
                        { type: 'no_buy' }],
            color: nil,
          },
          {
            name: 'Egg Nog Express',
            value: 80,
            revenue: 15,
            desc: 'The owning company adds $40 to any train run that includes both the Bar (F7) and the DC hex (C10).',
            sym: 'ENX',
            color: nil,
          },
          {
            name: "Conductor's Hat",
            value: 40,
            revenue: 10,
            desc: 'Adds $10 per room stopped at at least once by any one train of the owning corporation. Red off-board '\
                  'locations do not count.',
            sym: 'CH',
            color: nil,
          },
        ].freeze

        CORPORATIONS = [
          {
            sym: 'PRR',
            name: 'Pennsylvania Railroad',
            logo: '18_chesapeake/PRR',
            simple_logo: '18_chesapeake/PRR.alt',
            tokens: [0, 40, 60, 80],
            coordinates: 'L11',
            color: '#237333',
          },
          {
            sym: 'PLE',
            name: 'Pittsburgh and Lake Erie Railroad',
            logo: '18_chesapeake/PLE',
            simple_logo: '18_chesapeake/PLE.alt',
            tokens: [0, 40, 60],
            coordinates: 'B3',
            color: :black,
          },
          {
            sym: 'SRR',
            name: 'Strasburg Rail Road',
            logo: '18_chesapeake/SRR',
            simple_logo: '18_chesapeake/SRR.alt',
            tokens: [0, 40],
            city: 1,
            coordinates: 'E12',
            color: '#d81e3e',
          },
          {
            sym: 'B&O',
            name: 'Baltimore & Ohio Railroad',
            logo: '18_chesapeake/BO',
            simple_logo: '18_chesapeake/BO.alt',
            tokens: [0, 40, 60],
            coordinates: 'J5',
            city: 0,
            color: '#0189d1',
          },
          {
            sym: 'C&O',
            name: 'Chesapeake & Ohio Railroad',
            logo: '18_chesapeake/CO',
            simple_logo: '18_chesapeake/CO.alt',
            tokens: [0, 40, 60, 80],
            coordinates: 'K2',
            color: '#a2dced',
            text_color: 'black',
          },
          {
            sym: 'LV',
            name: 'Lehigh Valley Railroad',
            logo: '18_chesapeake/LV',
            simple_logo: '18_chesapeake/LV.alt',
            tokens: [0, 40],
            coordinates: 'F9',
            color: '#FFF500',
            text_color: 'black',
          },
          {
            sym: 'C&A',
            name: 'Camden & Amboy Railroad',
            logo: '18_chesapeake/CA',
            simple_logo: '18_chesapeake/CA.alt',
            tokens: [0, 40],
            coordinates: 'J11',
            color: '#f48221',
          },
          {
            sym: 'N&W',
            name: 'Norfolk & Western Railway',
            logo: '18_chesapeake/NW',
            simple_logo: '18_chesapeake/NW.alt',
            tokens: [0, 40, 60],
            coordinates: 'E6',
            color: '#7b352a',
          },
        ].freeze
      end
    end
  end
end
