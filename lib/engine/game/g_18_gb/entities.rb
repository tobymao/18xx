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
            desc: "The owner of the LB has priority for starting the LNWR. No other player may buy the Director's " \
                  'Certificate of the LNWR, and the owner of the London & Birmingham may not buy shares in any other ' \
                  "corporation until they have purchased the LNWR Director's Certificate.",
            sym: 'LB',
            color: nil,
            abilities: [
              {
                type: 'blocks_hexes',
                owner_type: 'player',
                hexes: ['F21'],
              },
              {
                type: 'choose_ability',
                owner_type: 'player',
                when: 'any',
                choices: { close: 'Close LB' },
              },
            ],
          },
          {
            name: 'Arbroath & Forfar',
            value: 30,
            revenue: 10,
            desc: 'The Arbroath & Forfar allows a corporation to take an extra tile action to lay or upgrade a tile in Perth ' \
                  '(I2). The owner of the AF may use this ability once per game, after the AF has closed, for any ' \
                  'corporation which they control. A tile placed in Perth as a normal tile lay does not close the AF.',
            sym: 'AF',
            color: nil,
            abilities: [
              {
                type: 'blocks_hexes',
                owner_type: 'player',
                hexes: ['K2'],
              },
              {
                type: 'choose_ability',
                owner_type: 'player',
                when: 'any',
                choices: { close: 'Close AF' },
              },
              {
                type: 'tile_lay',
                when: 'owning_player_track',
                owner_type: 'player',
                hexes: ['I2'],
                tiles: %w[G39 G40 G41 G36 G37 G38 G30 G34],
                reachable: true,
                special: false,
                count: 1,
              },
            ],
          },
          {
            name: 'Great Northern',
            value: 70,
            revenue: 25,
            desc: 'The GN allows a corporation to lay an additional station token in York (I14). A space is reserved for ' \
                  'the GN until the blue phase, otherwise an empty space must be available in York. The GN owner may use ' \
                  'this ability once per game, after the GN has closed, for any corporation which they control. The token ' \
                  'is free if the corporation can trace a route to York, otherwise it costs £50. The token is in addition to ' \
                  'the standard station tokens of the corporation. After laying the token, the corporation also gains the ' \
                  'ability to lay a green tile in York as one of its standard tile actions, instead of the usual yellow tile, ' \
                  'even before green tiles are normally available.',
            sym: 'GN',
            color: nil,
            abilities: [
              {
                type: 'blocks_hexes',
                owner_type: 'player',
                hexes: ['I18'],
              },
              {
                type: 'choose_ability',
                owner_type: 'player',
                when: 'any',
                choices: { close: 'Close GN' },
              },
              {
                type: 'reservation',
                hex: 'I14',
                remove: '4+2',
              },
              {
                type: 'token',
                hexes: ['I14'],
                teleport_price: 50,
                price: 0,
                count: 1,
                extra_action: false,
                from_owner: false,
                special_only: true,
              },
            ],
          },
          {
            name: 'Stockton & Darlington',
            value: 35,
            revenue: 12,
            desc: 'The SD gives a bonus of £10 for Middlesbrough (J13). The owner of the SD may use this bonus for any ' \
                  'trains owned by corporations that they control, from the time that the SD closes until the end of the game.',
            sym: 'SD',
            color: nil,
            abilities: [
              {
                type: 'blocks_hexes',
                owner_type: 'player',
                hexes: ['I12'],
              },
              {
                type: 'choose_ability',
                owner_type: 'player',
                when: 'any',
                choices: { close: 'Close SD' },
              },
              {
                type: 'hex_bonus',
                owner_type: 'player',
                amount: 10,
                hexes: ['J13'],
              },
            ],
          },
          {
            name: 'Liverpool & Manchester',
            value: 45,
            revenue: 15,
            desc: 'The LM gives a bonus of £30 for Liverpool (E14). The owner of the LM may use this bonus for any trains ' \
                  'run by corporations that they control, from the time that the LM closes until the end of the game.',
            sym: 'LM',
            color: nil,
            abilities: [
              {
                type: 'blocks_hexes',
                owner_type: 'player',
                hexes: ['F15'],
              },
              {
                type: 'choose_ability',
                owner_type: 'player',
                when: 'any',
                choices: { close: 'Close LM' },
              },
              {
                type: 'hex_bonus',
                owner_type: 'player',
                amount: 30,
                hexes: ['E14'],
              },
            ],
          },
          {
            name: 'Leicester & Swannington',
            value: 30,
            revenue: 10,
            desc: 'The LS allows a corporation to take an extra tile action to lay or upgrade a tile in Leicester (H21). The ' \
                  'owner of the LS may use this ability once per game, after the LS has closed, for any corporation which '\
                  'they control.',
            sym: 'LS',
            color: nil,
            abilities: [
              {
                type: 'blocks_hexes',
                owner_type: 'player',
                hexes: ['H21'],
              },
              {
                type: 'choose_ability',
                owner_type: 'player',
                when: 'any',
                choices: { close: 'Close LS' },
              },
              {
                type: 'tile_lay',
                owner_type: 'player',
                hexes: ['H21'],
                tiles: %w[G18 G19 G21 G22 G24 G26 G27 G28 G30],
                reachable: true,
                special: false,
                count: 1,
              },
            ],
          },
          {
            name: 'Taff Vale',
            value: 60,
            revenue: 25,
            desc: 'The TV allows a corporation to waive the cost of laying the Severn Tunnel tile - the blue estuary tile ' \
                  'marked "S" - in hex C22. This follows the usual rules for upgrades, so the game must be in an appropriate ' \
                  'phase, some part of the new track on the new tile must form part of a route for the corporation, and the ' \
                  'corporation must not be Insolvent. The owner of the TV may use this ability after the TV has closed, for ' \
                  'any corporation which they control. If a corporation places the Severn Tunnel tile without using the ' \
                  'ability of the TV, this does not force the TV to close.',
            sym: 'TV',
            color: nil,
            abilities: [
              {
                type: 'blocks_hexes',
                owner_type: 'player',
                hexes: ['C20'],
              },
              {
                type: 'choose_ability',
                owner_type: 'player',
                when: 'any',
                choices: { close: 'Close TV' },
              },
              {
                type: 'tile_lay',
                owner_type: 'player',
                when: 'owning_player_track',
                hexes: ['C22'],
                tiles: ['G33'],
                discount: 50,
                special: false,
                reachable: true,
                consume_tile_lay: true,
                count: 1,
              },
            ],
          },
          {
            name: 'Maryport & Carlisle',
            value: 50,
            revenue: 20,
            desc: 'The MC allows a corporation to lay an additional station token in Carlisle (H9). A space is reserved for ' \
                  'the MC until the blue phase, otherwise an empty space must be available in Carlisle. The MC owner may use ' \
                  'this ability once per game, after the MC has closed, for any corporation which they control. The token ' \
                  'is free if the corporation can trace a route to Carlisle, otherwise it costs £50.  The token is in ' \
                  'addition to the standard station tokens of the corporation. After laying the token, the corporation also ' \
                  'gains the ability to lay a green tile in Carlisle as one of its standard tile actions, instead of the ' \
                  'usual yellow tile, even before green tiles are normally available.',
            sym: 'MC',
            color: nil,
            abilities: [
              {
                type: 'blocks_hexes',
                owner_type: 'player',
                hexes: ['G10'],
              },
              {
                type: 'choose_ability',
                owner_type: 'player',
                when: 'any',
                choices: { close: 'Close MC' },
              },
              {
                type: 'reservation',
                hex: 'H9',
                remove: '4+2',
              },
              {
                type: 'token',
                hexes: ['H9'],
                teleport_price: 50,
                price: 0,
                count: 1,
                extra_action: false,
                from_owner: false,
                special_only: true,
              },
            ],
          },
          {
            name: 'Chester & Holyhead',
            value: 30,
            revenue: 10,
            desc: 'The CH gives a bonus income of £20 for Holyhead (C14). The owner of the CH may use this bonus for any ' \
                  'trains run by corporations that they control, from the time that the CH closes until the end of the game.',
            sym: 'CH',
            color: nil,
            abilities: [
              {
                type: 'blocks_hexes',
                owner_type: 'player',
                hexes: ['E16'],
              },
              {
                type: 'choose_ability',
                owner_type: 'player',
                when: 'any',
                choices: { close: 'Close CH' },
              },
              {
                type: 'hex_bonus',
                owner_type: 'player',
                amount: 20,
                hexes: ['C14'],
              },
            ],
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
            coordinates: 'G4',
            color: '#0a70b3',
            reservation_color: nil,
            always_market_price: true,
            max_ownership_percent: 100,
            abilities: [
              {
                type: 'base',
                description: 'Conversion tokens: 2',
                desc_detail: 'Receives 2 additional £50 tokens on the charter when converted to a 10-share corporation',
                count: 2,
              },
            ],
          },
          {
            sym: 'GER',
            name: 'Great Eastern Railway',
            type: '5-share',
            float_percent: 40,
            logo: '18_gb/GER',
            shares: [40, 20, 20, 20],
            tokens: [0, 50],
            coordinates: 'J25',
            color: '#37b2e2',
            reservation_color: nil,
            always_market_price: true,
            max_ownership_percent: 100,
            abilities: [
              {
                type: 'base',
                description: 'Conversion tokens: 2',
                desc_detail: 'Receives 2 additional £50 tokens on the charter when converted to a 10-share corporation',
                count: 2,
              },
              {
                type: 'tile_lay',
                hexes: ['J25'],
                tiles: %w[G36 G37 G38],
                cost: 0,
                reachable: true,
                consume_tile_lay: true,
                description: 'May place a green tile in J25',
                desc_detail: 'May place a green tile in its home city (J25), instead of the usual yellow tile, even before ' \
                             'green tiles are normally available',
              },
            ],

          },
          {
            sym: 'GSWR',
            name: 'Glasgow and South Western Railway',
            type: '5-share',
            float_percent: 40,
            logo: '18_gb/GSWR',
            shares: [40, 20, 20, 20],
            tokens: [0, 50],
            coordinates: 'F5',
            color: '#ec767c',
            reservation_color: nil,
            always_market_price: true,
            max_ownership_percent: 100,
            abilities: [
              {
                type: 'base',
                description: 'Conversion tokens: 2',
                desc_detail: 'Receives 2 additional £50 tokens on the charter when converted to a 10-share corporation',
                count: 2,
              },
              {
                type: 'tile_lay',
                hexes: ['F5'],
                tiles: %w[G36 G37 G38],
                cost: 0,
                reachable: true,
                consume_tile_lay: true,
                description: 'May place a green tile in F5',
                desc_detail: 'May place a green tile in its home city (F5), instead of the usual yellow tile, even before ' \
                             'green tiles are normally available',
              },
            ],
          },
          {
            sym: 'GWR',
            name: 'Great Western Railway',
            type: '5-share',
            float_percent: 40,
            logo: '18_gb/GWR',
            shares: [40, 20, 20, 20],
            tokens: [0, 50],
            coordinates: 'D23',
            color: '#008f4f',
            reservation_color: nil,
            always_market_price: true,
            max_ownership_percent: 100,
            abilities: [
              {
                type: 'base',
                description: 'Conversion tokens: 2',
                desc_detail: 'Receives 2 additional £50 tokens on the charter when converted to a 10-share corporation',
                count: 2,
              },
            ],
          },
          {
            sym: 'LNWR',
            name: 'London and North Western Railway',
            type: '5-share',
            float_percent: 40,
            logo: '18_gb/LNWR',
            shares: [40, 20, 20, 20],
            tokens: [0, 50],
            coordinates: 'F21',
            color: '#0a0a0a',
            text_color: '#ffffff',
            reservation_color: nil,
            always_market_price: true,
            max_ownership_percent: 100,
            abilities: [
              {
                type: 'base',
                description: 'Conversion tokens: 2',
                desc_detail: 'Receives 2 additional £50 tokens on the charter when converted to a 10-share corporation',
                count: 2,
              },
            ],
          },
          {
            sym: 'LSWR',
            name: 'London and South Western Railway',
            type: '5-share',
            float_percent: 40,
            logo: '18_gb/LSWR',
            shares: [40, 20, 20, 20],
            tokens: [0, 50],
            coordinates: 'D25',
            color: '#fcea18',
            text_color: '#000000',
            reservation_color: nil,
            always_market_price: true,
            max_ownership_percent: 100,
            abilities: [
              {
                type: 'base',
                description: 'Conversion tokens: 2',
                desc_detail: 'Receives 2 additional £50 tokens on the charter when converted to a 10-share corporation',
                count: 2,
              },
            ],
          },
          {
            sym: 'LYR',
            name: 'Lancashire and Yorkshire Railway',
            type: '5-share',
            float_percent: 40,
            logo: '18_gb/LYR',
            shares: [40, 20, 20, 20],
            tokens: [0],
            coordinates: 'H15',
            color: '#baa4cb',
            text_color: '#000000',
            reservation_color: nil,
            always_market_price: true,
            max_ownership_percent: 100,
            abilities: [
              {
                type: 'base',
                description: 'Conversion tokens: 2',
                desc_detail: 'Receives 2 additional £50 tokens on the charter when converted to a 10-share corporation',
                count: 2,
              },
            ],
          },
          {
            sym: 'MR',
            name: 'Midland Railway',
            type: '5-share',
            float_percent: 40,
            logo: '18_gb/MR',
            shares: [40, 20, 20, 20],
            tokens: [0, 50],
            coordinates: 'H19',
            color: '#dd0030',
            reservation_color: nil,
            always_market_price: true,
            max_ownership_percent: 100,
            abilities: [
              {
                type: 'base',
                description: 'Conversion tokens: 2',
                desc_detail: 'Receives 2 additional £50 tokens on the charter when converted to a 10-share corporation',
                count: 2,
              },
              {
                type: 'tile_lay',
                hexes: ['H19'],
                tiles: %w[G36 G37 G38],
                cost: 0,
                reachable: true,
                consume_tile_lay: true,
                description: 'May place a green tile in H19',
                desc_detail: 'May place a green tile in its home city (H19), instead of the usual yellow tile, even before ' \
                             'green tiles are normally available',
              },
            ],
          },
          {
            sym: 'MSLR',
            name: 'Manchester, Sheffield and Lincolnshire Railway',
            type: '5-share',
            float_percent: 40,
            logo: '18_gb/MSLR',
            shares: [40, 20, 20, 20],
            tokens: [0],
            coordinates: 'H17',
            color: '#881a1e',
            reservation_color: nil,
            always_market_price: true,
            max_ownership_percent: 100,
            abilities: [
              {
                type: 'base',
                description: 'Conversion tokens: 2',
                desc_detail: 'Receives 2 additional £50 tokens on the charter when converted to a 10-share corporation',
                count: 2,
              },
            ],
          },
          {
            sym: 'NBR',
            name: 'North British Railway',
            type: '5-share',
            float_percent: 40,
            logo: '18_gb/NBR',
            shares: [40, 20, 20, 20],
            tokens: [0, 50],
            coordinates: 'I6',
            color: '#eb6f0e',
            reservation_color: nil,
            always_market_price: true,
            max_ownership_percent: 100,
            abilities: [
              {
                type: 'base',
                description: 'Conversion tokens: 1',
                desc_detail: 'Receives 1 additional £50 token on the charter when converted to a 10-share corporation',
                count: 1,
              },
            ],
          },
          {
            sym: 'NER',
            name: 'North Eastern Railway',
            type: '5-share',
            float_percent: 40,
            logo: '18_gb/NER',
            shares: [40, 20, 20, 20],
            tokens: [0, 50],
            coordinates: 'J13',
            color: '#7bb137',
            reservation_color: nil,
            always_market_price: true,
            max_ownership_percent: 100,
            abilities: [
              {
                type: 'base',
                description: 'Conversion tokens: 2',
                desc_detail: 'Receives 2 additional £50 tokens on the charter when converted to a 10-share corporation',
                count: 2,
              },
              {
                type: 'tile_lay',
                hexes: ['J13'],
                tiles: %w[G36 G37 G38],
                cost: 0,
                reachable: true,
                consume_tile_lay: true,
                description: 'May place a green tile in J13',
                desc_detail: 'May place a green tile in its home city (J13), instead of the usual yellow tile, even before ' \
                             'green tiles are normally available',
              },
            ],
          },
          {
            sym: 'SWR',
            name: 'South Wales Railway',
            type: '5-share',
            float_percent: 40,
            logo: '18_gb/SWR',
            shares: [40, 20, 20, 20],
            tokens: [0, 50],
            coordinates: 'A20',
            color: '#9a9a9d',
            text_color: '#000000',
            reservation_color: nil,
            always_market_price: true,
            max_ownership_percent: 100,
            abilities: [
              {
                type: 'base',
                description: 'Conversion tokens: 2',
                desc_detail: 'Receives 2 additional £50 tokens on the charter when converted to a 10-share corporation',
                count: 2,
              },
              {
                type: 'tile_lay',
                hexes: ['A20'],
                tiles: %w[G36 G37 G38],
                cost: 0,
                reachable: true,
                consume_tile_lay: true,
                description: 'May place a green tile in A20',
                desc_detail: 'May place a green tile in its home city (A20), instead of the usual yellow tile, even before ' \
                             'green tiles are normally available',
              },
            ],
          },
      ].freeze
      end
    end
  end
end
