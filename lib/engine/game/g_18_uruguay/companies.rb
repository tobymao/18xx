# frozen_string_literal: true

module Engine
  module Game
    module G18Uruguay
      module Companies
        COMPANIES = [
        {
          name: 'P1 Amigos del Progreso',
          sym: 'AP',
          value: 20,
          revenue: 5,
          min_price: 10,
          max_price: 40,
          desc: 'No special abilities.',
          abilities: [],
          color: nil,
        },
        {
          name: 'P2 Latifundio Agrícola',
          value: 40,
          min_price: 20,
          max_price: 80,
          revenue: 10,
          desc: 'Owner (or controlling president) moves one crop cube from a countryside'\
                'hex to an adjacent town or city hex each OR. Closes when the last crop cube has been moved.',
          sym: 'LA_CORN',
          abilities: [
                {
                  type: 'assign_hexes',
                  hexes: %w[C3 D4 G13 H2 H6],
                  count_per_or: 1,
                  when: 'or_start',
                  owner_type: 'player',
                  count: 10,
                  description: 'Owner (or controlling president) moves one crop cube from a countryside'\
                               'hex to an adjacent town or city hex each OR. Closes when the last crop cube has been moved.',
                },
            ],
          color: nil,
        },
        {
          name: 'P3 Latifundio de Ovejas',
          value: 70,
          min_price: 35,
          max_price: 140,
          revenue: 15,
          desc: 'Owner (or controlling president) moves one sheep cube from a countryside'\
                'hex to an adjacent town or city hex each OR. Closes when the last sheep cube has been moved.',
          sym: 'LO_SHEEP',
          abilities: [
                {
                  type: 'assign_hexes',
                  hexes: %w[E5 E7 G5 H12 J8],
                  count_per_or: 1,
                  when: 'or_start',
                  owner_type: 'player',
                  count: 10,
                  description: 'Owner (or controlling president) moves one sheep cube from a countryside'\
                               'hex to an adjacent town or city hex each OR. Closes when the last sheep cube has been moved.',
                },
            ],
          color: nil,
        },
        {
          name: 'P4 Latifundio de Vacas',
          value: 110,
          min_price: 55,
          max_price: 220,
          revenue: 20,
          desc: 'Owner (or controlling president) moves one cattle cube from a countryside'\
                'hex to an adjacent town or city hex each OR. Closes when the last cattle cube has been moved.',
          sym: 'LO_CATTLE',
          abilities: [
                {
                  type: 'assign_hexes',
                  hexes: %w[D8 F4 F10 F12 I5],
                  count_per_or: 1,
                  when: 'or_start',
                  owner_type: 'player',
                  count: 10,
                  description: 'Owner (or controlling president) moves one cattle cube from a countryside'\
                               'hex to an adjacent town or city hex each OR. Closes when the last cattle cube has been moved.',
                },
            ],
          color: nil,
        },
        {
          name: 'P5 John Eldon Gorst',
          value: 160,
          revenue: 25,
          desc: 'Accompanied by the 30%
                    President’s Certificate of The River Plate Trust, Loan
                    & Agency Company, ltd (RPTLA). Closes when
                    RPTLA buys its first non-yellow ship. P5 is not available for purchase.',
          sym: 'JOHN',
          abilities: [
                { type: 'no_buy' },
                { type: 'shares', shares: 'RPTLA_0' },
            ],
          color: nil,
        },
        {
          name: 'P6 Senen María Rodrígue',
          value: 220,
          revenue: 30,
          desc: 'Accompanied by
                the 20% Pesident’s Certificate of the Ferrocarriles
                Central del Uruguay (FCCU). Closes when FCCU
                buys its first train. P6 is not available for purchase.',
          sym: 'FCCU_PRIV',
          abilities: [
                { type: 'no_buy' },
                { type: 'shares', shares: 'FCCU_0' },
                { type: 'close', when: 'bought_train', corporation: 'FCCU' },
            ],
          color: nil,
        },
        ].freeze

        MINORS = [
          {
            sym: 'LA_CORN',
            name: 'Latifundio Agrícola',
            logo: '18_uruguay/corn',
            simple_logo: '18_uruguay/corn',
            tokens: [0],
            color: :pink,
            text_color: 'black',
            abilities: [
              {
                type: 'assign_hexes',
                hexes: %w[C3 D4 G13 H2 H6],
                count_per_or: 1,
                when: 'or_start',
                count: 10,
                description: 'Delivers goods to towns and cities.',
              },
            ],
          },
          {
            sym: 'LO_SHEEP',
            name: 'Latifundio de Ovejas',
            logo: '18_uruguay/sheep',
            simple_logo: '18_uruguay/sheep',
            tokens: [0],
            color: :cyan,
            text_color: 'black',
            abilities: [
              {
                type: 'assign_hexes',
                hexes: %w[E5 E7 G5 H12 J8],
                count_per_or: 1,
                when: 'or_start',
                count: 10,
                description: 'Delivers goods to towns and cities.',
              },
            ],
          },
          {
            sym: 'LO_CATTLE',
            name: 'Latifundio de Vacas',
            logo: '18_uruguay/cow',
            simple_logo: '18_uruguay/cow',
            tokens: [0],
            color: :cyan,
            text_color: 'black',
            abilities: [
              {
                type: 'assign_hexes',
                hexes: %w[D8 F4 F10 F12 I5],
                count_per_or: 1,
                when: 'or_start',
                owner_type: 'player',
                count: 10,
                description: 'Delivers goods to towns and cities.',
              },
            ],
          },
        ].freeze
      end
    end
  end
end
