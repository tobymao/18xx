# frozen_string_literal: true

module Engine
  module Game
    module GSystem18
      module Entities
        def game_companies
          []
        end

        S18_CORPORATIONS = [
          {
            float_percent: 60,
            sym: 'DGN',
            name: 'Dragon',
            logo: 'System18/DGN',
            tokens: [0, 40, 100],
            coordinates: nil,
            color: '#50c878',
            reservation_color: nil,
            max_ownership_percent: 60,
          },
          {
            float_percent: 60,
            sym: 'GFN',
            name: 'Griffin',
            logo: 'System18/GFN',
            tokens: [0, 40, 100],
            coordinates: nil,
            color: '#999999',
            reservation_color: nil,
            max_ownership_percent: 60,
          },
          {
            float_percent: 60,
            sym: 'PHX',
            name: 'Phoenix',
            logo: 'System18/PHX',
            tokens: [0, 40, 100],
            coordinates: nil,
            color: :'#ff7518',
            text_color: 'black',
            reservation_color: nil,
            max_ownership_percent: 60,
          },
          {
            float_percent: 60,
            sym: 'KKN',
            name: 'Kraken',
            logo: 'System18/KKN',
            tokens: [0, 40, 100],
            coordinates: nil,
            color: :'#0096ff',
            reservation_color: nil,
            max_ownership_percent: 60,
          },
          {
            float_percent: 60,
            sym: 'SPX',
            name: 'Sphinx',
            logo: 'System18/SPX',
            tokens: [0, 40, 100],
            coordinates: nil,
            color: :'#fafa33',
            text_color: 'black',
            reservation_color: nil,
            max_ownership_percent: 60,
          },
        ].freeze

        def game_corporations
          # start with standard set of corps
          corps = []
          S18_CORPORATIONS.each { |c| corps << c.dup }

          # change based on maps
          if map?(:France)
            corps.each_with_index do |c, idx|
              c[:float_percent] = 20
              c[:always_market_price] = true
              c[:coordinates] = %w[C5 C5 C5 C9 E7][idx]
              c[:city] = [0, 1, 2, nil, nil][idx]
            end
          else
            # NEUS
            corps.each_with_index do |c, idx|
              c[:coordinates] = %w[B7 D9 B5 C10 B11][idx]
            end
          end

          corps
        end
      end
    end
  end
end
