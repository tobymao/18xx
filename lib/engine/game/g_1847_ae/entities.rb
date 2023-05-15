# frozen_string_literal: true

# TEMPORARY, TAKEN FROM 1894
module Engine
  module Game
    module G1847AE
      module Entities
        COMPANIES = [
          {
            name: 'Pfälzische Ludwigsbahn presidency',
            value: 172,
            revenue: 0,
            desc: 'Comes with the President\'s certificate of Pfälzische Ludwigsbahn (L). '\
                  'Closes immediately.',
            sym: 'PLP',
            abilities: [{ type: 'shares', shares: 'L_0' }],
          },
          {
            name: 'Saarbrücker Private Railway',
            value: 190,
            revenue: 15,
            desc: 'Comes with the president\'s certificate of Saarbrücker Eisenbahn (Saar). '\
                  'May not be sold to a corporation. '\
                  'Closes when Saar buys its first train.',
            sym: 'SPR',
            abilities: [{ type: 'no_buy' },
                        { type: 'shares', shares: 'Saar_0' },
                        { type: 'close', when: 'bought_train', corporation: 'Saar' }],
          },
          {
            name: 'Locomotive Firm Krauss & Co.',
            value: 130,
            revenue: 0,
            desc: 'Every OR, first time a train is purchased from supply, this pays revenue '\
                  'equal to 10% of the train\'s cost and the stock price marker is moved right. '\
                  'If no train is purchased from supply in OR, no revenue is paid and the stock '\
                  'price marker is moved left. '\
                  'May not be sold to a corporation. '\
                  'May be sold to or purchased from the market. '\
                  'Never closes.',
            sym: 'LFKC',
            abilities: [{ type: 'no_buy' }],
          },
          {
            name: 'Rammelsbach',
            value: 150,
            revenue: 30,
            min_price: 100,
            max_price: 200,
            desc: 'Revenue increases to 50M when a tile is laid in D9. '\
                  'May be sold to a corporation for 100 to 200M. '\
                  'Never closes.',
            sym: 'R',
          },
          {
            name: 'Königsbach',
            value: 110,
            revenue: 5,
            min_price: 15,
            max_price: 40,
            desc: 'Owning corporation may close this company to place a yellow tile on '\
                  'a mountain hex for free, in addition to normal track action. '\
                  'Otherwise closes in Phase 6E. '\
                  'May be sold to a corporation for 15 to 40M. '\
                  'Comes with a share of Pfälzische Ludwigsbahn (L).',
            sym: 'K',
            abilities: [
              { type: 'close', on_phase: '6E' },
              { type: 'shares', shares: 'L_1' },
              {
                type: 'tile_lay',
                hexes: %w[B4
                          C5
                          D4
                          D8
                          D10
                          D12
                          D14
                          D20
                          E3
                          E5
                          E7
                          E9
                          E11
                          E15
                          F4
                          F10
                          F14
                          G11
                          G13
                          I15],
                tiles: %w[1 3 4 7 8 9 55 56 58 69],
                free: true,
                when: 'track',
                owner_type: 'corporation',
                reachable: true,
                count: 1,
                consume_tile_lay: false,
                closed_when_used_up: true,
                special: false,
              },
            ],
          },
          {
            name: 'Hochstätten',
            value: 160,
            revenue: 15,
            min_price: 40,
            max_price: 120,
            desc: 'Owning corporation may close this company to place a yellow tile on '\
                  'a mountain hex for free, in addition to normal track action. '\
                  'Otherwise closes in Phase 6E. '\
                  'May be sold to a corporation for 40 to 120M. '\
                  'Comes with a share of Pfälzische Ludwigsbahn (L).',
            sym: 'H',
            abilities: [
              { type: 'close', on_phase: '6E' },
              { type: 'shares', shares: 'L_2' },
              {
                type: 'tile_lay',
                hexes: %w[B4
                          C5
                          D4
                          D8
                          D10
                          D12
                          D14
                          D20
                          E3
                          E5
                          E7
                          E9
                          E11
                          E15
                          F4
                          F10
                          F14
                          G11
                          G13
                          I15],
                tiles: %w[1 3 4 7 8 9 55 56 58 69],
                free: true,
                when: 'track',
                owner_type: 'corporation',
                reachable: true,
                count: 1,
                consume_tile_lay: false,
                closed_when_used_up: true,
                special: false,
              },
            ],
          },
          {
            name: 'Weidenthal',
            value: 135,
            revenue: 10,
            min_price: 25,
            max_price: 75,
            desc: 'Owning corporation may close this company to place a token for half the price. '\
                  'Otherwise closes in Phase 6E. '\
                  'May be sold to a corporation for 25 to 75M. '\
                  'Comes with a share of Pfälzische Ludwigsbahn (L).',
            sym: 'W',
            abilities: [
              { type: 'close', on_phase: '6E' },
              { type: 'shares', shares: 'L_3' },
              {
                type: 'token',
                owner_type: 'corporation',
                when: 'token',
                connected: true,
                hexes: [],
                discount: 0.5,
                count: 1,
                from_owner: true,
                closed_when_used_up: true,
              },
            ],
          },
          {
            name: 'Main-Neckar-Railway',
            value: 90,
            revenue: 20,
            desc: 'May be exchanged for an Investor share of the Hessische Ludwigsbahn (HLB), '\
                  'instead of buying a share, during a stock round in Phase 3+3 or later. '\
                  'Automatically exchanged at the beginning of the first stock round in Phase 5+5. '\
                  'May not be sold to a corporation. ',
            sym: 'MNR',
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
                  'instead of buying a share, during a stock round in Phase 3+3 or later. '\
                  'Automatically exchanged at the beginning of the first stock round in Phase 5+5. '\
                  'May not be sold to a corporation. ',
            sym: 'SCR',
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
                  'instead of buying a share, during a stock round in Phase 3+3 or later. '\
                  'Automatically exchanged at the beginning of the first stock round in Phase 5+5. '\
                  'May not be sold to a corporation. ',
            sym: 'VIW',
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
