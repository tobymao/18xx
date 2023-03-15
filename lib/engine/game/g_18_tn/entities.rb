# frozen_string_literal: true

module Engine
  module Game
    module G18TN
      module Entities
        COMPANIES = [
          {
            sym: 'TCC',
            name: 'Tennessee Copper Co.',
            value: 20,
            revenue: 5,
            desc: 'Corporation owner may lay a free yellow tile in H17. It need not be '\
                  'connected to an existing station token of the corporation. It does not '\
                  'count toward the corporation\'s normal limit of two yellow tile lays per turn.',
            abilities: [
            {
              type: 'tile_lay',
              free: true,
              count: 1,
              owner_type: 'corporation',
              hexes: ['H17'],
              tiles: %w[7 8 9],
              when: 'track',
            },
          ],
          },
          {
            sym: 'ETWCR',
            name: 'East Tennessee & Western Carolina Railroad',
            value: 40,
            revenue: 10,
            desc: 'Corporation owner may lay a free yellow tile in F19. It need not be connected '\
                  'to an existing station token of the corporation. It does not count toward the '\
                  'corporation\'s normal limit of two yellow tile lays per turn.',
            abilities: [
              {
                type: 'tile_lay',
                free: true,
                count: 1,
                owner_type: 'corporation',
                hexes: ['F19'],
                tiles: %w[7 8 9],
                when: 'track',
              },
            ],
          },
          {
            sym: 'MCR',
            name: 'Memphis & Charleston Railroad',
            value: 70,
            revenue: 15,
            desc: 'Corporation owner may lay a free yellow tile in H3. It need not be connected '\
                  'to an existing station token of the corporation. It does not count toward the '\
                  'corporation\'s normal limit of two yellow tile lays per turn.',
            abilities: [
              {
                type: 'tile_lay',
                free: true,
                count: 1,
                owner_type: 'corporation',
                hexes: ['H3'],
                tiles: %w[5 6 57],
                when: 'track',
              },
            ],
          },
          {
            sym: 'OWR',
            name: 'Oneida & Western Railroad',
            value: 100,
            revenue: 20,
            desc: 'Corporation owner may lay a free yellow tile in E16. It need not be connected '\
                  'to an existing station token of the corporation. It does not count toward the '\
                  'corporation\'s normal limit of two yellow tile lays per turn.',
            abilities: [
              {
                type: 'tile_lay',
                free: true,
                count: 1,
                owner_type: 'corporation',
                hexes: ['E16'],
                tiles: %w[7 8 9],
                when: 'track',
              },
            ],
          },
          {
            sym: 'LNR',
            name: 'Louisville and Nashville Railroad',
            value: 175,
            revenue: 0,
            desc: 'The purchaser of this private company receives the president\'s certificate of '\
                  'the L&N Railroad and must immediately set its par value. The L&N automatically '\
                  'floats once this private company is purchased and is an exception to the normal '\
                  'rule. This private company closes immediately after the par value is set.',
            abilities: [{ type: 'shares', shares: 'L&N_0' }],
          },
        ].freeze

        CORPORATIONS = [
          {
            sym: 'SR',
            name: 'Southern Railway',
            logo: '18_tn/SR',
            simple_logo: '18_tn/SR.alt',
            tokens: [0, 40, 100, 100],
            coordinates: 'F17',
            color: 'yellow',
            text_color: 'green',
          },
          {
            sym: 'GMO',
            name: 'Gulf, Mobile, and Ohio Railroad',
            logo: '18_tn/GMO',
            simple_logo: '18_tn/GMO.alt',
            tokens: [0, 40, 100, 100],
            coordinates: 'G6',
            color: 'red',
          },
          {
            float_percent: 20,
            sym: 'L&N',
            name: 'Louisville and Nashville Railroad',
            logo: '18_tn/LN',
            simple_logo: '18_tn/LN.alt',
            tokens: [0, 40, 100, 100],
            coordinates: 'B13',
            color: 'blue',
          },
          {
            sym: 'IC',
            name: 'Illinois Central Railroad',
            logo: '18_tn/IC',
            simple_logo: '18_tn/IC.alt',
            tokens: [0, 40, 100],
            coordinates: 'D7',
            color: 'green',
          },
          {
            sym: 'NC&StL',
            name: 'Nashville, Chattanooga, and St. Louis Railroad',
            logo: '18_tn/NCS',
            simple_logo: '18_tn/NCS.alt',
            tokens: [0, 40],
            coordinates: 'H15',
            color: 'orange',
            text_color: 'black',
          },
          {
            sym: 'TC',
            name: 'Tennessee Central Railway',
            logo: '18_tn/TC',
            simple_logo: '18_tn/TC.alt',
            tokens: [0, 40],
            coordinates: 'F11',
            color: 'black',
          },
        ].freeze
      end
    end
  end
end
