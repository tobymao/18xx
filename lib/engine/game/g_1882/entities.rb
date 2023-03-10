# frozen_string_literal: true

module Engine
  module Game
    module G1882
      module Entities
        COMPANIES = [
          {
            name: 'Hudson Bay',
            value: 20,
            revenue: 5,
            desc: 'Blocks hex C11 (Flin Flon) while owned by a player. Closes at the start of Phase 5.',
            sym: 'HB',
            abilities: [{ type: 'blocks_hexes', owner_type: 'player', hexes: ['C11'] }],
            color: nil,
          },
          {
            name: 'Saskatchewan Central',
            value: 50,
            revenue: 10,
            desc: "Blocks hex H4 while owned by a player. On the owner's turn during a stock round they may convert it"\
                  " to a President's share of the SC by choosing its par price and using their \"buy action\" to purchase an"\
                  ' additional share of the SC. This is the only way the SC can be started. Place the SC home token in any'\
                  ' available non-reserved city slot or replace a neutral station. If the next available train is a 3, 4, 5'\
                  ' or 6, add one train of that type to the Depot. Closes at the start of Phase 6.',
            sym: 'SC',
            abilities: [{ type: 'close', on_phase: '6' },
                        { type: 'blocks_hexes', owner_type: 'player', hexes: ['H4'] },
                        {
                          type: 'exchange',
                          corporations: ['SC'],
                          owner_type: 'player',
                          from: 'par',
                        }],
            color: nil,
          },
          {
            name: 'North West Rebellion',
            value: 80,
            revenue: 15,
            desc: 'The owning corporation may move a single station token located in a non-NWR hex to any open city in'\
                  " an NWR hex. This action is free and may be performed at any time during the corporation's turn. An extra"\
                  " tile lay or upgrade may be performed on the destination hex. If the corporation's home token is moved,"\
                  ' replace it with a neutral station (its home token cannot be moved if a neutral station already exists in'\
                  ' the corporation’s home hex). Closes at the start of Phase 5.',
            sym: 'NWR',
            abilities: [
              {
                type: 'token',
                owner_type: 'corporation',
                hexes: %w[C3 D4 D6 E5],
                price: 0,
                teleport_price: 0,
                when: 'owning_corp_or_turn',
                special_only: true,
                count: 1,
                from_owner: true,
              },
              {
                type: 'tile_lay',
                when: 'owning_corp_or_turn',
                owner_type: 'corporation',
                count: 1,
                hexes: [],
                tiles: [],
              },
            ],
            color: nil,
          },
          {
            name: 'Trestle Bridge',
            value: 140,
            revenue: 0,
            desc: 'Blocks hex G9 while owned by a player. Earns $10 whenever any corporation pays to cross a river.'\
                  ' Comes with a 10% share of a randomly selected corporation (excluding SC). Closes at the start of'\
                  ' Phase 5.',
            sym: 'TB',
            abilities: [
              {
                type: 'shares',
                shares: 'random_share',
                corporations: %w[CNR CPR GT HBR QLL],
              },
              { type: 'blocks_hexes', owner_type: 'player', hexes: ['G9'] },
              { type: 'tile_income', income: 10, terrain: 'water' },
            ],
            color: nil,
          },
          {
            name: 'Canadian Pacific',
            value: 180,
            revenue: 25,
            desc: "Purchasing player immediately takes the 20% President's share of the CPR and chooses its par value."\
                  ' This private closes at the start of phase 5 or when the CPR purchases a train. It cannot be bought by a'\
                  ' corporation.',
            sym: 'CP',
            abilities: [{ type: 'shares', shares: 'CPR_0' }, { type: 'no_buy' }],
            color: nil,
          },
        ].freeze

        CORPORATIONS = [
          {
            sym: 'CN',
            name: 'Canadian National',
            logo: '1882/CN',
            simple_logo: '1882/CN.alt',
            tokens: [],
            color: :orange,
            text_color: 'black',
            reservation_color: nil,
          },
          {
            sym: 'CNR',
            name: 'Canadian Northern',
            logo: '1882/CNR',
            simple_logo: '1882/CNR.alt',
            tokens: [0, 40, 100],
            coordinates: 'D8',
            color: '#237333',
            reservation_color: nil,
          },
          {
            sym: 'HBR',
            name: 'Hudson Bay Railway',
            logo: '1882/HBR',
            simple_logo: '1882/HBR.alt',
            tokens: [0, 40, 100],
            coordinates: 'G11',
            color: :gold,
            text_color: 'black',
            reservation_color: nil,
          },
          {
            sym: 'CPR',
            name: 'Canadian Pacific Railway',
            logo: '1882/CPR',
            simple_logo: '1882/CPR.alt',
            tokens: [0, 40, 100, 100],
            coordinates: 'I5',
            color: '#d81e3e',
            reservation_color: nil,
          },
          {
            sym: 'GT',
            name: 'Grand Trunk Pacific',
            logo: '1882/GT',
            simple_logo: '1882/GT.alt',
            tokens: [0, 40, 100],
            coordinates: 'L8',
            color: :black,
            reservation_color: nil,
          },
          {
            sym: 'SC',
            name: 'Saskatchewan Central Railroad',
            logo: '1882/SC',
            simple_logo: '1882/SC.alt',
            tokens: [0],
            color: '#0189d1',
            reservation_color: nil,
          },
          {
            sym: 'QLL',
            name: "Qu'Appelle, Long Lake Railroad Co.",
            logo: '1882/QLL',
            simple_logo: '1882/QLL.alt',
            tokens: [0, 40],
            coordinates: 'J10',
            color: :purple,
            reservation_color: nil,
          },
        ].freeze
      end
    end
  end
end
