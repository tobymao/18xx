# frozen_string_literal: true

module Engine
  module Game
    module G1864
      module Entities
        COMPANIES = [].freeze

        CORPORATIONS = [
          {
            sym: 'N',
            name: 'Nikolaev Railway',
            logo: '1861/N',
            simple_logo: '1861/N.alt',
            float_percent: 100,
            always_market_price: true,
            tokens: [0],
            shares: [100],
            max_ownership_percent: 100,
            type: 'minor',
            coordinates: 'B2',
            color: '#d30869',
          },
          {
            sym: 'MK',
            name: 'Moscow & Kazan Railway',
            logo: '1861/MK',
            simple_logo: '1861/MK.alt',
            float_percent: 20,
            always_market_price: true,
            tokens: [0, 20, 40],
            type: 'major',
            color: '#7b352a',
          },
        ].freeze
      end
    end
  end
end
