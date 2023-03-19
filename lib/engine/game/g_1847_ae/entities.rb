# frozen_string_literal: true

# TEMPORARY, TAKEN FROM 1894
module Engine
  module Game
    module G1847AE
      module Entities
        COMPANIES = [
          {
            name: 'Main-Neckar-Railway',
            value: 90,
            revenue: 20,
            desc: 'May be exchanged for an Investor share of the Hessische Ludwigsbahn (HLB), '\
                  'instead of buying a share, during a stock round in Phase 3+3 or later. ' \
                  'Automatically exchanged at the beginning of the first stock round in Phase 5+5.',
            sym: 'MNR',
            color: nil,
            abilities: [{ type: 'no_buy' },
                        {
                          type: 'exchange',
                          corporations: ['HLB'],
                          owner_type: 'player',
                          when: 'owning_player_sr_turn',
                          from: %w[reserved],
                        }],
          },
          {
            name: 'Saarland Coal Mines',
            value: 75,
            revenue: 15,
            desc: 'May be exchanged for an Investor share of the Saarbrücker Eisenbahn (Saar), '\
                  'instead of buying a share, during a stock round in Phase 3+3 or later. ' \
                  'Automatically exchanged at the beginning of the first stock round in Phase 5+5.',
            sym: 'SCR',
            color: nil,
            abilities: [{ type: 'no_buy' },
                        {
                          type: 'exchange',
                          corporations: ['Saar'],
                          owner_type: 'player',
                          when: 'owning_player_sr_turn',
                          from: %w[reserved],
                        }],
          },
          {
            name: 'Völklinger Iron Works',
            value: 85,
            revenue: 20,
            desc: 'May be exchanged for an Investor share of the Saarbrücker Eisenbahn (Saar), '\
                  'instead of buying a share, during a stock round in Phase 3+3 or later. ' \
                  'Automatically exchanged at the beginning of the first stock round in Phase 5+5.',
            sym: 'VIW',
            color: nil,
            abilities: [{ type: 'no_buy' },
                        {
                          type: 'exchange',
                          corporations: ['Saar'],
                          owner_type: 'player',
                          when: 'owning_player_sr_turn',
                          from: %w[reserved],
                        }],
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
