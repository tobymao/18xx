# frozen_string_literal: true

module Engine
  module Game
    module G1713Menorca
      module Companies
        CORPORATIONS = [
          {
            sym: 'RNC',
            name: 'Royal Navy Company',
            logo: '1713Menorca/RNC',
            simple_logo: '1713Menorca/RNC.alt',
            tokens: [0, 80],
            coordinates: 'J11',
            color: '#1A3A5C',
            float_percent: 50,
            shares: [20, 10, 10, 10, 10, 10, 10, 10, 10],
          },
          {
            sym: 'RCC',
            name: 'Real Compania de Comercio',
            logo: '1713Menorca/RCC',
            simple_logo: '1713Menorca/RCC.alt',
            tokens: [0, 80],
            coordinates: 'C8',
            color: '#7B2D00',
            float_percent: 50,
            shares: [20, 10, 10, 10, 10, 10, 10, 10, 10],
          },
          {
            sym: 'RAM',
            name: 'Ramaders i Artesans de Menorca',
            logo: '1713Menorca/RAM',
            simple_logo: '1713Menorca/RAM.alt',
            tokens: [0, 30, 60],
            coordinates: 'G8',
            color: '#2D5A1B',
            float_percent: 50,
            shares: [20, 10, 10, 10, 10, 10, 10, 10, 10],
          },
          {
            sym: 'CLV',
            name: 'Compagnie du Levant',
            logo: '1713Menorca/CLV',
            simple_logo: '1713Menorca/CLV.alt',
            tokens: [0, 80],
            coordinates: 'J11',
            city: 1,
            color: '#4A235A',
            float_percent: 50,
            shares: [20, 10, 10, 10, 10, 10, 10, 10, 10],
          },
        ].freeze
      end
    end
  end
end
