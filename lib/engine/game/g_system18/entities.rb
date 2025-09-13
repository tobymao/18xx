# frozen_string_literal: true

module Engine
  module Game
    module GSystem18
      module Entities
        def game_companies
          return [] unless respond_to?("map_#{map_name}_game_companies")

          send("map_#{map_name}_game_companies")
        end

        def game_minors
          return [] unless respond_to?("map_#{map_name}_game_minors")

          send("map_#{map_name}_game_minors")
        end

        S18_CORPORATIONS = [
          {
            float_percent: 60,
            sym: 'DGN',
            name: 'Dragon',
            logo: 'System18/DGN',
            simple_logo: 'System18/DGN.alt',
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
            simple_logo: 'System18/GFN.alt',
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
            simple_logo: 'System18/PHX.alt',
            tokens: [0, 40, 100],
            coordinates: nil,
            color: '#ff7518',
            text_color: 'black',
            reservation_color: nil,
            max_ownership_percent: 60,
          },
          {
            float_percent: 60,
            sym: 'KKN',
            name: 'Kraken',
            logo: 'System18/KKN',
            simple_logo: 'System18/KKN.alt',
            tokens: [0, 40, 100],
            coordinates: nil,
            color: '#0096ff',
            reservation_color: nil,
            max_ownership_percent: 60,
          },
          {
            float_percent: 60,
            sym: 'SPX',
            name: 'Sphinx',
            logo: 'System18/SPX',
            simple_logo: 'System18/SPX.alt',
            tokens: [0, 40, 100],
            coordinates: nil,
            color: '#fafa33',
            text_color: 'black',
            reservation_color: nil,
            max_ownership_percent: 60,
          },
        ].freeze

        def game_corporations
          # start with standard set of corps
          corps = []
          S18_CORPORATIONS.each { |c| corps << c.dup }

          send("map_#{map_name}_game_corporations", corps)
        end
      end
    end
  end
end
