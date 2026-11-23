# frozen_string_literal: true

require 'lib/radial_selector'
require 'lib/settings'
require 'view/game/actionable'

module View
  module Game
    # Hex-anchored popup of staged choices, fanned radially around the hex
    # (Lib::RadialSelector) with Cancel at its center -- the third selector
    # alongside TileSelector and TokenSelector. A choice value is currently
    # always a text label; see render_choice to extend it.
    class HexChoiceSelector < Snabberb::Component
      include Actionable
      include Lib::RadialSelector
      include Lib::Settings

      needs :tile_selector, store: true
      needs :zoom, default: 1
      needs :near_left_edge, default: false
      needs :near_right_edge, default: false
      needs :near_top_edge, default: false
      needs :near_bottom_edge, default: false

      EDGE_MARGIN = 260
      BOTTOM_EDGE_MARGIN = 220

      # Fan radius at 1x zoom. Wide enough that the widest expected label
      # ("Transshipment ($XX)") and Cancel, landing on the same horizontal
      # line, don't overlap -- centers need ~89px of separation plus a gap.
      BASE_DISTANCE = 100

      BASE_FONT_SIZE = 14
      BASE_PAD_V = 4
      BASE_PAD_H = 8

      # Caps the spread between adjacent choices -- without it,
      # list_coordinates' own angle stretch doubles a 2-choice half-circle
      # fan into a full circle, landing them diametrically opposite instead
      # of together.
      MAX_ANGLE_PER_CHOICE = 70

      def render
        angle, rotation = calc_angle_rotation(@near_left_edge, @near_right_edge, @near_top_edge, @near_bottom_edge)
        count = @tile_selector.choices.size
        if count > 1
          capped = [(count - 1) * MAX_ANGLE_PER_CHOICE, angle].min
          rotation += (angle - capped) / 2.0 if angle < FULL_CIRCLE
          angle = capped
        end
        distance = BASE_DISTANCE * @zoom

        choices = list_coordinates(@tile_selector.choices.to_a, distance, 0, angle, rotation).map do |pair, left, bottom|
          choice, label = pair
          render_choice(choice, label, left, bottom)
        end

        h(:div, { style: { position: 'absolute' } }, [*choices, render_cancel])
      end

      def render_choice(choice, label, left, bottom)
        h('button.no_margin', {
            props: { innerHTML: label },
            style: fanned_style(left, bottom).merge(
              backgroundColor: default_for(:green),
              color: '#FFFFFF',
              fontSize: "#{BASE_FONT_SIZE * @zoom}px",
              padding: "#{BASE_PAD_V * @zoom}px #{BASE_PAD_H * @zoom}px",
              whiteSpace: 'nowrap',
            ),
            on: { click: -> { choose(choice) } },
          })
      end

      def render_cancel
        h('button.no_margin', {
            props: { innerHTML: '✖' },
            style: fanned_style(0, 0).merge(
              backgroundColor: default_for(:red),
              color: '#FFFFFF',
              fontSize: "#{BASE_FONT_SIZE * @zoom}px",
              padding: "#{BASE_PAD_V * @zoom}px #{BASE_PAD_H * @zoom}px",
            ),
            on: { click: -> { store(:tile_selector, nil) } },
          })
      end

      # Anchored at (left, bottom), centered on that point regardless of
      # the button's own rendered size.
      def fanned_style(left, bottom)
        {
          position: 'absolute',
          left: "#{left}px",
          bottom: "#{bottom}px",
          transform: 'translate(-50%, 50%)',
          display: 'inline-block',
          width: 'max-content',
          cursor: 'pointer',
          filter: 'drop-shadow(3px 3px 2px #888)',
        }
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
