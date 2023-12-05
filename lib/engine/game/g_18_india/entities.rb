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
          }
        ].freeze

        CORPORATIONS = [
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
