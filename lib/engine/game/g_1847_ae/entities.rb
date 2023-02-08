# frozen_string_literal: true

# TEMPORARY, TAKEN FROM 1894
module Engine
  module Game
    module G1847AE
      module Entities
        COMPANIES = [
          {
            name: 'Ligne Longwy-Villerupt-Micheville',
            sym: 'LVM',
            value: 20,
            revenue: 5,
            desc: 'Owning corporation may lay a yellow tile in I14.'\
                  ' This is in addition to the corporation\'s tile builds.'\
                  ' No connection required. Blocks I14 while owned by a player.',
            abilities: [{ type: 'blocks_hexes', owner_type: 'player', hexes: ['I14'] },
                        {
                          type: 'tile_lay',
                          owner_type: 'corporation',
                          hexes: ['I14'],
                          tiles: %w[7 8 9],
                          when: 'owning_corp_or_turn',
                          count: 1,
                        }],
            color: '#d9d9d9',
          },
          {
            name: 'Antwerpen-Rotterdamsche Spoorwegmaatschappij',
            sym: 'AR',
            value: 25,
            revenue: 5,
            desc: 'When owned by a corporation, the revenue is equal to 10.',
            abilities: [{ type: 'revenue_change', revenue: 10, when: 'sold' }],
            color: '#d9d9d9',
          },
          {
            name: 'Gare de Liège-Guillemins',
            sym: 'GLG',
            value: 50,
            revenue: 10,
            desc: 'Owning corporation may lay a yellow tile or upgrade a yellow tile in Liège'\
                  ' (H17) along with an optional token.'\
                  ' This counts as one of the corporation\'s tile builds.'\
                  ' Blocks H17 while owned by a player.',
            abilities: [{ type: 'blocks_hexes', owner_type: 'player', hexes: ['H17'] },
                        {
                          type: 'teleport',
                          owner_type: 'corporation',
                          hexes: ['H17'],
                          tiles: %w[14 15 57 619],
                        }],
            color: '#d9d9d9',
          },
          {
            name: 'London shipping',
            sym: 'LS',
            value: 90,
            revenue: 15,
            desc: 'Owning corporation may place its cheapest available token for free in A12.'\
                  ' The value of London (A10) is increased, for this corporation only,'\
                  ' by the largest non-London, non-Luxembourg revenue on the route.',
            abilities: [{
              type: 'token',
              when: 'owning_corp_or_turn',
              hexes: ['A12'],
              count: 1,
              price: 0,
              teleport_price: 0,
              extra_action: true,
              from_owner: true,
              owner_type: 'corporation',
            }],
            color: '#d9d9d9',
          },
        ].freeze

        CORPORATIONS = [
          {
            sym: 'L',
            name: 'Pfälzische Ludwigsbahn',
            logo: '1847_ae/L',
            simple_logo: '1847_ae/L',
            tokens: [0, 60, 80, 100],
            float_percent: 50,
            max_ownership_percent: 100,
            coordinates: 'F18',
            required_par_price: 86,
            hex_color: 'blue',
            shares: [20, 10, 10, 10, 10, 10, 10, 10, 10],
            second_share_double: false,
            last_share_double: false,
            color: '#4682b4',
            abilities: [
              {
                type: 'base',
                description: 'Builds in blue hexes in yellow phase',
                remove: '4',
              },
            ],
          },
          {
            sym: 'Saar',
            name: 'Saarbrücker Eisenbahn',
            logo: '1847_ae/Saar',
            simple_logo: '1847_ae/Saar',
            tokens: [0, 60, 80, 100],
            float_percent: 30,
            max_ownership_percent: 100,
            coordinates: 'H6',
            required_par_price: 84,
            hex_color: 'pink',
            shares: [20, 10, 10, 10, 10, 10, 10, 20],
            second_share_double: false,
            last_share_double: true,
            color: '#ff4040',
            abilities: [
              {
                type: 'base',
                description: 'Builds in pink hexes in yellow phase',
                remove: '4',
              },
            ],
          },
          {
            sym: 'HLB',
            name: 'Hessische Ludwigsbahn',
            logo: '1847_ae/HLB',
            simple_logo: '1847_ae/HLB',
            tokens: [0, 0, 80, 100],
            float_percent: 40,
            max_ownership_percent: 100,
            coordinates: %w[D18 C21],
            required_par_price: 80,
            hex_color: 'green',
            shares: [20, 10, 10, 10, 10, 10, 10, 20],
            second_share_double: false,
            last_share_double: true,
            color: '#dda0dd',
            abilities: [
              {
                type: 'base',
                description: 'Builds in green hexes in yellow phase',
                remove: '4',
              },
              {
                type: 'base',
                description: 'May not be started until Saar floats',
              },
              {
                type: 'base',
                description: 'Two home stations (D18 and C21)',
              },
            ],
            text_color: 'black',
          },
          {
            sym: 'NDB',
            name: 'Neustadt-Dürkheimer Bahn',
            logo: '1847_ae/NDB',
            simple_logo: '1847_ae/NDB',
            tokens: [0, 60],
            float_percent: 50,
            max_ownership_percent: 100,
            coordinates: 'G15',
            # the shares order creates a 10 share company, but the first 2 sold certs are 20%
            shares: [20, 10, 20, 10, 10, 10, 20],
            second_share_double: true,
            last_share_double: true,
            required_par_price: 74,
            hex_color: 'blue',
            color: '#61b229',
            abilities: [
              {
                type: 'base',
                description: 'Builds in blue hexes in yellow phase',
                remove: '4',
              },
              {
                type: 'base',
                description: 'May not be started until HLB floats',
              },
            ],
          },
          {
            sym: 'M',
            name: 'Pfälzische Maximiliansbahn',
            logo: '1847_ae/M',
            simple_logo: '1847_ae/M',
            tokens: [0, 60, 80],
            float_percent: 50,
            max_ownership_percent: 100,
            coordinates: 'H16',
            required_par_price: 80,
            hex_color: 'blue',
            shares: [20, 10, 10, 10, 10, 10, 10, 20],
            second_share_double: false,
            last_share_double: true,
            color: '#fafa37',
            text_color: 'black',
            abilities: [
              {
                type: 'base',
                description: 'Builds in blue hexes in yellow phase',
                remove: '4',
              },
              {
                type: 'base',
                description: 'May not be started until HLB floats',
              },
            ],
          },
          {
            sym: 'N',
            name: 'Pfälzische Nordbahn',
            logo: '1847_ae/N',
            simple_logo: '1847_ae/N',
            tokens: [0, 60, 80],
            float_percent: 50,
            max_ownership_percent: 100,
            coordinates: 'F12',
            # the shares order creates a 10 share company, but the first 2 sold certs are 20%
            shares: [20, 10, 20, 10, 10, 10, 20],
            second_share_double: true,
            last_share_double: true,
            required_par_price: 66,
            hex_color: 'blue',
            color: '#ff9966',
            abilities: [
              {
                type: 'base',
                description: 'Builds in blue hexes in yellow phase',
                remove: '4',
              },
              {
                type: 'base',
                description: 'May not be started until HLB floats',
              },
            ],
          },
          {
            sym: 'RNB',
            name: 'Rhein-Nahe-Bahn',
            logo: '1847_ae/RNB',
            simple_logo: '1847_ae/RNB',
            tokens: [0, 60, 80],
            float_percent: 50,
            max_ownership_percent: 100,
            coordinates: 'C13',
            # the shares order creates a 10 share company, but the first 2 sold certs are 20%
            shares: [20, 10, 20, 10, 10, 10, 20],
            second_share_double: true,
            last_share_double: true,
            required_par_price: 66,
            hex_color: 'pink',
            color: '#ffc0cb',
            abilities: [
              {
                type: 'base',
                description: 'Builds in pink hexes in yellow phase',
                remove: '4',
              },
              {
                type: 'base',
                description: 'May not be started until HLB floats',
              },
            ],
          },
        ].freeze
      end
    end
  end
end
