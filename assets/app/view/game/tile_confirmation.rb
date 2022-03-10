# frozen_string_literal: true

require 'lib/settings'
require 'view/game/actionable'

module View
  module Game
    class TileConfirmation < Snabberb::Component
      include Actionable
      include Lib::Settings

      needs :tile_selector, store: true
      needs :zoom, default: 1

      def render
        button_style = {
          display: 'inline-block',
          cursor: 'pointer',
          fontSize: '35px',
          color: '#FFFFFF',
          filter: 'drop-shadow(3px 3px 2px #888)',
          padding: '6px 2px 8px 2px',
        }

        confirm = {
          props: { innerHTML: '✔' },
          style: {
            backgroundColor: default_for(:green),
            **button_style,
          },
          on: { click: confirm_click },
        }

        cancel = {
          props: { innerHTML: '✖' },
          style: {
            backgroundColor: default_for(:red),
            **button_style,
          },
          on: { click: -> { store(:tile_selector, nil) } },
        }

        div_props = {
          style: {
            display: 'grid',
            gridAutoFlow: 'column',
            gridGap: '5px',
            position: 'absolute',
            left: '-38px',
            top: "#{-68 * @zoom}px",
          },
        }

        h(:div, div_props, [
          h('button.no_margin', cancel),
          h('button.no_margin', confirm),
        ])
      end

      def confirm_click
        # If there is a "blocks_hexes_consent" ability on this hex, get consent
        (@game.companies + @game.minors + @game.corporations).each do |company|
          next if company.closed?
          next unless (ability = @game.abilities(company, :blocks_hexes_consent))
          next unless @game.hex_blocked_by_ability?(@tile_selector.entity, ability, @tile_selector.hex)

          return -> { check_consent(company.owner, -> { lay_tile }) }
        end

        -> { lay_tile }
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
