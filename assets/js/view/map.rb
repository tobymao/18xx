# frozen_string_literal: true

require 'view/hex'

module View
  class Map < Snabberb::Component
    needs :game

    def render
      hexes = @game.map.hexes.map do |hex|
        h(Hex, hex: hex)
      end

      h(:svg, { style: { width: '100%', height: '800px' } }, [
        h(:g, { attrs: { transform: 'scale(0.5)' } }, hexes)
      ])
    end
  end
end
