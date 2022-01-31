# frozen_string_literal: true

module Engine
  module Game
    module G18GB
      module Entities
        COMPANIES = [
          {
            name: 'London & Birmingham',
            value: 40,
            revenue: 10,
            desc: "The owner of the L&B has priority for starting the LNWR. No other player may buy the Director's " \
                  'Certificate of the LNWR, and the owner of the London & Birmingham may not buy shares in any other company' \
                  "until they have purchased the LNWR Director's Certificate.",
            sym: 'LB',
            color: nil,
            abilities: [{ type: 'blocks_hexes', owner_type: 'player', hexes: ['G22'] }],
          },
          {
            name: 'Arbroath & Forfar',
            value: 30,
            revenue: 10,
            desc: 'The Arbroath & Forfar allows a company to take an extra tile lay action to lay or upgrade a tile in Perth ' \
                  '(J3). The owner of the AF may use this ability once per game, after the AF has closed, for any company ' \
                  'which they control. A tile placed in Perth as a nomral tile lay does not close the AF.',
            sym: 'AF',
            color: nil,
            abilities: [{ type: 'blocks_hexes', owner_type: 'player', hexes: ['L3'] }],
          },
          {
            name: 'Great Northern',
            value: 70,
            revenue: 25,
            desc: 'The GN allows a company to lay a free Station Marker in York (J15). The GN owner may use this ability once ' \
                  'per game, after the GN has closed, for any company which they control.',
            sym: 'GN',
            color: nil,
            abilities: [{ type: 'blocks_hexes', owner_type: 'player', hexes: ['J19'] }],
          },
          {
            name: 'Stockton & Darlington',
            value: 45,
            revenue: 15,
            desc: 'The SD gives a bonus of £10 for Middlesbrough (K14). The owner of the SD may use this bonus for any trains ' \
                  'owned by Companies that they control, from the time that the LM closes until the end of the game.',
            sym: 'SD',
            color: nil,
            abilities: [{ type: 'blocks_hexes', owner_type: 'player', hexes: ['J13'] }],
          },
          {
            name: 'Liverpool & Manchester',
            value: 45,
            revenue: 15,
            desc: 'The LM gives a bonus of £10 for Liverpool (F15). The owner of the LM may use this bonus for any trains run ' \
                  'by Companies that they control, from the time that the LM closes until the end of the game.',
            sym: 'LM',
            color: nil,
            abilities: [{ type: 'blocks_hexes', owner_type: 'player', hexes: ['G16'] }],
          },
          {
            name: 'Leicester & Swannington',
            value: 30,
            revenue: 10,
            desc: 'The LS allows a company to take an extra tile lay action to lay or upgrade a tile in Leicester (I22). The ' \
                  'owner of the LS may use this ability once per game, after the LS has closed, for any company which they ' \
                  'control.',
            sym: 'LS',
            color: nil,
            abilities: [{ type: 'blocks_hexes', owner_type: 'player', hexes: ['I22'] }],
          },
          {
            name: 'Taff Vale',
            value: 60,
            revenue: 20,
            desc: 'The TV allows a company to waive the cost of laying the Severn Tunnel tile - the blue estuary tile marked ' \
                  '"S" - in hex D23. This follows the usual rules for upgrades, so the game must be in an appropriate phase, ' \
                  'some part of the new track on the new tile must form part of a route for the company, and the company must ' \
                  'not be Insolvent. The owner of the TV may use this ability after the TV has closed, for any company which ' \
                  'they control. If a company places the Severn Tunnel tile without using the ability of the TV, this does not ' \
                  'force the TV to close.',
            sym: 'TV',
            color: nil,
            abilities: [{ type: 'blocks_hexes', owner_type: 'player', hexes: ['D21'] }],
          },
          {
            name: 'Maryport & Carlisle',
            value: 60,
            revenue: 20,
            desc: 'The MC allows a company to lay a Station Marker in Carlisle (I10). The MC owner may use this ability once ' \
                  'per game, after the MC has closed, for any company which they control.',
            sym: 'MC',
            color: nil,
            abilities: [{ type: 'blocks_hexes', owner_type: 'player', hexes: ['H11'] }],
          },
          {
            name: 'Chester & Holyhead',
            value: 30,
            revenue: 10,
            desc: 'The CH gives a bonus income of £20 for Holyhead (D15). The owner of the CH may use this bonus for any ' \
                  'trains run by Companies that they control, from the time that the CH closes until the end of the game.',
            sym: 'CH',
            color: nil,
            abilities: [{ type: 'blocks_hexes', owner_type: 'player', hexes: ['F17'] }],
          },
        ].freeze

        CORPORATIONS = [
          {
            sym: 'CR',
            name: 'Caledonian Railway',
            type: '5-share',
            float_percent: 40,
            logo: '18_gb/CR',
            shares: [40, 20, 20, 20],
            tokens: [0, 0],
            coordinates: 'H5',
            color: '#0a70b3',
            reservation_color: nil,
          },
          {
            sym: 'GER',
            name: 'Great Eastern Railway',
            type: '5-share',
            float_percent: 40,
            logo: '18_gb/GER',
            shares: [40, 20, 20, 20],
            tokens: [0, 50],
            coordinates: 'K26',
            color: '#37b2e2',
            reservation_color: nil,
          },
          {
            sym: 'GSWR',
            name: 'Glasgow and South Western Railway',
            type: '5-share',
            float_percent: 40,
            logo: '18_gb/GSWR',
            shares: [40, 20, 20, 20],
            tokens: [0, 50],
            coordinates: 'G6',
            color: '#ec767c',
            reservation_color: nil,
          },
          {
            sym: 'GWR',
            name: 'Great Western Railway',
            type: '5-share',
            float_percent: 40,
            logo: '18_gb/GWR',
            shares: [40, 20, 20, 20],
            tokens: [0, 50],
            coordinates: 'E24',
            color: '#008f4f',
            reservation_color: nil,
          },
          {
            sym: 'LNWR',
            name: 'London and North Western Railway',
            type: '5-share',
            float_percent: 40,
            logo: '18_gb/LNWR',
            shares: [40, 20, 20, 20],
            tokens: [0, 50],
            coordinates: 'G22',
            color: '#0a0a0a',
            text_color: '#ffffff',
            reservation_color: nil,
          },
          {
            sym: 'LSWR',
            name: 'London and South Western Railway',
            type: '5-share',
            float_percent: 40,
            logo: '18_gb/LSWR',
            shares: [40, 20, 20, 20],
            tokens: [0, 50],
            coordinates: 'E26',
            color: '#fcea18',
            reservation_color: nil,
          },
          {
            sym: 'LYR',
            name: 'Lancashire and Yorkshire Railway',
            type: '5-share',
            float_percent: 40,
            logo: '18_gb/LYR',
            shares: [40, 20, 20, 20],
            tokens: [0],
            coordinates: 'I16',
            color: '#baa4cb',
            reservation_color: nil,
          },
          {
            sym: 'MR',
            name: 'Midland Railway',
            type: '5-share',
            float_percent: 40,
            logo: '18_gb/MR',
            shares: [40, 20, 20, 20],
            tokens: [0, 50],
            coordinates: 'I20',
            color: '#dd0030',
            reservation_color: nil,
          },
          {
            sym: 'MSLR',
            name: 'Manchester, Sheffield and Lincolnshire Railway',
            type: '5-share',
            float_percent: 40,
            logo: '18_gb/MSLR',
            shares: [40, 20, 20, 20],
            tokens: [0],
            coordinates: 'I18',
            color: '#881a1e',
            reservation_color: nil,
          },
          {
            sym: 'NBR',
            name: 'North British Railway',
            type: '5-share',
            float_percent: 40,
            logo: '18_gb/NBR',
            shares: [40, 20, 20, 20],
            tokens: [0, 50],
            coordinates: 'J7',
            color: '#eb6f0e',
            reservation_color: nil,
          },
          {
            sym: 'NER',
            name: 'North Eastern Railway',
            type: '5-share',
            float_percent: 40,
            logo: '18_gb/NER',
            shares: [40, 20, 20, 20],
            tokens: [0, 50],
            coordinates: 'K14',
            color: '#7bb137',
            reservation_color: nil,
          },
          {
            sym: 'SWR',
            name: 'South Wales Railway',
            type: '5-share',
            float_percent: 40,
            logo: '18_gb/SWR',
            shares: [40, 20, 20, 20],
            tokens: [0, 50],
            coordinates: 'B21',
            color: '#9a9a9d',
            reservation_color: nil,
          },
      ].freeze
      end
    end
  end
end
