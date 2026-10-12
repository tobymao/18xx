# frozen_string_literal: true

module Engine
  module Game
    module G18Junta
      module Entities
        COMPANIES = [].freeze

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
            tokens: [0, 40],
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
            tokens: [0, 40, 80],
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
