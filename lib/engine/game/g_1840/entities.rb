# frozen_string_literal: true

module Engine
  module Game
    module G1840
      module Entities
        MARKET = [
            %w[40],
             ].freeze

        PHASES = [
            {
              name: 'a',
              train_limit: 3,
              tiles: %i[yellow],
            },

          ].freeze

        TRAINS = [
            {
              name: '2a',
              distance: 2,
              price: 70,
              rusts_on: '3',
              num: 5,
            },
          ].freeze

        COMPANIES = [
            {
              name: 'Plan - Tachau',
              value: 25,
              revenue: 5,
              sym: 'S1',
              desc: 'May either ignore the cost to build a river tile or ' \
                     'lay a purple-edged green upgrade to town/city hexes',
              color: nil,
            },
          ].freeze

        CORPORATIONS = [
            {
              float_percent: 50,
              float_excludes_market: true,
              sym: 'SX',
              name: 'Sächsische Eisenbahn',
              logo: '18_cz/SX',
              simple_logo: '18_cz/SX.alt',
              max_ownership_percent: 60,
              always_market_price: true,
              tokens: [0, 40],
              coordinates: %w[A8 B5],
              color: :"#e31e24",
              type: 'large',
              reservation_color: nil,
            },
          ].freeze
      end
    end
  end
end
