# frozen_string_literal: true

module Engine
  module Game
    module G1844
      module Entities
        MOUNTAIN_HEXES = %w[H7 L13 I14 G14 F19 J29 L23].freeze
        MOUNTAIN_TILES = %w[XM1 XM2 XM3].freeze

        TUNNEL_HEXES = %w[J9 I12 K14 I16 H17 H19 H21 H23 H27].freeze
        TUNNEL_TILES = %w[X78 X79].freeze

        COMPANIES = [
          {
            name: 'P1 - Brienzer-Rothorn-Bahn',
            sym: 'P1',
            value: 20,
            revenue: 5,
            desc: 'No special ability.',
            min_price: 1,
            max_price: 40,
          },
          {
            name: 'P2 - Bödelibahn',
            sym: 'P2',
            value: 50,
            revenue: 10,
            desc: 'Once in the game, a corporation may place an additional yellow track tile' \
                  ' according to the rules. Either that corporation or its director must be' \
                  ' the owner of the company.',
            min_price: 1,
            max_price: 100,
            abilities: [
              {
                type: 'tile_lay',
                after_phase: '2',
                when: %w[track owning_player_track],
                count: 1,
                reachable: true,
                special: false,
                tiles: %w[3 4 5 6 7 8 9 57 58],
                hexes: [],
              },
            ],
          },
          {
            name: 'P3 - Gotthard-Postkutsche',
            sym: 'P3',
            value: 80,
            revenue: 15,
            desc: 'Comes with a Tunnel company',
            min_price: 1,
            max_price: 160,
            abilities: [{ type: 'acquire_company', company: 'T1' }],
          },
          {
            name: 'P4 - Furka-Oberalpbahn',
            sym: 'P4',
            value: 110,
            revenue: 20,
            desc: 'The owner of this company may at any time place the Furka-Oberalp special tile. This is an' \
                  ' additional tile lay and free of cost. Doing this closes the company; its owner receives 80 SFR' \
                  ' as a compensation. This happens at the latest by the sale of the first 5/5H train.' \
                  " Its owner can't waive that build.",
            min_price: 1,
            max_price: 220,
            abilities: [
              {
                type: 'choose_ability',
                after_phase: '2',
                when: %w[owning_player_sr_turn owning_player_or_turn owning_corp_or_turn],
                choices: ['Place tile'],
              },
            ],
          },
          {
            name: 'P5 - Compagnie Montreaux-Montbovon',
            sym: 'P5',
            value: 140,
            revenue: 25,
            min_price: 1,
            max_price: 280,
            desc: "Comes with a 10% share of the MOB. This share can't be sold until MOB has been parred.",
            abilities: [{ type: 'shares', shares: 'MOB_1' }],
          },
          {
            name: 'P6 - Societa anonima delle ferrovie',
            sym: 'P6',
            value: 180,
            revenue: 30,
            desc: "Comes with the Director's share of the FNM. When purchased, the owner sets the par price for the FNM" \
                  ' and it immediately floats, with 3 shares going to the market. The company closes when the FNM runs' \
                  ' a train for the first time.',
            abilities: [{ type: 'close', when: 'ran_train', corporation: 'FNM' },
                        { type: 'no_buy' },
                        { type: 'shares', shares: 'FNM_0' }],
          },
          {
            name: 'P7 - Lokfabrik Oerlikon',
            sym: 'P7',
            value: 100,
            revenue: 0,
            desc: 'The company closes when the first 5 or 5H train is bought and the player receives the 5H train "EVA".' \
                  ' They may assign it immediately or later to any corporation they are the director of. Train limits must'\
                  ' be kept.',
            abilities: [
              { type: 'close', on_phase: 'never' },
              { type: 'no_buy' },
              {
                type: 'choose_ability',
                after_phase: '4',
                when: 'owning_player_or_turn',
                choices: [], # Defined in special_choose step
              },
            ],
          },
          {
            name: 'B1 - Mountain Railway',
            sym: 'B1',
            value: 150,
            revenue: 0,
            desc: 'Upon purchase, select an unused revenue tile and assign it to an unoccupied mountain. Available' \
                  ' revenue tiles are (2) 10/20/50/80, (2) 10/40/50/60, and (2) 10/50/80/10. Once the selected' \
                  " mountain is included in any corporation's route, this company pays revenue of 40 SFR at the" \
                  ' beginning of each operating round and is worth 150 SFR at end game. Each player can only' \
                  ' purchase one Mountain Railway per stock round. Does not close and does not count against' \
                  ' certificate limit.',
            color: 'brown',
            abilities: [
              { type: 'close', on_phase: 'never' },
              { type: 'no_buy' },
              {
                type: 'tile_lay',
                when: 'stock_round',
                owner_type: 'player',
                blocks: true,
                count: 1,
                tiles: MOUNTAIN_TILES,
                hexes: MOUNTAIN_HEXES,
              },
            ],
          },
          {
            name: 'B2 - Mountain Railway',
            sym: 'B2',
            value: 150,
            revenue: 0,
            desc: 'Upon purchase, select an unused revenue tile and assign it to an unoccupied mountain. Available' \
                  ' revenue tiles are (2) 10/20/50/80, (2) 10/40/50/60, and (2) 10/50/80/10. Once the selected' \
                  " mountain is included in any corporation's route, this company pays revenue of 40 SFR at the" \
                  ' beginning of each operating round and is worth 150 SFR at end game. Each player can only' \
                  ' purchase one Mountain Railway per stock round. Does not close and does not count against' \
                  ' certificate limit.',
            color: 'brown',
            abilities: [
              { type: 'close', on_phase: 'never' },
              { type: 'no_buy' },
              {
                type: 'tile_lay',
                when: 'stock_round',
                blocks: true,
                count: 1,
                tiles: MOUNTAIN_TILES,
                hexes: MOUNTAIN_HEXES,
              },
            ],
          },
          {
            name: 'B3 - Mountain Railway',
            sym: 'B3',
            value: 150,
            revenue: 0,
            desc: 'Upon purchase, select an unused revenue tile and assign it to an unoccupied mountain. Available' \
                  ' revenue tiles are (2) 10/20/50/80, (2) 10/40/50/60, and (2) 10/50/80/10. Once the selected' \
                  " mountain is included in any corporation's route, this company pays revenue of 40 SFR at the" \
                  ' beginning of each operating round and is worth 150 SFR at end game. Each player can only' \
                  ' purchase one Mountain Railway per stock round. Does not close and does not count against' \
                  ' certificate limit.',
            color: 'brown',
            abilities: [
              { type: 'close', on_phase: 'never' },
              { type: 'no_buy' },
              {
                type: 'tile_lay',
                when: 'stock_round',
                blocks: true,
                count: 1,
                tiles: MOUNTAIN_TILES,
                hexes: MOUNTAIN_HEXES,
              },
            ],
          },
          {
            name: 'B4 - Mountain Railway',
            sym: 'B4',
            value: 150,
            revenue: 0,
            desc: 'Upon purchase, select an unused revenue tile and assign it to an unoccupied mountain. Available' \
                  ' revenue tiles are (2) 10/20/50/80, (2) 10/40/50/60, and (2) 10/50/80/10. Once the selected' \
                  " mountain is included in any corporation's route, this company pays revenue of 40 SFR at the" \
                  ' beginning of each operating round and is worth 150 SFR at end game. Each player can only' \
                  ' purchase one Mountain Railway per stock round. Does not close and does not count against' \
                  ' certificate limit.',
            color: 'brown',
            abilities: [
              { type: 'close', on_phase: 'never' },
              { type: 'no_buy' },
              {
                type: 'tile_lay',
                when: 'stock_round',
                blocks: true,
                count: 1,
                tiles: MOUNTAIN_TILES,
                hexes: MOUNTAIN_HEXES,
              },
            ],
          },
          {
            name: 'B5 - Mountain Railway',
            sym: 'B5',
            value: 150,
            revenue: 0,
            desc: 'Upon purchase, select an unused revenue tile and assign it to an unoccupied mountain. Available' \
                  ' revenue tiles are (2) 10/20/50/80, (2) 10/40/50/60, and (2) 10/50/80/10. Once the selected' \
                  " mountain is included in any corporation's route, this company pays revenue of 40 SFR at the" \
                  ' beginning of each operating round and is worth 150 SFR at end game. Each player can only' \
                  ' purchase one Mountain Railway per stock round. Does not close and does not count against' \
                  ' certificate limit.',
            color: 'brown',
            abilities: [
              { type: 'close', on_phase: 'never' },
              { type: 'no_buy' },
              {
                type: 'tile_lay',
                when: 'stock_round',
                blocks: true,
                count: 1,
                tiles: MOUNTAIN_TILES,
                hexes: MOUNTAIN_HEXES,
              },
            ],
          },
          {
            name: 'T1 - Tunnel Company',
            sym: 'T1',
            value: 50,
            revenue: 0,
            desc: "As an additional tile lay action, one of the owning player's corporations may place a tunnel" \
                  ' on an unused tunnel hex that it can reach for 100 SFR. Once the tunnel is included in any' \
                  " corporation's route, this company pays revenue of 10 SFR at the beginning of each operating" \
                  ' round and is worth 50 SFR at end game. Each player can only purchase one Tunnel Company per' \
                  ' stock round. Does not close and does not count against certificate limit.',
            color: 'gray',
            abilities: [
              {
                type: 'tile_lay',
                when: 'owning_player_track',
                count: 1,
                cost: 100,
                reachable: true,
                tiles: TUNNEL_TILES,
                hexes: TUNNEL_HEXES,
              },
              { type: 'close', on_phase: 'never' },
              { type: 'no_buy' },
            ],
          },
          {
            name: 'T2 - Tunnel Company',
            sym: 'T2',
            value: 50,
            revenue: 0,
            desc: "As an additional tile lay action, one of the owning player's corporations may place a tunnel" \
                  ' on an unused tunnel hex that it can reach for 100 SFR. Once the tunnel is included in any' \
                  " corporation's route, this company pays revenue of 10 SFR at the beginning of each operating" \
                  ' round and is worth 50 SFR at end game. Each player can only purchase one Tunnel Company per' \
                  ' stock round. Does not close and does not count against certificate limit.',
            color: 'gray',
            abilities: [
              {
                type: 'tile_lay',
                when: 'owning_player_track',
                count: 1,
                cost: 100,
                reachable: true,
                tiles: TUNNEL_TILES,
                hexes: TUNNEL_HEXES,
              },
              { type: 'close', on_phase: 'never' },
              { type: 'no_buy' },
            ],
          },
          {
            name: 'T3 - Tunnel Company',
            sym: 'T3',
            value: 50,
            revenue: 0,
            desc: "As an additional tile lay action, one of the owning player's corporations may place a tunnel" \
                  ' on an unused tunnel hex that it can reach for 100 SFR. Once the tunnel is included in any' \
                  " corporation's route, this company pays revenue of 10 SFR at the beginning of each operating" \
                  ' round and is worth 50 SFR at end game. Each player can only purchase one Tunnel Company per' \
                  ' stock round. Does not close and does not count against certificate limit.',
            color: 'gray',
            abilities: [
              {
                type: 'tile_lay',
                when: 'owning_player_track',
                count: 1,
                cost: 100,
                reachable: true,
                tiles: TUNNEL_TILES,
                hexes: TUNNEL_HEXES,
              },
              { type: 'close', on_phase: 'never' },
              { type: 'no_buy' },
            ],
          },
          {
            name: 'T4 - Tunnel Company',
            sym: 'T4',
            value: 50,
            revenue: 0,
            desc: "As an additional tile lay action, one of the owning player's corporations may place a tunnel" \
                  ' on an unused tunnel hex that it can reach for 100 SFR. Once the tunnel is included in any' \
                  " corporation's route, this company pays revenue of 10 SFR at the beginning of each operating" \
                  ' round and is worth 50 SFR at end game. Each player can only purchase one Tunnel Company per' \
                  ' stock round. Does not close and does not count against certificate limit.',
            color: 'gray',
            abilities: [
              {
                type: 'tile_lay',
                when: 'owning_player_track',
                count: 1,
                cost: 100,
                reachable: true,
                tiles: TUNNEL_TILES,
                hexes: TUNNEL_HEXES,
              },
              { type: 'close', on_phase: 'never' },
              { type: 'no_buy' },
            ],
          },
          {
            name: 'T5 - Tunnel Company',
            sym: 'T5',
            value: 50,
            revenue: 0,
            desc: "As an additional tile lay action, one of the owning player's corporations may place a tunnel" \
                  ' on an unused tunnel hex that it can reach for 100 SFR. Once the tunnel is included in any' \
                  " corporation's route, this company pays revenue of 10 SFR at the beginning of each operating" \
                  ' round and is worth 50 SFR at end game. Each player can only purchase one Tunnel Company per' \
                  ' stock round. Does not close and does not count against certificate limit.',
            color: 'gray',
            abilities: [
              {
                type: 'tile_lay',
                when: 'owning_player_track',
                count: 1,
                cost: 100,
                reachable: true,
                tiles: TUNNEL_TILES,
                hexes: TUNNEL_HEXES,
              },
              { type: 'close', on_phase: 'never' },
              { type: 'no_buy' },
            ],
          },
        ].freeze

        CORPORATIONS = [
          {
            float_percent: 50,
            sym: 'NOB',
            name: 'Schweizerische Nordostbahn (V1)',
            logo: '1844/NOB.alt',
            simple_logo: '1844/NOB.alt',
            type: 'pre-sbb',
            shares: [50, 25, 25],
            tokens: [0, 40],
            max_ownership_percent: 75,
            coordinates: 'D19',
            destination_coordinates: 'D15',
            color: '#d8d2d3',
            text_color: '#363552',
          },
          {
            float_percent: 50,
            sym: 'SCB',
            name: 'Schweizerische Centralbahn (V2)',
            logo: '1844/SCB.alt',
            simple_logo: '1844/SCB.alt',
            type: 'pre-sbb',
            shares: [50, 25, 25],
            tokens: [0, 40],
            max_ownership_percent: 75,
            coordinates: 'C12',
            destination_coordinates: 'F17',
            color: '#583838',
            text_color: '#a2452b',
          },
          {
            float_percent: 50,
            sym: 'VSB',
            name: 'Vereinigte Schweizer Bahnen (V3)',
            logo: '1844/VSB.alt',
            simple_logo: '1844/VSB.alt',
            type: 'pre-sbb',
            shares: [50, 25, 25],
            tokens: [0, 40],
            max_ownership_percent: 75,
            coordinates: 'C24',
            destination_coordinates: 'F25',
            color: '#225252',
            text_color: '#d8d2d3',
          },
          {
            float_percent: 50,
            sym: 'JS',
            name: 'Jura-Simplon (V4)',
            logo: '1844/JS.alt',
            simple_logo: '1844/JS.alt',
            type: 'pre-sbb',
            shares: [50, 25, 25],
            tokens: [0, 40],
            max_ownership_percent: 75,
            coordinates: 'I4',
            city: 0,
            destination_coordinates: 'F7',
            color: '#d8d2d3',
            text_color: '#225252',
          },
          {
            float_percent: 50,
            sym: 'GB',
            name: 'Gotthardbahn (V5)',
            logo: '1844/GB.alt',
            simple_logo: '1844/GB.alt',
            type: 'pre-sbb',
            shares: [50, 25, 25],
            tokens: [0, 40],
            max_ownership_percent: 75,
            coordinates: 'G18',
            destination_coordinates: 'H19',
            color: '#c1b22b',
            text_color: 'black',
          },
          {
            float_percent: 60,
            sym: 'JN',
            name: 'Jura Neuchatelois (R1)',
            logo: '1844/JN.alt',
            simple_logo: '1844/JN.alt',
            shares: [40, 20, 20, 20],
            tokens: [0, 40, 100],
            type: 'regional',
            coordinates: 'F7',
            color: '#3f963d',
          },
          {
            float_percent: 60,
            sym: 'ChA',
            name: 'Chur-Arosa (R2)',
            logo: '1844/ChA.alt',
            simple_logo: '1844/ChA.alt',
            shares: [40, 20, 20, 20],
            tokens: [0, 40, 100],
            type: 'regional',
            coordinates: 'G28',
            color: '#242943',
            text_color: '#bcba4c',
          },
          {
            float_percent: 60,
            sym: 'VZ',
            name: 'Visp-Zermatt (R3)',
            logo: '1844/VZ.alt',
            simple_logo: '1844/VZ.alt',
            shares: [40, 20, 20, 20],
            tokens: [0, 40, 100],
            type: 'regional',
            coordinates: 'K10',
            color: '#b02c2d',
          },
          {
            float_percent: 50,
            sym: 'FNM',
            name: 'Ferrovie Nord Milano (H1)',
            logo: '1844/FNM.alt',
            simple_logo: '1844/FNM.alt',
            shares: [20, 10, 10, 10, 10, 10, 10, 10, 10],
            tokens: [0, 40, 100, 100, 100],
            type: 'historical',
            coordinates: 'L21',
            destination_coordinates: 'G20',
            color: '#2a5f3b',
          },
          {
            float_percent: 50,
            sym: 'RhB',
            name: 'Rhätische Bahn (H2)',
            logo: '1844/RhB.alt',
            simple_logo: '1844/RhB.alt',
            shares: [20, 10, 10, 10, 10, 10, 10, 10, 10],
            tokens: [0, 40, 100, 100, 100],
            type: 'historical',
            coordinates: 'G26',
            destination_coordinates: 'J13',
            color: '#cf3334',
          },
          {
            float_percent: 50,
            sym: 'BLS',
            name: 'Bern-Lötschberg-Simplon (H3)',
            logo: '1844/BLS.alt',
            simple_logo: '1844/BLS.alt',
            shares: [20, 10, 10, 10, 10, 10, 10, 10, 10],
            tokens: [0, 40, 100, 100, 100],
            type: 'historical',
            coordinates: 'F11',
            destination_coordinates: 'J13',
            abilities: [{ type: 'assign_hexes', hexes: ['J13'], count: 1 }],
            color: '#c1b22b',
          },
          {
            float_percent: 50,
            sym: 'STB',
            name: 'Sensetalbahn (H4)',
            logo: '1844/STB.alt',
            simple_logo: '1844/STB.alt',
            shares: [20, 10, 10, 10, 10, 10, 10, 10, 10],
            tokens: [0, 40, 100, 100, 100],
            type: 'historical',
            coordinates: 'D15',
            city: 0,
            destination_coordinates: 'H13',
            color: '#3e3d5e',
          },
          {
            float_percent: 50,
            sym: 'AB',
            name: 'Appenzeller Bahn (H5)',
            logo: '1844/AB.alt',
            simple_logo: '1844/AB.alt',
            shares: [20, 10, 10, 10, 10, 10, 10, 10, 10],
            tokens: [0, 40, 100, 100, 100],
            type: 'historical',
            coordinates: 'D25',
            destination_coordinates: 'C20',
            color: '#d8d2d3',
            text_color: 'black',
          },
          {
            float_percent: 50,
            sym: 'MOB',
            name: 'Montreux-Oberland Bernois (H6)',
            logo: '1844/MOB.alt',
            simple_logo: '1844/MOB.alt',
            shares: [20, 10, 10, 10, 10, 10, 10, 10, 10],
            tokens: [0, 40, 100, 100, 100],
            type: 'historical',
            coordinates: 'I6',
            destination_coordinates: 'H13',
            color: '#be8c3a',
          },
          {
            float_percent: 20,
            sym: 'SBB',
            name: 'Schweizer Bundesbahnen',
            logo: '1844/SBB.alt',
            simple_logo: '1844/SBB.alt',
            shares: [10, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 10, 10, 10, 10],
            tokens: [],
            type: 'historical',
            floatable: false,
            color: '#913e2e',
            abilities: [
              {
                type: 'train_buy',
                description: 'Buys and sells trains at face value only',
                face_value: true,
              },
              {
                type: 'train_limit',
                increase: 2,
                description: 'Train limit: 4',
              },
            ],
          },
        ].freeze
      end
    end
  end
end
