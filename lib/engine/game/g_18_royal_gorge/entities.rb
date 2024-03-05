# frozen_string_literal: true

module Engine
  module Game
    module G18RoyalGorge
      module Entities
        YELLOW_COMPANIES = [
          {
            sym: 'Y1',
            name: 'St. Cloud Hotel (Y1)',
            desc: "Hotel token starts in Silvercliffe (G17). When owned by a corporation, St. Cloud's "\
                  'hotel token will generate an additional $20 revenue only for the holding corporation. '\
                  'Once in Brown Phase, the hotel is moved to Cañon City (H12). This company never closes.',
            value: 50,
            revenue: 5,
            abilities: [
              # +$20 revenue in Silvercliffe; moves to Canon City in brown
            ],
          },
          {
            sym: 'Y2',
            name: 'Ghost Town Tour Co. (Y2)',
            desc: 'When the owning corporation ships the last gold from any mine space, they  may put 1 Ghost Town '\
                  'Token in that hex. On future turns, Ghost Town Tokens provide $10 revenue for the owning corporation.',
            value: 45,
            revenue: 15,
            abilities: [
              {
                type: 'choose_ability',
                owner_type: 'corporation',
                when: %w[dividend],
                count: 4,
              },
            ],
          },
          {
            sym: 'Y3',
            name: 'Coal Creek Mines (Y3)',
            desc: 'Special abilities not implemented.',
            # desc: 'When any corporation runs through Coal Creek, the owning corporation receives a coal cube '\
            #       'from the Coal Mine Card. On a future turn, the owning corporation may use up to 2 coal cubes '\
            #       'to increase their train run by 1 stop for each cube. When used, cubes are removed from the game.',
            value: 40,
            revenue: 5,
            abilities: [
              # owning corp gets a coal cube from the coal mine card (supply of
              # 12) when anyone runs through Coal Creek
            ],
          },
          {
            sym: 'Y4',
            name: 'William Palmer (Y4)',
            desc: 'Owning player will start the game with a 10% of Rio Grande and a 10% share of CF&I.',
            value: 75,
            revenue: 5,
            abilities: [
              { type: 'shares', shares: ['CF&I_1', 'RG_1'] },
              { type: 'no_buy' },
            ],
          },
          {
            sym: 'Y5',
            name: 'Territorial Prison (Y5)',
            desc: 'If a corporation owns the prison, they may use prison labor to build in any terrain at 1/2 price.',
            value: 70,
            revenue: 10,
            abilities: [
              {
                type: 'tile_discount',
                discount: 5,
                terrain: 'mountain',
                owner_type: 'corporation',
                hexes: %(E9 F16 I11 J10 J8 L6),
              },
              {
                type: 'tile_discount',
                discount: 10,
                terrain: 'mountain',
                owner_type: 'corporation',
                hexes: %(C9 D16 E5 I5 J4 J6 K5),
              },
              {
                type: 'tile_discount',
                discount: 15,
                terrain: 'mountain',
                owner_type: 'corporation',
                hexes: %(B10 D4 D6 D8 D18),
              },
              {
                type: 'tile_discount',
                discount: 10,
                terrain: 'water',
                owner_type: 'corporation',
              },
            ],
          },
          {
            sym: 'Y6',
            name: 'Local Jeweler (Y6)',
            desc: 'Every time any corporation ships gold, the jeweler receives $5 from the Bank onto this card. '\
                  'At the beginning of each Stock Round, any money on this card becomes personal cash.',
            value: 20,
            revenue: 5,
            abilities: [
              # $5 from bank when anybody ships Gold, moves to owner's cash at
              # start of SR
              { type: 'no_buy' },
            ],
          },
        ].freeze

        GREEN_COMPANIES = [
          {
            sym: 'G1',
            name: 'Doc Holliday (G1)',
            desc: 'During the Treaty of Boston, Doc acquires 2 debt tokens. These tokens indebt Santa Fe '\
                  'to Doc Holliday. When/if Santa Fe chooses to pay Doc Holliday, that money is '\
                  'immediately available to the owner of this private. Closes when debt is paid in full.',
            value: 55,
            revenue: 10,
            abilities: [
              # treaty of boston: 2 debt tokens; closes after SF buys both of them
              { type: 'no_buy' },
            ],
          },
          {
            sym: 'G2',
            name: '13LB Gold Nugget (G2)',
            desc: 'Once during the game, the owning corporation may ship 1 Gold for $130 revenue '\
                  'increase (instead of the normal $50).',
            value: 40,
            revenue: 5,
            abilities: [
              {
                type: 'choose_ability',
                owner_type: 'corporation',
                when: %w[dividend],
                count: 1,
              },
            ],
          },
          {
            sym: 'G3',
            name: 'Hanging Bridge Lease (G3)',
            desc: 'The owning corporation may run through The Royal Gorge (D12-E13-F12) by paying a '\
                  '10% dividend to the Rio Grande from the proceeds. This money can either come from '\
                  "the charter, or the president's personal cash.",
            value: 50,
            revenue: 10,
          },
          {
            sym: 'G4',
            name: 'Florence Oil Fields (G4)',
            desc: 'Once in Green Phase, provides $25 revenue per operating round. This company '\
                  'cannot be voluntarily closed, and still counts toward the certificate limit.',
            value: 75,
            revenue: 0,
            abilities: [
              { type: 'revenue_change', revenue: 25, on_phase: 'Green' },
              { type: 'no_buy' },
            ],
          },
          {
            sym: 'G5',
            name: 'Metals Investor (G5)',
            desc: 'Special abilities not implemented.',
            # desc: 'Each Stock Round, the owning player may purchase 1 CF&I share and/or 1 VGC '\
            #       'share for one step cheaper than their current value. Once used, the player may '\
            #       'not sell any of the purchased stocks until the next Stock Round.',
            value: 25,
            revenue: 5,
            abilities: [
              # 1 step discount on CF&I/VGC shares; if used, cannot sell the
              # bought shares till next SR
              { type: 'no_buy' },
            ],
          },
          {
            sym: 'G6',
            name: 'Coal Depot (G6)',
            desc: 'Special abilities not implemented.',
            # desc: 'Place one coal cube on this card for every $10 paid for this company in the '\
            #       'initial auction (rounded down). During operating rounds, the owning corporation may '\
            #       'spend 1-2 coal cubes to add additional stops on a route, following normal route rules.',
            value: 10,
            revenue: 5,
            abilities: [
              # 1 coal cube per $10 paid (round down) during auction
            ],
          },
        ].freeze

        BROWN_COMPANIES = [
          {
            sym: 'B1',
            name: 'Silver Mines (B1)',
            desc: 'Once in Brown Phase, provides $25 revenue per operating round. Never closes, '\
                  'counts towards certificate limit when held by a player.',
            value: 70,
            revenue: 0,
            abilities: [{ type: 'revenue_change', revenue: 25, on_phase: 'Brown' }],
          },
          {
            sym: 'B2',
            name: 'Sulphur Springs (B2)',
            desc: 'The owning corporation may close this company permanently to turn Sulphur '\
                  'Springs (E3) into a city of the same color tile. If owned by a player, once in Brown Phase, '\
                  'provides $50 revenue per operating round, only if Sulphur Springs is connected by any rail.',
            value: 50,
            revenue: 0,
            abilities: [
              {
                type: 'tile_lay',
                when: 'owning_corp_or_turn',
                hexes: %w[E3],
                tiles: %w[RG1 RG2 RG3],
                owner_type: 'corporation',
                count: 1,
                closed_when_used_up: true,
                special: true,
              },
            ],
          },
          {
            sym: 'B3',
            name: 'Steel Depot (B3)',
            desc: 'Comes with the Steel Depot card. Once per operating round, owning corporation '\
                  'may use 0-2 steel from the Steel Depot card to lay yellow track for free. (Max '\
                  'of 6 track applies).',
            value: 55,
            revenue: 10,
            abilities: [
              {
                type: 'tile_lay',
                count: 5,
                count_per_or: 2,
                consume_tile_lay: true,
                hexes: [],
                tiles: %w[RG4 3 4 5 6 7 8 9 57 58],
                special: false,
                reachable: true,
              },
            ],
          },
          {
            sym: 'B4',
            name: 'Gold Miner (B4)',
            desc: 'Special abilities not implemented.',
            # desc: 'This card acts as though it were a 20% share of Victor Gold Company. Does not '\
            #       'count as a certificate. Closes when the first 5+ train is purchased.',
            value: 20,
            revenue: 0,
            abilities: [
              # { type: 'close', on_train: '5+' },
              # 20% share of gold company
              # does not count against cert limit
              { type: 'no_buy' },
            ],
          },
          {
            sym: 'B5',
            name: 'Track Engineer (B5)',
            desc: 'Special abilities not implemented.',
            # desc: 'Every operating round, this company may treat one train as if it were +1. It may '\
            #       'be a different train each operating round.',
            value: 60,
            revenue: 10,
            abilities: [
              # extend a train by 1 each OR
            ],
          },
          {
            sym: 'B6',
            name: 'U.S. Mint Worker (B6)',
            desc: 'Special abilities not implemented.',
            # desc: 'The owning player may close this company to purchase 1-2 Victor Gold Company '\
            #       'shares at a 50% discount each. These are bought simultaneously.',
            value: 40,
            revenue: 5,
            abilities: [
              { type: 'no_buy' },
              # once per game may buy 1-2 gold shares at 50% discount; closes company
            ],
          },
        ].freeze

        def self.def_corporation(**kwargs)
          {
            float_percent: 20,
            tokens: [0, 40, 60, 80].take(kwargs.delete(:tokens)),
            always_market_price: true,
            logo: "18_royal_gorge/#{kwargs[:sym]}",
            simple_logo: "18_royal_gorge/#{kwargs[:sym]}.alt",
            type: :rail,
          }.merge(kwargs).freeze
        end

        INCLUDED_CORPORATIONS = [
          def_corporation(
            sym: 'RG',
            name: 'Denver & Rio Grande Western',
            coordinates: 'L2',
            tokens: 3,
            color: 'red',
          ),
          def_corporation(
            sym: 'SF',
            name: 'Santa Fe Railroad',
            coordinates: 'O15',
            tokens: 4,
            color: 'purple',
          ),
        ].freeze

        MAYBE_CORPORATIONS = [
          def_corporation(
            sym: 'KP',
            name: 'Kansas Pacific Railway',
            coordinates: 'O5',
            tokens: 4,
            color: 'gray',
          ),
          def_corporation(
            sym: 'SPP',
            name: 'Denver, South Park & Pacific Railroad',
            coordinates: 'B6',
            tokens: 4,
            color: 'orange',
          ),
          def_corporation(
            sym: 'PAV',
            name: 'Pueblo and Arkansas Valley Railroad',
            coordinates: 'L14',
            tokens: 4,
            color: 'blue',
          ),
          def_corporation(
            sym: 'NO',
            name: 'Denver & New Orleans',
            coordinates: 'L8',
            tokens: 3,
            color: 'black',
          ),
          def_corporation(
            sym: 'CM',
            name: 'Colorado Midland Railway',
            coordinates: 'B2',
            tokens: 3,
            color: 'green',
          ),
          def_corporation(
            sym: 'S',
            name: 'Silverton Railway',
            coordinates: 'C17',
            tokens: 3,
            color: 'white',
            text_color: 'black',
          ),
          def_corporation(
            sym: 'FCC',
            name: 'Florence & Cripple Creek Railroad',
            coordinates: 'I13',
            tokens: 2,
            color: 'yellow',
            text_color: 'black',
          ),
          def_corporation(
            sym: 'CSCC',
            name: 'Colorado Springs & Cripple Creek District',
            coordinates: 'K7',
            tokens: 2,
            color: 'green',
          ),
          def_corporation(
            sym: 'CS',
            name: 'Colorado & Southern',
            coordinates: 'J2',
            tokens: 2,
            color: 'black',
          ),
        ].freeze

        def self.def_metal_corporation(**kwargs)
          {
            shares: Array.new(10, 10),
            float_percent: 0,
            tokens: [],
            capitalization: :full,
            always_market_price: true,
            logo: "18_royal_gorge/#{kwargs[:sym]}",
            simple_logo: "18_royal_gorge/#{kwargs[:sym]}.alt",
            type: :metal,
          }.merge(kwargs).freeze
        end

        METAL_CORPORATIONS = [
          def_metal_corporation(
            sym: 'CF&I',
            name: 'Colorado Fuel & Iron',
            color: 'gray',
            abilities: [
              {
                type: 'base',
                description: 'Steel Market',
                desc_detail: 'Corporations must buy a steel cube from CF&I for each track '\
                             'laid/upgraded. That money, plus $50, is paid as dividends to CF&I '\
                             'shareholders at the end of each OR set.',
              },
            ],
          ),
          def_metal_corporation(
            sym: 'VGC',
            name: 'Victor Gold Company',
            color: 'gold',
            text_color: 'black',
            abilities: [
              {
                type: 'base',
                description: 'Gold Dividend',
                desc_detail: 'When gold is shipped from the map, it is added to the Gold Dividend table, '\
                             'covering the lowest available slot. At the end of each OR set, VGC '\
                             'pays the amount of the lowest uncovered slot as dividends to '\
                             'shareholders. That amount is also tracked here as VGC\'s cash.',
              },
              {
                type: 'base',
                description: 'Gold Slots',
                desc_detail: 'Yellow: 50, 90. Green: 140, 200. Brown: 270. Red: 350. Availability '\
                             'for filling slots is determined by the current phase.',
              },
            ],
          ),
        ].freeze

        DEBT_CORPORATION = {
          sym: 'DEBT',
          name: 'Debt',
          color: 'red',
          tokens: [],
          logo: '18_royal_gorge/DEBT',
          simple_logo: '18_royal_gorge/DEBT.alt',
          type: :debt,
          hide_shares: true,
        }.freeze
      end
    end
  end
end
