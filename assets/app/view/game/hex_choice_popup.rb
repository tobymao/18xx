# frozen_string_literal: true

require 'lib/settings'
require 'view/game/actionable'

module View
  module Game
    # Generic hex-anchored popup rendering one button per staged choice,
    # plus a dismiss button. Mirrors TileConfirmation's positioning/style
    # but is driven by an arbitrary Lib::HexChoicePopup instead of a
    # single tile. Every choice value is currently a plain text label --
    # a future PR (e.g. one offering a tile-image or ore-icon choice) can
    # extend `render` with its own branch alongside the plain-text case
    # here, the same way TileConfirmation's own choice rendering grew.
    class HexChoicePopup < Snabberb::Component
      include Actionable
      include Lib::Settings

      needs :tile_selector, store: true
      needs :zoom, default: 1
      needs :near_right_edge, default: false
      needs :near_top_edge, default: false
      needs :near_bottom_edge, default: false

      # Roughly matches the popup's own max-width (POPUP_MAX_WIDTH) plus
      # its drop shadow, so the edge flip below kicks in before any
      # clipping would actually occur, not right at the point it already
      # has.
      EDGE_MARGIN = 260

      # Same idea as EDGE_MARGIN but for the vertical axis -- large enough
      # to flip before a popup stacking several choice buttons actually
      # runs off the bottom of the map.
      BOTTOM_EDGE_MARGIN = 220

      # Bounds how wide the popup can grow regardless of label length --
      # long choice text wraps onto additional lines instead of
      # extending the row sideways past this width.
      POPUP_MAX_WIDTH = 220

      def render
        button_style = {
          display: 'inline-block',
          cursor: 'pointer',
          fontSize: '14px',
          color: '#FFFFFF',
          filter: 'drop-shadow(3px 3px 2px #888)',
          padding: '4px 8px',
          whiteSpace: 'normal',
          maxWidth: "#{POPUP_MAX_WIDTH}px",
        }

        buttons = @tile_selector.choices.map do |choice, label|
          h('button.no_margin', {
              props: { innerHTML: label },
              style: { backgroundColor: default_for(:green), **button_style },
              on: { click: -> { choose(choice) } },
            })
        end

        cancel = h('button.no_margin', {
                     props: { innerHTML: '✖' },
                     style: { backgroundColor: default_for(:red), **button_style },
                     on: { click: -> { store(:tile_selector, nil) } },
                   })

        style = {
          display: 'flex',
          flexWrap: 'wrap',
          gap: '5px',
          maxWidth: "#{POPUP_MAX_WIDTH}px",
          position: 'absolute',
        }
        # Flips which edge the offset is measured from -- not just the
        # sign of the value -- so the button row grows back toward the
        # hex (and the rest of the map) instead of past whichever
        # boundary it's close to.
        if @near_right_edge
          style[:right] = '-60px'
        else
          style[:left] = '-60px'
        end
        # Same flip idea as near_right_edge above, but anchoring from the
        # bottom instead of the top so the box grows upward, away from
        # the map's own bottom edge, instead of downward past it.
        if @near_bottom_edge
          style[:bottom] = '8px'
        elsif @near_top_edge
          style[:top] = '8px'
        else
          style[:top] = "#{-68 * @zoom}px"
        end

        div_props = { style: style }

        h(:div, div_props, [*buttons, cancel])
      end

      def choose(choice)
        entity = @tile_selector.entity
        label = @tile_selector.choices[choice]

        dispatch = lambda do
          store(:tile_selector, nil, skip: true)
          process_action(Engine::Action::Choose.new(entity, choice: choice))
        end

        if (consenter = @game.consenter_for_choice(entity, choice, label))
          check_consent(entity, consenter, dispatch)
        else
          dispatch.call
        end
      end
    end
  end
end
