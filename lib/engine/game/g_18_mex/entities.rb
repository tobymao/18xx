# frozen_string_literal: true

module Engine
  module Game
    module G18MEX
      module Entities
        COMPANIES = [
          {
            sym: 'MCAR',
            name: 'Mexico City-Acapulco Railroad',
            value: 20,
            revenue: 5,
            desc: 'No special abilities.',
          },
          {
            sym: 'CdB',
            name: 'Compagnie Du Boleo',
            value: 30,
            revenue: 5,
            desc: 'May play token in Santa Rosalia at no cost and in addition to regular '\
                  'token lay. May be purchased by a corporation for $15-$30, from Phase 2.',
            abilities: [
              {
                type: 'token',
                when: 'owning_corp_or_turn',
                owner_type: 'corporation',
                hexes: ['H3'],
                price: 0,
                teleport_price: 0,
                extra_action: true,
                from_owner: true,
                count: 1,
              },
            ],
          },
          {
            sym: 'KCMO',
            name: 'Kansas City, Mexico, & Orient Railroad',
            value: 40,
            revenue: 10,
            desc: 'Owning corporation may place the non-upgradable Copper Canyon tile in F5 for $60 (instead of the normal '\
                  '$120) unless that hex is already built. The tile lay does not have to be connected to an existing station '\
                  'token of the owning corporation. The lay does not count toward the normal lay limit but must be done during '\
                  'tile lay. Using this tile laying ability closes the private company.',

            abilities: [
              {
                type: 'tile_lay',
                discount: 60,
                owner_type: 'corporation',
                tiles: ['470'],
                hexes: ['F5'],
                count: 1,
                when: 'track',
              },
            ],
          },
          {
            sym: 'A',
            name: 'Interoceanic Railroad',
            value: 50,
            revenue: 0,
            desc: 'Owner takes control of minor corporation A. Begins in Tampico (M12). This private cannot be sold. When Phase '\
                  '3½ begins, the minor corporation closes, but its owner receives a 5% share in NdM.',
            abilities: [{ type: 'no_buy', owner_type: 'player' }],
          },
          {
            sym: 'B',
            name: 'Sonora-Baja California Railway',
            value: 50,
            revenue: 0,
            desc: 'Owner takes control of minor corporation B. Begins in Mazatlán (K6). This private cannot be sold. When Phase '\
                  '3½ begins, the minor corporation closes, but its owner receives a 5% share in NdM.',
            abilities: [{ type: 'no_buy', owner_type: 'player' }],
          },
          {
            sym: 'C',
            name: 'Southeastern Railway',
            value: 50,
            revenue: 0,
            desc: 'Owner takes control of minor corporation C. Begins in Oaxaca (S12). This private cannot be sold. When Phase '\
                  '3½ begins, the minor corporation closes, but its owner receives a 10% share in UdY.',
            abilities: [{ type: 'no_buy', owner_type: 'player' }],
          },
          {
            sym: 'MIR',
            name: 'Mexican International Railroad',
            value: 100,
            revenue: 20,
            desc: 'Comes with a 10% share of the Chihuahua Pacific Railway (CHI).',
            abilities: [{ type: 'shares', shares: 'CHI_1' },
                        {
                          type: 'blocks_hexes',
                          owner_type: 'player',
                          hexes: %w[K11 J12],
                        }],
          },
          {
            sym: 'MNR',
            name: 'Mexican National Railroad',
            value: 140,
            revenue: 20,
            desc: "Comes with President's Certificate of NdM. Owner must immediately set NdM's par price. Closes when NdM buys "\
                  'a train. May not be sold to a corporation.',
            abilities: [{ type: 'shares', shares: 'NdM_0' },
                        { type: 'close', when: 'bought_train', corporation: 'NdM' },
                        { type: 'no_buy' }],
          },
        ].freeze

        CORPORATIONS = [
          {
            float_percent: 50,
            sym: 'CHI',
            name: 'Chihuahua Pacific Railway',
            logo: '18_mex/CHI',
            simple_logo: '18_mex/CHI.alt',
            tokens: [0, 40, 60, 80],
            coordinates: 'E6',
            color: '#FF4136',
          },
          {
            float_percent: 50,
            sym: 'NdM',
            name: 'National Railways of Mexico',
            logo: '18_mex/NdM',
            simple_logo: '18_mex/NdM.alt',
            shares: [20, 10, 10, 10, 10, 10, 10, 5, 5, 10],
            tokens: [0, 40, 60, 80],
            abilities: [
              {
                type: 'train_buy',
                description: 'Inter train buy/sell at face value',
                face_value: true,
              },
              {
                type: 'train_limit',
                description: '+1 train limit',
                increase: 1,
              },
              {
                type: 'no_buy',
                description: 'Unavailable in SR before phase 3½',
              },
            ],
            coordinates: 'O10',
            color: '#00AC00',
          },
          {
            float_percent: 50,
            sym: 'MC',
            name: 'Mexican Central Railway',
            logo: '18_mex/MC',
            simple_logo: '18_mex/MC.alt',
            tokens: [0, 40],
            coordinates: 'I8',
            color: '#232b2b',
          },
          {
            float_percent: 50,
            sym: 'FCP',
            name: 'Pacific Railroad',
            logo: '18_mex/FCP',
            simple_logo: '18_mex/FCP.alt',
            tokens: [0, 40, 60, 80],
            abilities: [{ type: 'base', description: 'Cannot be merged into NdM' }],
            coordinates: 'B3',
            color: '#FFF128',
            text_color: 'black',
          },
          {
            float_percent: 50,
            sym: 'TM',
            name: 'Texas-Mexican Railway',
            logo: '18_mex/TM',
            simple_logo: '18_mex/TM.alt',
            tokens: [0, 40],
            abilities: [{ type: 'base', description: 'Cannot be merged into NdM' }],
            coordinates: 'I12',
            color: '#FFC502',
            text_color: 'black',
          },
          {
            float_percent: 50,
            sym: 'MEX',
            name: 'Mexican Railway',
            logo: '18_mex/MEX',
            simple_logo: '18_mex/MEX.alt',
            tokens: [0, 40, 60],
            coordinates: 'P13',
            color: 'darkGray',
            text_color: 'black',
          },
          {
            float_percent: 50,
            sym: 'SPM',
            name: 'Southern Pacific Railroad of Mexico',
            logo: '18_mex/SPM',
            simple_logo: '18_mex/SPM.alt',
            tokens: [0, 40, 60],
            coordinates: 'O8',
            color: '#0080FF',
          },
          {
            float_percent: 50,
            sym: 'UdY',
            name: 'United Railways of Yucatan',
            logo: '18_mex/UdY',
            simple_logo: '18_mex/UdY.alt',
            tokens: [0, 40],
            coordinates: 'Q14',
            color: 'darkMagenta',
          },
        ].freeze

        MINORS = [
          {
            sym: 'A',
            name: 'Interoceanic Railroad',
            logo: '18_mex/A',
            simple_logo: '18_mex/A.alt',
            tokens: [0],
            coordinates: 'M12',
            color: 'limeGreen',
          },
          {
            sym: 'B',
            name: 'Sonora-Baja Railway',
            logo: '18_mex/B',
            simple_logo: '18_mex/B.alt',
            tokens: [0],
            coordinates: 'K6',
            color: 'darkGreen',
          },
          {
            sym: 'C',
            name: 'Southeastern Railway',
            logo: '18_mex/C',
            simple_logo: '18_mex/C.alt',
            tokens: [0],
            coordinates: 'S12',
            color: 'darkMagenta',
          },
        ].freeze
      end
    end
  end
end
