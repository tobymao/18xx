# frozen_string_literal: true

module Engine
  module Game
    module G1894
      module Entities
        COMPANIES = [
          {
            name: 'Ligne de Reims à Charleville',
            sym: 'LRC',
            value: 20,
            revenue: 5,
            desc: 'Once per game the owning corporation may pay 60 F to lay a yellow track.'\
                  ' This is in addition to the corporation\'s regular track actions.'\
                  ' Blocks I14 while owned by a player.',
            abilities: [{ type: 'blocks_hexes', owner_type: 'player', hexes: ['I14'] },
                        {
                          type: 'tile_lay',
                          owner_type: 'corporation',
                          when: 'track',
                          cost: 60,
                          count: 1,
                          special: false,
                          reachable: true,
                          hexes: [],
                          tiles: %w[X1 X2 X3 1 7 8 9 56 57 630 631 632 633],
                        }],
            color: '#d9d9d9',
          },
          {
            name: 'Antwerpen-Rotterdamsche Spoorwegmaatschappij',
            sym: 'AR',
            value: 25,
            revenue: 5,
            desc: 'When owned by a corporation, the revenue is equal to 10 F.',
            abilities: [{ type: 'revenue_change', revenue: 10, when: 'sold' }],
            color: '#d9d9d9',
          },
          {
            name: 'Gare de Liège-Guillemins',
            sym: 'GLG',
            value: 50,
            revenue: 10,
            desc: 'Owning corporation may lay a or upgrade a yellow tile in Liège'\
                  ' (H17), even if not connected. If it does, it may then'\
                  ' optionally place a token for free there.'\
                  ' This counts as one of the corporation\'s tile builds and token laying'\
                  ' (if token was placed). Blocks H17 while owned by a player.',
            abilities: [{ type: 'blocks_hexes', owner_type: 'player', hexes: ['H17'] },
                        {
                          type: 'teleport',
                          owner_type: 'corporation',
                          hexes: ['H17'],
                          tiles: %w[57 14 15 619],
                        }],
            color: '#d9d9d9',
          },
          {
            name: 'Station Antwerpen Centraal',
            sym: 'SAC',
            value: 50,
            revenue: 10,
            desc: 'Owning corporation may lay or upgrade a yellow tile in Antwerpen'\
                  ' (D17), even if not connected. If it does, it may then '\
                  ' optionally place a token for free there.'\
                  ' This counts as one of the corporation\'s tile builds and token laying'\
                  ' (if token was placed). Blocks D17 while owned by a player.',
            abilities: [{ type: 'blocks_hexes', owner_type: 'player', hexes: ['D17'] },
                        {
                          type: 'teleport',
                          owner_type: 'corporation',
                          hexes: ['D17'],
                          tiles: %w[57 14 15 619],
                        }],
            color: '#d9d9d9',
          },
          {
            name: 'Ligne de Saint-Quentin à Guise',
            sym: 'SQG',
            value: 70,
            revenue: 0,
            desc: 'Revenue is equal to 70 F if Saint-Quentin (G10) is green, to 100 F if'\
                  ' Saint-Quentin is brown and to 0 F otherwise.'\
                  ' Closes in purple phase. May not be sold to corporation in red and gray phase.',
            abilities: [{ type: 'close', on_phase: 'Purple' }],
            color: '#d9d9d9',
          },
          {
            name: 'London shipping',
            sym: 'LS',
            value: 90,
            revenue: 15,
            desc: 'Owning corporation pays 40 F for ferry marker.'\
                  ' Owning corporation may place its cheapest available token for free in A12.'\
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
          {
            name: 'Nord minor shareholding',
            sym: 'NMinorS',
            value: 140,
            revenue: 20,
            desc: 'Owning player immediately receives a 10% share of the Nord without further payment.',
            color: '#d9d9d9',
          },
          {
            name: 'PLM major shareholding',
            sym: 'PLMMS',
            value: 180,
            revenue: 40,
            desc: 'Owning player immediately receives the President\'s certificate of the'\
                  ' PLM without further payment. This private company may not be sold to any corporation, and does'\
                  ' not exchange hands if the owning player loses the Presidency of the PLM.'\
                  ' Closes when the PLM operates.',
            abilities: [{ type: 'close', when: 'operated', corporation: 'PLM' },
                        { type: 'no_buy' },
                        { type: 'shares', shares: 'PLM_0' }],
            color: '#dda0dd',
          },
          {
            name: 'Ouest major shareholding',
            sym: 'OMMS',
            value: 180,
            revenue: 40,
            desc: 'Owning player immediately receives the President\'s certificate of the'\
                  ' Ouest without further payment. This private company may not be sold to any corporation, and does'\
                  ' not exchange hands if the owning player loses the Presidency of the Ouest.'\
                  ' Closes when the Ouest operates.',
            abilities: [{ type: 'close', when: 'operated', corporation: 'Ouest' },
                        { type: 'no_buy' },
                        { type: 'shares', shares: 'Ouest_0' }],
            color: '#4682b4',
          },
          {
            name: 'Nord major shareholding',
            sym: 'NMS',
            value: 180,
            revenue: 40,
            desc: 'Owning player immediately receives the President\'s certificate of the'\
                  ' Nord without further payment. This private company may not be sold to any corporation, and does'\
                  ' not exchange hands if the owning player loses the Presidency of the Nord.'\
                  ' Closes when the Nord operates.',
            abilities: [{ type: 'close', when: 'operated', corporation: 'Nord' },
                        { type: 'no_buy' },
                        { type: 'shares', shares: 'Nord_0' }],
            color: '#ff4040',
          },
          {
            name: 'CFOR major shareholding',
            sym: 'CMS',
            value: 180,
            revenue: 40,
            desc: 'Owning player immediately receives the President\'s certificate of the'\
                  ' CFOR without further payment. This private company may not be sold to any corporation, and does'\
                  ' not exchange hands if the owning player loses the Presidency of the CFOR.'\
                  ' Closes when the CFOR operates.',
            abilities: [{ type: 'close', when: 'operated', corporation: 'CFOR' },
                        { type: 'no_buy' },
                        { type: 'shares', shares: 'CFOR_0' }],
            color: '#9c661f',
            text_color: 'white',
          },
          {
            name: 'Est major shareholding',
            sym: 'EMS',
            value: 180,
            revenue: 40,
            desc: 'Owning player immediately receives the President\'s certificate of the'\
                  ' Est without further payment. This private company may not be sold to any corporation, and does'\
                  ' not exchange hands if the owning player loses the Presidency of the Est.'\
                  ' Closes when the Est operates.',
            abilities: [{ type: 'close', when: 'operated', corporation: 'Est' },
                        { type: 'no_buy' },
                        { type: 'shares', shares: 'Est_0' }],
            color: '#ff9966',
          },
          {
            name: 'Belge major shareholding',
            sym: 'BMS',
            value: 200,
            revenue: 60,
            desc: 'Owning player immediately receives the President\'s certificate of the'\
                  ' Belge without further payment. This private company may not be sold to any corporation, and does'\
                  ' not exchange hands if the owning player loses the Presidency of the Belge.'\
                  ' Closes when the Belge operates.',
            abilities: [{ type: 'close', when: 'operated', corporation: 'Belge' },
                        { type: 'no_buy' },
                        { type: 'shares', shares: 'Belge_0' }],
            color: '#61b229',
          },
        ].freeze

        CORPORATIONS = [
          {
            sym: 'Ouest',
            name: 'Chemins de fer de l\'Ouest',
            logo: '1894/Ouest',
            simple_logo: '1894/Ouest.alt',
            tokens: [0, 0, 100, 100, 100],
            max_ownership_percent: 60,
            coordinates: %w[B3 E6],
            color: '#4682b4',
          },
          {
            sym: 'Nord',
            name: 'Chemins de fer du Nord',
            logo: '1894/Nord',
            simple_logo: '1894/Nord.alt',
            tokens: [0, 0, 100, 100],
            max_ownership_percent: 60,
            coordinates: %w[D9 G14],
            color: '#ff4040',
          },
          {
            sym: 'AG',
            name: 'Chemin de fer d\'Anvers à Gand',
            logo: '1894/AG',
            simple_logo: '1894/AG.alt',
            tokens: [0, 40, 100, 100, 100],
            max_ownership_percent: 60,
            coordinates: 'D15',
            color: '#fcf75e',
            text_color: 'black',
          },
          {
            sym: 'CFOR',
            name: 'Chemin de fer d\'Orléans à Rouen',
            logo: '1894/CFOR',
            simple_logo: '1894/CFOR.alt',
            tokens: [0, 0, 100, 100, 100],
            max_ownership_percent: 60,
            coordinates: %w[D3 H3],
            color: '#9c661f',
          },
          {
            sym: 'Belge',
            name: 'Chemins de fer de l\'État belge',
            logo: '1894/Belge',
            simple_logo: '1894/Belge.alt',
            tokens: [0, 40, 100],
            max_ownership_percent: 60,
            coordinates: 'E16',
            color: '#61b229',
            abilities: [
              {
                type: 'description',
                description: 'May not redeem shares',
              },
            ],
          },
          {
            sym: 'PLM',
            name: 'Chemins de fer de Paris à Lyon et à la Méditerranée',
            logo: '1894/PLM',
            simple_logo: '1894/PLM.alt',
            tokens: [0, 40, 100, 100, 100],
            max_ownership_percent: 60,
            coordinates: 'G6',
            city: 0,
            color: '#dda0dd',
            text_color: 'black',
          },
          {
            sym: 'Est',
            name: 'Chemins de fer de l\'Est',
            logo: '1894/Est',
            simple_logo: '1894/Est.alt',
            tokens: [0, 40, 100, 100, 100],
            max_ownership_percent: 60,
            coordinates: 'I10',
            color: '#ff9966',
            text_color: 'black',
          },
          {
            sym: 'LF',
            name: 'Late French',
            logo: '1894/LF',
            simple_logo: '1894/LF.alt',
            tokens: [0, 40, 100],
            max_ownership_percent: 60,
            color: '#ffc0cb',
            text_color: 'black',
          },
          {
            sym: 'LB',
            name: 'Late Belgian',
            logo: '1894/LB',
            simple_logo: '1894/LB.alt',
            tokens: [0, 40, 100],
            max_ownership_percent: 60,
            color: '#c9c9c9',
            text_color: 'black',
          },
        ].freeze
      end
    end
  end
end
