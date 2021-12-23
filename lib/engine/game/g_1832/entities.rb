# frozen_string_literal: true

module Engine
  module Game
    module G1832
      module Entities
        CORPORATIONS = [
          {
            float_percent: 60,
            sym: 'ACL',
            name: 'Atlantic Coast Line Railroad',
            logo: '1832/ACL',
            tokens: [0, 40, 100],
            shares: [20, 10, 10, 10, 10, 10, 10, 10, 10],
            color: 'pink',
            type: 'major',
            text_color: 'black',
            coordinates: 'G17',
          },
          {
            float_percent: 60,
            sym: 'A&WP',
            name: 'Atlanta & West Point Railroad',
            logo: '1832/A&WP',
            tokens: [0, 40],
            shares: [20, 10, 10, 10, 10, 10, 10, 10, 10],
            color: 'purple',
            type: 'major',
            text_color: 'white',
            coordinates: 'F10',
          },
          {
            float_percent: 60,
            sym: 'SALR',
            name: 'Seaboard Air Line Railway',
            logo: '1832/SALR',
            tokens: [0, 40, 100],
            shares: [20, 10, 10, 10, 10, 10, 10, 10, 10],
            color: 'orange',
            type: 'major',
            text_color: 'black',
            coordinates: 'D20',
          },
          {
            float_percent: 60,
            sym: 'N&W',
            name: 'Norfolk & Western Railway',
            logo: '1832/N&W',
            tokens: [0, 40, 100],
            shares: [20, 10, 10, 10, 10, 10, 10, 10, 10],
            color: 'black',
            type: 'major',
            text_color: 'white',
            coordinates: 'B24',
          },
          {
            float_percent: 60,
            sym: 'CG',
            name: 'Central of Georgia Railway',
            logo: '1832/CG',
            tokens: [0, 40, 100],
            shares: [20, 10, 10, 10, 10, 10, 10, 10, 10],
            color: 'teal',
            type: 'major',
            text_color: 'white',
            coordinates: 'H16',
          },
          {
            float_percent: 60,
            sym: 'L&N',
            name: 'Louisville & Nashville Railroad',
            logo: '1832/L&N',
            tokens: [0, 40, 100],
            shares: [20, 10, 10, 10, 10, 10, 10, 10, 10],
            color: 'blue',
            type: 'major',
            text_color: 'white',
            coordinates: 'C7',
          },
          {
            float_percent: 60,
            sym: 'GRR',
            name: 'Georgia Railraod',
            logo: '1832/GRR',
            tokens: [0, 40],
            shares: [20, 10, 10, 10, 10, 10, 10, 10, 10],
            color: 'lightblue',
            type: 'major',
            text_color: 'black',
            coordinates: 'F10',
          },
          {
            float_percent: 60,
            sym: 'GMO',
            name: 'Gulf, Mobile & Ohio Railroad',
            logo: '1832/GMO',
            tokens: [0, 40, 100],
            shares: [20, 10, 10, 10, 10, 10, 10, 10, 10],
            color: 'red',
            type: 'major',
            text_color: 'white',
            coordinates: 'J2',
          },
          {
            float_percent: 60,
            sym: 'SOU',
            name: 'Southern Railway',
            logo: '1832/SOU',
            tokens: [0, 40, 100],
            shares: [20, 10, 10, 10, 10, 10, 10, 10, 10],
            color: 'green',
            type: 'major',
            text_color: 'black',
            coordinates: 'C11',
          },
          {
            float_percent: 60,
            sym: 'FECR',
            name: 'Florida East Coast Railroad',
            logo: '1832/FECR',
            tokens: [0, 40],
            shares: [20, 10, 10, 10, 10, 10, 10, 10, 10],
            color: 'yellow',
            type: 'major',
            text_color: 'black',
            coordinates: 'J14',
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
          # TODO: HEY CAP, PLEASE FIX THIS SO THAT IT CAN ASSIGN TO ORLANDO AND OTHER MEDIUM CITIES WHEN THEY GET UPGRADES TY TY
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
                hexes: %w[D20 F10 C7 F6 D16],
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
                count: 2,
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
            }],
            color: nil,
          },
          {
            name: 'West Virginia Coalfields',
            value: 80,
            revenue: 15,
            sym: 'P5',
            desc: 'This private company gives the owning company a WVCF token for free.'\
                  ' When other companies connect to the coal fields, '\
                  'they may buy a WVCF token (if available) during their operating round for $80'\
                  ' ($40 goes to the company owning the WVCF private company).',
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
