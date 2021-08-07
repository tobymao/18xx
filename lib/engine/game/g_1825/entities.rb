# frozen_string_literal: true

module Engine
  module Game
    module G1825
      module Entities
        COMPANIES = [
          {
            name: 'Arbroath & Forfar',
            sym: 'A&F',
            value: 30,
            revenue: 5,
            color: :Green,
            abilities: [{ type: 'no_buy' }],
          },
          {
            name: 'Tanfield Wagon Way',
            sym: 'TWW',
            value: 60,
            revenue: 10,
            color: :Green,
            abilities: [{ type: 'no_buy' }],
          },
          {
            name: 'Stockton & Darlington',
            sym: 'S&D',
            value: 160,
            revenue: 25,
            color: :Green,
            abilities: [{ type: 'no_buy' }],
          },
        ].freeze

        CORPORATIONS = [
          {
            sym: 'CR',
            name: 'Caledonia Railway',
            tokens: [0, 40, 100, 100],
            coordinates: 'G5',
            city: 2,
            color: :Blue,
            reservation_color: nil,
          },
          {
            sym: 'NBR',
            name: 'North British Railway',
            tokens: [0, 40, 100, 100],
            coordinates: 'G5',
            city: 1,
            color: '#868c1b',
            reservation_color: nil,
          },
          {
            sym: 'GS',
            name: 'Glasgow & South West Railway Company',
            tokens: [0, 40, 100],
            coordinates: 'G5',
            city: 0,
            color: '#8c1b2f',
            reservation_color: nil,
          },
          {
            sym: 'GN',
            name: 'Great North of Scotland Railway',
            tokens: [0],
            coordinates: 'B12',
            city: 0,
            color: '#0c6b0c',
            traincost: 550,
            train: '5',
          },
          {
            sym: 'HR',
            name: 'Highland Railway',
            tokens: [0],
            coordinates: 'B8',
            city: 0,
            color: '#e0b53d',
            traincost: 410,
            train: 'U3',
          },
          {
            sym: 'M&C',
            name: 'Maryport and Carslisle Railway Company',
            tokens: [0],
            coordinates: 'K7',
            city: 0,
            color: '#1b967a',
            traincost: 370,
            train: '3T',
          },
        ].freeze
      end
    end
  end
end
