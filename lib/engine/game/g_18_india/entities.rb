# frozen_string_literal: true

module Engine
  module Game
    module G18India
      module Entities
        COMPANIES = [
          {
            name: 'Swedish EIC',
            sym: 'P1',
            value: 25,
            revenue: 5,
            desc: 'No special abilities.',
            color: nil,
          },
          {
            name: 'Portuguese EIC',
            sym: 'P2',
            value: 35,
            revenue: 5,
            desc: 'One extra yellow tile placement. Close when used.',
            color: nil,
            # TODO Add Ability
          },
          {
            name: 'Dutch EIC',
            sym: 'P3',
            value: 60,
            revenue: 10,
            desc: 'One extra track upgade. Close when used.',
            color: nil,
            # TODO Add Ability
          },
          {
            name: 'French EIC',
            sym: 'P4',
            value: 75,
            revenue: 15,
            desc: '$40 Terrain cost discount. Close when used.',
            color: nil,
            # TODO Add Ability
          },
          {
            name: 'Danish EIC',
            sym: 'P5',
            value: 115,
            revenue: 20,
            desc: 'One free station, even if full. Close when used.',
            color: nil,
            # TODO Add Ability
          },
          {
            name: 'British EIC',
            sym: 'P6',
            value: 150,
            revenue: 25,
            desc: 'Receives jewlery concession. Close when used.',
            color: nil,
            # TODO Add Ability
          },
        ].freeze

        CORPORATIONS = [
          {
            name: 'Great Indian Peninsula Railway',
            sym: 'GIPR',
            #logo: '18India/GIPR',
            tokens: [0, 40, 100, 100, 100],
            # Add Exchange Tokens
            # No president cert / Pres cert is 10%
            # par_price: 112
            float_percent: 30,
            max_ownership_percent: 100,
            # Can start in any open city
            #coordinates: '',
            color: 'white',
          },
          {
            name: 'Northwestern Railway',
            sym: 'NW',
            #logo: '18India/NW',
            tokens: [0, 40, 100, 100],
            # par_price: 100
            float_percent: 20,
            max_ownership_percent: 100,
            coordinates: 'G8',
            color: '#000000',
          },
          {
            name: 'East India Railway',
            sym: 'EI',
            #logo: '18India/EI',
            tokens: [0, 40, 100],
            # par_price: 110
            float_percent: 20,
            max_ownership_percent: 100,
            coordinates: 'P17',
            color: '#000000',
          },
          {
            name: 'North Central Railway',
            sym: 'NC',
            #logo: '18India/',
            tokens: [0, 40, 100, 100, 100],
            # par_price: 112
            float_percent: 20,
            max_ownership_percent: 100,
            coordinates: 'K14',
            color: '#000000',
          },
          {
            name: '',
            sym: '',
            #logo: '18India/',
            tokens: [0, 40, 100, 100, 100],
            # par_price: 112
            float_percent: 20,
            max_ownership_percent: 100,
            coordinates: '',
            color: '#000000',
          },

          {
            name: 'Bengal Nagur Railway',
            sym: 'BNR',
            #logo: '18India/BNR',
            tokens: [0, 40, 100, 100, 100],
            float_percent: 20,
            max_ownership_percent: 100,
            coordinates: 'I20',
            color: 'brown',
          },
          {
            name: 'Bombay Railway',
            sym: 'BR',
            #logo: '18India/BR',
            tokens: [0, 40, 100],
            float_percent: 20,
            max_ownership_percent: 100,
            coordinates: 'D23',
            color: 'purple',
          },
        ].freeze
      end
    end
  end
end
