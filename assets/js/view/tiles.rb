# frozen_string_literal: true

require 'snabberb'

require 'engine/tile'

module View
  class Tiles < Snabberb::Component
    def render
      tile_ids = [
        Engine::Tile::YELLOW.keys,
        Engine::Tile::GREEN.keys,
        Engine::Tile::BROWN.keys,
        Engine::Tile::GRAY.keys,
      ].reduce(&:+)

      # TODO?: iterate over tile_ids just once
      generic_tiles = tile_ids.reject { |id| id =~ /;/ }
      game_tiles = tile_ids.select { |id| id =~ /;/ }

      children = (generic_tiles + game_tiles).flat_map do |tile|
        render_tile_block(tile)
      end

      h(
        :div,
        { attrs: { id: 'tiles' } },
        children,
      )
    end

    def render_tile_block(tile_id)
      [
        h(:div, { style: {
            display: 'inline-block',
            width: '80px',
            height: '97px',
            'outline-style': 'solid',
            'outline-width': 'thin',
            'margin-top': '10px',
            'margin-right': '1px',
          } }, [
            h(:div, { style: { 'text-align': 'center' } }, tile_id),
            h(:svg, { style: { width: '100%', height: '100%' } }, [
                h(:g, { attrs: { transform: 'scale(0.4)' } }, [
                    h(
                      Hex,
                      hex: Engine::Hex.new('A1', layout: 'flat', tile: Engine::Tile.for(tile_id)),
                      role: :tile_selector
                    )
                  ])
              ])
          ])
      ]
    end
  end
end
