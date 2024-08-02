# frozen_string_literal: true

module Engine
  module Game
    module G1832
      module Entities
        CORPORATIONS = [
          {
            sym: 'ACL',
            name: 'Atlantic Coast Line Railroad',
            logo: '1832/ACL',
            simple_logo: '1832/ACL.alt',
            tokens: [0, 40, 100],
            shares: [20, 10, 10, 10, 10, 10, 10, 10, 10],
            color: 'pink',
            type: 'major',
            text_color: 'black',
            coordinates: 'G17',
            abilities: [
              {
                type: 'tile_discount',
                discount: 60,
                hexes: ['G17'],
              },
            ],
          },
          {
            sym: 'A&WP',
            name: 'Atlanta & West Point Railroad',
            logo: '1832/A&WP',
            simple_logo: '1832/A&WP.alt',
            tokens: [0, 40],
            shares: [20, 10, 10, 10, 10, 10, 10, 10, 10],
            color: 'purple',
            type: 'major',
            text_color: 'white',
            coordinates: 'F10',
            city: 1,
          },
          {
            sym: 'SALR',
            name: 'Seaboard Air Line Railway',
            logo: '1832/SALR',
            simple_logo: '1832/SALR.alt',
            tokens: [0, 40, 100],
            shares: [20, 10, 10, 10, 10, 10, 10, 10, 10],
            color: 'orange',
            type: 'major',
            text_color: 'black',
            coordinates: 'D20',
          },
          {
            sym: 'N&W',
            name: 'Norfolk & Western Railway',
            logo: '1832/N&W',
            simple_logo: '1832/N&W.alt',
            tokens: [0, 40, 100],
            shares: [20, 10, 10, 10, 10, 10, 10, 10, 10],
            color: 'black',
            type: 'major',
            text_color: 'white',
            coordinates: 'B24',
          },
          {
            sym: 'CG',
            name: 'Central of Georgia Railway',
            logo: '1832/CG',
            simple_logo: '1832/CG.alt',
            tokens: [0, 40, 100],
            shares: [20, 10, 10, 10, 10, 10, 10, 10, 10],
            color: 'teal',
            type: 'major',
            text_color: 'white',
            coordinates: 'H16',
            abilities: [
              {
                type: 'tile_discount',
                discount: 60,
                hexes: ['H16'],
              },
            ],
          },
          {
            sym: 'L&N',
            name: 'Louisville & Nashville Railroad',
            logo: '1832/L&N',
            simple_logo: '1832/L&N.alt',
            tokens: [0, 40, 100],
            shares: [20, 10, 10, 10, 10, 10, 10, 10, 10],
            color: 'blue',
            type: 'major',
            text_color: 'white',
            coordinates: 'C7',
          },
          {
            sym: 'GRR',
            name: 'Georgia Railraod',
            logo: '1832/GRR',
            simple_logo: '1832/GRR.alt',
            tokens: [0, 40],
            shares: [20, 10, 10, 10, 10, 10, 10, 10, 10],
            color: 'lightblue',
            type: 'major',
            text_color: 'black',
            coordinates: 'F10',
            city: 0,
          },
          {
            sym: 'GMO',
            name: 'Gulf, Mobile & Ohio Railroad',
            logo: '1832/GMO',
            simple_logo: '1832/GMO.alt',
            tokens: [0, 40, 100],
            shares: [20, 10, 10, 10, 10, 10, 10, 10, 10],
            color: 'red',
            type: 'major',
            text_color: 'white',
            coordinates: 'J2',
          },
          {
            sym: 'SOU',
            name: 'Southern Railway',
            logo: '1832/SOU',
            simple_logo: '1832/SOU.alt',
            tokens: [0, 40, 100],
            shares: [20, 10, 10, 10, 10, 10, 10, 10, 10],
            color: 'green',
            type: 'major',
            text_color: 'black',
            coordinates: 'C11',
            abilities: [
              {
                type: 'tile_discount',
                discount: 60,
                hexes: ['C11'],
              },
            ],
          },
          {
            sym: 'FECR',
            name: 'Florida East Coast Railroad',
            logo: '1832/FECR',
            simple_logo: '1832/FECR.alt',
            tokens: [0, 40],
            shares: [20, 10, 10, 10, 10, 10, 10, 10, 10],
            color: 'yellow',
            type: 'major',
            text_color: 'black',
            coordinates: 'J14',
            abilities: [{ type: 'assign_hexes', hexes: ['N16'], count: 1, cost: 100 }],
          },
          {
            float_percent: 20,
            sym: 'AMTK',
            name: 'Amtrak System',
            logo: '1832/AMTK',
            simple_logo: '1832/AMTK.alt',
            tokens: [100, 100, 100, 100, 100],
            shares: [20, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5],
            color: 'white',
            type: 'system',
            text_color: 'black',
          },
          {
            float_percent: 20,
            sym: 'BNSF',
            name: 'Burlington Northern Santa Fe System',
            logo: '1832/BNSF',
            simple_logo: '1832/BNSF.alt',
            tokens: [100, 100, 100, 100, 100],
            shares: [20, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5],
            color: 'white',
            type: 'system',
            text_color: 'black',
          },
          {
            float_percent: 20,
            sym: 'IC',
            name: 'Illinois Central System',
            logo: '1832/IC',
            simple_logo: '1832/IC.alt',
            tokens: [100, 100, 100, 100, 100],
            shares: [20, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5],
            color: 'white',
            type: 'system',
            text_color: 'black',
          },
          {
            float_percent: 20,
            sym: 'CSX',
            name: 'CSX System',
            logo: '1832/CSX',
            simple_logo: '1832/CSX.alt',
            tokens: [100, 100, 100, 100, 100],
            shares: [20, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5],
            color: 'white',
            type: 'system',
            text_color: 'black',
          },
          {
            float_percent: 20,
            sym: 'NS',
            name: 'Norfolk Southern System',
            logo: '1832/NS',
            simple_logo: '1832/NS.alt',
            tokens: [100, 100, 100, 100, 100],
            shares: [20, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5],
            color: 'white',
            type: 'system',
            text_color: 'black',
          },
        ].freeze

        COMPANIES = [
          {
            name: 'Carolina Stagecoach Company',
            sym: 'P1',
            value: 20,
            revenue: 5,
            desc: 'No special abilities.',
            abilities: [],
            color: nil,
          },
          {
            name: 'Cotton Warehouse',
            value: 40,
            revenue: 10,
            desc: 'This company has a $10 token which may be placed in any non-coastal city'\
                  ' (Atlantic or Gulf Coast) as an extra token lay during the'\
                  ' token placement step of an owning public company\'s operating round.',
            sym: 'P2',
            abilities: [
              {
                type: 'assign_hexes',
                when: 'owning_corp_or_turn',
                hexes: %w[C7 C11 D16 D20 F10 F6],
                count: 1,
                owner_type: 'corporation',
              },
              {
                type: 'assign_corporation',
                when: 'sold',
                count: 1,
                owner_type: 'corporation',
              },
            ],
            color: nil,
          },
          {
            name: 'Atlantic Shipping',
            value: 50,
            revenue: 10,
            desc: 'This company has a Port token which may be placed on any city'\
                  ' on the coasts as an extra token lay during the token placement'\
                  ' step of an owning public company\'s operating round. All eligible cities are marked with an anchor symbol.'\
                  ' This token increases the value of the selected city by $20'\
                  ' for the owning company and by $10 for all other companies.',
            sym: 'P3',
            abilities: [
              {
                type: 'assign_hexes',
                hexes: %w[B24 E21 G17 H16 I3 J4 J2 J10 J14 M13 N16 E21],
                count: 1,
                owner_type: 'corporation',
                when: 'owning_corp_or_turn',
              },
              {
                type: 'assign_corporation',
                when: 'sold',
                count: 1,
                owner_type: 'corporation',
              },
            ],
            color: nil,
          },
          {
            name: 'London Investment',
            value: 70,
            revenue: 10,
            desc: 'This company represents those shrewd investors in London. They have hired'\
                  ' you to invest their money in the new Southern railways.'\
                  ' They will purchase a share of your choice in any newly started company.'\
                  ' You get the share. After the company pays its first dividend, '\
                  'the London Investment Company is closed, as they realize they have paid you'\
                  ' for nothing and you spent the money for yourself.',
            sym: 'P4',
            abilities: [{
              type: 'exchange',
              owner_type: 'player',
              corporations: 'any',
              from: 'ipo',
            },
                        { type: 'no_buy' }],
            color: nil,
          },
          {
            name: 'West Virginia Coalfields',
            value: 80,
            revenue: 15,
            sym: 'P5',
            abilities: [
              {
                type: 'blocks_hexes',
                owner_type: 'player',
                hexes: %w[B12 B16 C13 C15],
              },
            ],
            desc: 'This private company gives the owning company a Coal token for free.'\
                  ' When other companies connect to the Coalfields, '\
                  'they may buy a Coal token (if available) during their operating round for $80'\
                  ' ($40 goes to the corporation owning the Coal private company).',
          },
          {
            name: 'Central Railroad & Canal',
            sym: 'P7',
            value: 200,
            revenue: 30,
            desc: 'Comes with the president\'s share of the Central of Georgia Railway. The player buying this'\
                  ' private company must immediately set the par value of the CG. ',
            abilities: [
                        { type: 'close', when: 'bought_train', corporation: 'CG' },
                        { type: 'no_buy' },
                        { type: 'shares', shares: 'CG_0' },
            ],
            color: nil,
          },
        ].freeze
      end
    end
  end
end
