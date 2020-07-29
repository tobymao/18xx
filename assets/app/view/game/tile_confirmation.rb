# frozen_string_literal: true

require 'view/game/actionable'

module View
  module Game
    class TileConfirmation < Snabberb::Component
      include Actionable

      needs :tile_selector, store: true

      def render
        confirm = {
          props: { innerHTML: '☑' },
          style: {
            position: 'absolute',
            cursor: 'pointer',
            left: '-26px',
            top: '-50px',
            color: 'black',
            fontSize: '35px',
          },
          on: { click: -> { lay_tile } },
        }

        delete = {
          props: { innerHTML: '☒' },
          style: {
            position: 'absolute',
            cursor: 'pointer',
            left: '6px',
            top: '-50px',
            color: 'black',
            fontSize: '35px',
          },
          on: { click: -> { store(:tile_selector, nil) } },
        }

        h(:div, [
          h(:div, confirm),
          h(:div, delete),
        ])
      end

      def lay_tile
        action = Engine::Action::LayTile.new(
          @tile_selector.entity,
          tile: @tile_selector.tile,
          hex: @tile_selector.hex,
          rotation: @tile_selector.tile.rotation,
        )
        store(:tile_selector, nil, skip: true)
        process_action(action)
      end
    end
  end
end
