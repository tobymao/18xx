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
        entity = @tile_selector.entity
        tile = @tile_selector.tile
        hex = @tile_selector.hex

        lay_tile_lambda = -> { lay_tile(entity, tile, hex) }

        # If there are 1+ "blocks_hexes_consent" abilities on this hex, get
        # consent from one of the players
        blocking_players = (@game.companies + @game.minors + @game.corporations).each_with_object([]) do |company, players|
          next if company.closed?
          next unless (ability = @game.abilities(company, :blocks_hexes_consent))
          next unless @game.hex_blocked_by_ability?(entity, ability, hex, tile)

          players << company.owner
        end

        if blocking_players.empty?
          lay_tile_lambda
        else
          -> { check_consent(entity, blocking_players, lay_tile_lambda) }
        end
      end

      def lay_tile(entity, tile, hex)
        action = Engine::Action::LayTile.new(
          entity,
          tile: tile,
          hex: hex,
          rotation: tile.rotation,
        )
        store(:tile_selector, nil, skip: true)
        process_action(action)
      end
    end
  end
end
