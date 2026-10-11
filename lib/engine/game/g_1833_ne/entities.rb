# frozen_string_literal: true

module Engine
  module Game
    module G1833NE
      module Entities
        COMPANIES = [
          {
            name: 'P1. Granite Railway',
            value: 15,
            revenue: 5,
            desc: 'Blocks hex H23 until bought by a corporation.',
            abilities: [
              { type: 'blocks_hexes', owner_type: 'player', hexes: ['H23'] },
            ],
            sym: 'P1',
          },
          {
            name: 'P2. Lowell Merchants',
            value: 40,
            revenue: 10,
            desc: 'Owning corporation may lay a tile in G20 for free, but only on the round this is purchased in.',
            abilities: [
              { type: 'blocks_hexes', owner_type: 'player', hexes: ['G20'] },
              {
                type: 'tile_discount',
                when: 'owning_corp_or_turn',
                owner_type: 'corporation',
                discount: 20,
                hexes: ['G20'],
              },
            ],
            sym: 'P2',
          },
          {
            name: 'P3. Champlain & St. Lawrence',
            value: 50,
            revenue: 10,
            desc: 'Owning corporation may lay up to two extra free yellow tiles in reserved hexes C4 and C6. '\
                  'If both tiles are laid, they must connect to each other. Tile in C4 must connect to Montreal (B3). '\
                  'Owning corporation does not need to be connected to either hex to use this ability.',
            abilities: [
              { type: 'blocks_hexes', owner_type: 'player', hexes: %w[C4 C6] },
              {
                type: 'tile_lay',
                when: 'owning_corp_or_turn',
                owner_type: 'corporation',
                free: true,
                must_lay_together: true,
                hexes: %w[C4 C6],
                tiles: %w[3 4 7 8 9 58],
                count: 2,
              },
            ],
            sym: 'P3',
          },
          {
            name: 'P4. Ogdensburg Railroad',
            value: 60,
            revenue: 15,
            desc: 'May use Ogdensburg RR (hex A6) as a token to lay track and run a route (only). Doubles bonus for '\
                  'a route from hex A6 along track that (inter)connects to Boston (G22).',
            abilities: [], # todo
            sym: 'P4',
          },
          {
            name: 'P5. Luxury Ferry Service',
            value: 70,
            revenue: 15,
            desc: 'Doubles the value of one ferry (and any bonuses). Cannot be reassigned.',
            abilities: [], # todo
            sym: 'P5',
          },
          {
            name: 'P6. Delaware & Hudson Railroad',
            value: 80,
            revenue: 30,
            desc: 'May use D&H RR (hex A12) as a token to lay track and run a route (only).'\
                  'Purchasing corporation must pay an additional $40 to the bank when buying this in.',
            abilities: [{ type: 'close', on_phase: 'never', owner_type: 'corporation' }], # still more todo
            sym: 'P6',
          },
        ].freeze

        CORPORATIONS = [
          {
            float_percent: 20,
            sym: 'CV',
            name: 'Central Vermont Railroad',
            logo: '1833_ne/CV',
            simple_logo: '1833_ne/CV.alt',
            tokens: [0, 80, 80, 80],
            coordinates: 'C8',
            color: :'#0095DA',
            always_market_price: true,
          },
          {
            float_percent: 20,
            sym: 'FRR',
            name: 'Fitchburg Railroad',
            logo: '1833_ne/PRR',
            simple_logo: '1833_ne/PRR.alt',
            tokens: [0, 80, 80, 80],
            coordinates: 'E20',
            color: :'#D1E088',
            text_color: 'black',
            always_market_price: true,
          },
          {
            float_percent: 20,
            sym: 'StL&A',
            name: 'St. Lawrence & Atlantic',
            logo: '1833_ne/StLA',
            simple_logo: '1833_ne/StLA.alt',
            tokens: [0, 80, 80, 80],
            coordinates: 'B3',
            city: 1,
            color: :'#F38221',
            always_market_price: true,
          },
          {
            float_percent: 20,
            sym: 'A&StL',
            name: 'Atlantic & St. Lawrence',
            logo: '1833_ne/AStL',
            simple_logo: '1833_ne/AStL.alt',
            tokens: [0, 80, 80, 80],
            coordinates: 'I14',
            color: :'#8D807D',
            always_market_price: true,
          },
          {
            float_percent: 20,
            sym: 'B&L',
            name: 'Boston & Lowell Railroad',
            logo: '1833_ne/BL',
            simple_logo: '1833_ne/BL.alt',
            tokens: [0, 80, 80, 80],
            coordinates: 'G22',
            city: 1,
            color: :'#F5ABAD',
            text_color: 'black',
            always_market_price: true,
          },
          {
            float_percent: 20,
            sym: 'RR',
            name: 'Rutland Railroad',
            logo: '1833_ne/RR',
            simple_logo: '1833_ne/RR.alt',
            tokens: [0, 80, 80, 80],
            coordinates: 'C12',
            color: :'#2F7146',
            always_market_price: true,
          },
          {
            float_percent: 20,
            sym: 'HR',
            name: 'Hartford Railroad Co.',
            logo: '1833_ne/HR',
            simple_logo: '1833_ne/HR.alt',
            tokens: [0, 80, 80, 80],
            coordinates: 'C24',
            color: :'#C4E9FB',
            text_color: 'black',
            always_market_price: true,
          },
          {
            float_percent: 20,
            sym: 'B&P',
            name: 'Boston & Providence',
            logo: '1833_ne/BP',
            simple_logo: '1833_ne/BP.alt',
            tokens: [0, 80, 80, 80],
            coordinates: 'F25',
            color: :'#EACD93',
            text_color: 'black',
            always_market_price: true,
          },
          {
            float_percent: 20,
            sym: 'BW',
            name: 'Boston & Worcester',
            logo: '1833_ne/BW',
            simple_logo: '1833_ne/BW.alt',
            tokens: [0, 80, 80, 80],
            coordinates: 'G22',
            city: 0,
            color: 'white',
            text_color: 'black',
            always_market_price: true,
          },
        ].freeze
      end
    end
  end
end
