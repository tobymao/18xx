# frozen_string_literal: true

module Engine
  module Game
    module G18Junta
      module Entities
        COMPANIES = [
          {
            name: '(A) Investidores Unidos',
            sym: '(A)',
            value: 35,
            revenue: 15,
            desc: 'Once per game, at the start of a Stock Round, the owner may fix the par price of a ' \
                  'company that has not yet sold any shares.',
            color: nil,
          },
          {
            name: '(B) Empreiteiros Montoya',
            sym: '(B)',
            value: 40,
            revenue: 10,
            desc: 'Once per game, the owning company may lay the Laguna tile (E11) for free, in addition to ' \
                  'its normal Track action and without needing a route to the hex.',
            color: nil,
            abilities: [
              {
                type: 'tile_lay',
                owner_type: 'corporation',
                hexes: ['E11'],
                tiles: ['J16'],
                when: 'owning_corp_or_turn',
                count: 1,
                free: true,
                special: true,
              },
            ],
          },
          {
            name: '(C) Misioneros Campesinos',
            sym: '(C)',
            value: 45,
            revenue: 10,
            desc: 'When the owning company lays a tile in a hex with a paramilitary token, it may ' \
                  'discard that token without choosing a side. If it does, the Political Track marker ' \
                  'does not move and no corruption token is drawn.',
            color: nil,
          },
          {
            name: '(D) Ferramenteria Ochoa',
            sym: '(D)',
            value: 50,
            revenue: 5,
            desc: 'Once per game, when buying a train from the supply, the owning company may discard a 2- ' \
                  'or 3-train and pay only the difference in price. The new train must cost more than the ' \
                  'discarded one.',
            color: nil,
          },
          {
            name: '(E) Casa Ruiz de Assistencia',
            sym: '(E)',
            value: 55,
            revenue: 10,
            desc: 'From the purchase of the first 3-train, the owner may donate this Private Company to a ' \
                  'company they preside over, instead of selling it. The bank gives that company $150, and ' \
                  'the Private Company keeps paying its revenue to that company. The owner receives no ' \
                  'compensation.',
            color: nil,
            abilities: [{ type: 'choose_ability', owner_type: 'player', when: 'any', choices: {} }],
          },
          {
            name: '(F) Ingeniería Real',
            sym: '(F)',
            value: 60,
            revenue: 10,
            desc: 'Once per Operating Round, the owning company may make an additional yellow tile lay for ' \
                  '$25 plus terrain costs. Normal tile placement rules apply to it.',
            color: nil,
            abilities: [{
              type: 'tile_lay',
              owner_type: 'corporation',
              hexes: [],
              tiles: [],
              when: 'track',
              count_per_or: 1,
              cost: 25,
              reachable: true,
              special: false,
            }],
          },
          {
            name: '(G) Expresso Resplandor',
            sym: '(G)',
            value: 65,
            revenue: 10,
            desc: "Towns do not count toward the range of the owning company's trains, but they still count " \
                  'for revenue.',
            color: nil,
          },
          {
            name: '(H) Gutiérrez y Asociados',
            sym: '(H)',
            value: 70,
            revenue: 15,
            desc: 'When the owning company pays a high dividend (at least twice its share price), the bank ' \
                  "adds 10% of the dividend to the company's treasury.",
            color: nil,
          },
          {
            name: '(I) Orejuela Abogados',
            sym: '(I)',
            value: 75,
            revenue: 20,
            desc: 'During coup resolution, before the tokens are counted, the owning company may discard one of ' \
                  'its alignment tokens.',
            color: nil,
          },
          {
            name: '(J) Sanchez Ingeniería',
            sym: '(J)',
            value: 80,
            revenue: 20,
            desc: 'The owning company gets a $25 discount on mountains and a $15 discount on farms, ' \
                  'including farm upgrades.',
            abilities: [
              { type: 'tile_discount', discount: 25, terrain: 'mountain', owner_type: 'corporation', exact_match: false },
              # Farms use the swamp terrain (see map.rb).
              { type: 'tile_discount', discount: 15, terrain: 'swamp', owner_type: 'corporation', exact_match: false },
            ],
            color: nil,
          },
          {
            name: '(K) Hernandez Abogados',
            sym: '(K)',
            value: 85,
            revenue: 5,
            desc: "Once per Operating Round, when the owning company's president draws a black corruption " \
                  'token from the bag, it is automatically returned to the bag and a new token is ' \
                  'drawn, which is kept regardless of its color.',
            color: nil,
          },
          {
            name: '(L) Banco de La Nación',
            sym: '(L)',
            value: 180,
            revenue: 40,
            desc: 'Can never be bought by a Public Company.',
            color: nil,
            abilities: [{ type: 'no_buy' }],
          },
          {
            name: '(M) Sociedade Caja Negra',
            sym: '(M)',
            value: 40,
            revenue: 5,
            desc: 'Once per Stock Round, on its owner\'s turn, the owner may draw 1 corruption token from the bag ' \
                  'and receive $5 times the current phase number from the bank. This does not use up the ' \
                  'owner\'s turn.',
            color: nil,
          },
          {
            name: '(N) Emisarios de las Sombras',
            sym: '(N)',
            value: 60,
            revenue: 15,
            desc: 'Once per game, during its operating turn, the owning company may remove 1 paramilitary ' \
                  "token from any hex on the board. When doing so, the company's president takes 2 black " \
                  'corruption tokens directly from the stock.',
            color: nil,
          },
        ].freeze

        CORPORATIONS = [
          {
            sym: 'A',
            name: 'Amarilla',
            logo: '18_junta/A',
            simple_logo: '18_junta/A.alt',
            tokens: [0, 40],
            max_ownership_percent: 60,
            float_percent: 50,
            coordinates: 'L6',
            color: '#fcf75e',
            text_color: 'black',
          },
          {
            sym: 'B',
            name: 'Barrizal',
            logo: '18_junta/B',
            simple_logo: '18_junta/B.alt',
            tokens: [0, 40, 80, 120],
            max_ownership_percent: 60,
            float_percent: 50,
            coordinates: 'D10',
            color: '#0099ff',
          },
          {
            sym: 'C',
            name: 'Campesina',
            logo: '18_junta/C',
            simple_logo: '18_junta/C.alt',
            tokens: [0, 40, 80],
            max_ownership_percent: 60,
            float_percent: 50,
            coordinates: 'E3',
            color: '#ff2200',
          },
          {
            sym: 'E',
            name: 'Estelar',
            logo: '18_junta/E',
            simple_logo: '18_junta/E.alt',
            tokens: [0, 40, 80],
            max_ownership_percent: 60,
            float_percent: 50,
            coordinates: 'E13',
            color: '#9900cc',
          },
          {
            sym: 'F',
            name: 'Ferrocarrillera',
            logo: '18_junta/F',
            simple_logo: '18_junta/F.alt',
            tokens: [0, 40, 80],
            max_ownership_percent: 60,
            float_percent: 50,
            coordinates: 'I11',
            color: '#ff9966',
            text_color: 'black',
          },
          {
            sym: 'H',
            name: 'Hijos Muñoz',
            logo: '18_junta/H',
            simple_logo: '18_junta/H.alt',
            tokens: [0, 40, 80],
            max_ownership_percent: 60,
            float_percent: 50,
            coordinates: 'H2',
            color: '#ff99ff',
            text_color: 'black',
          },
          {
            sym: 'M',
            name: 'Montañera',
            logo: '18_junta/M',
            simple_logo: '18_junta/M.alt',
            tokens: [0, 40, 80],
            max_ownership_percent: 60,
            float_percent: 50,
            coordinates: 'J8',
            color: '#9c661f',
          },
          {
            sym: 'V',
            name: 'Valle-verdiana',
            logo: '18_junta/V',
            simple_logo: '18_junta/V.alt',
            tokens: [0, 40],
            max_ownership_percent: 60,
            float_percent: 50,
            coordinates: 'G7',
            color: '#61b229',
          },
        ].freeze
      end
    end
  end
end
