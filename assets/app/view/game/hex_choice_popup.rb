# frozen_string_literal: true

require 'lib/radial_selector'
require 'lib/settings'
require 'view/game/actionable'

module View
  module Game
    # Generic hex-anchored popup rendering one button per staged choice,
    # plus a dismiss button, fanned radially around the hex -- same
    # positioning technique (Lib::RadialSelector) as TileSelector's
    # tile-upgrade fan and TokenSelector's token ring, per crericha's
    # review on this PR (18xx#13141). Cancel sits at the hex's own
    # center; the real choices fan out around it. Mirrors
    # TileConfirmation's role but is driven by an arbitrary
    # Lib::HexChoicePopup instead of a single tile. Every choice value is
    # currently a plain text label -- a future PR (e.g. one offering a
    # tile-image or ore-icon choice) can extend `render_choice` with its
    # own branch alongside the plain-text case here, the same way
    # TileConfirmation's own choice rendering grew.
    class HexChoicePopup < Snabberb::Component
      include Actionable
      include Lib::RadialSelector
      include Lib::Settings

      needs :tile_selector, store: true
      needs :zoom, default: 1
      needs :near_left_edge, default: false
      needs :near_right_edge, default: false
      needs :near_top_edge, default: false
      needs :near_bottom_edge, default: false

      # Roughly matches how far a fanned-out choice can land from the hex,
      # so the edge flip below kicks in before a choice would actually
      # render past the map's own boundary, not right at the point it
      # already has.
      EDGE_MARGIN = 260

      # Same idea as EDGE_MARGIN but for the vertical axis.
      BOTTOM_EDGE_MARGIN = 220

      # How far from the hex's center each non-Cancel choice fans out.
      DISTANCE = 55

      # Caps how many degrees apart two adjacent fanned choices land.
      # Without this, a 2-choice half-circle fan (e.g. Explore/Skip next
      # to a map edge) gets stretched edge-to-edge by list_coordinates'
      # own `angle = angle * count / (count - 1)` adjustment -- for
      # count == 2 that doubles a 180-degree half-circle back to a full
      # 360, landing the two choices diametrically opposite (literally
      # top and bottom of the hex) instead of close together on the side
      # the fan opened toward. Capping the real spread per choice first
      # (same technique TileSelector's own coordinates_for uses via its
      # MAX_ANGLE) keeps that stretch modest regardless of choice count.
      MAX_ANGLE_PER_CHOICE = 70

      def render
        angle, rotation = calc_angle_rotation(@near_left_edge, @near_right_edge, @near_top_edge, @near_bottom_edge)
        count = @tile_selector.choices.size
        if count > 1
          capped = [(count - 1) * MAX_ANGLE_PER_CHOICE, angle].min
          rotation += (angle - capped) / 2.0 if angle < FULL_CIRCLE
          angle = capped
        end
        distance = DISTANCE * @zoom

        choices = list_coordinates(@tile_selector.choices.to_a, distance, 0, angle, rotation).map do |pair, left, bottom|
          choice, label = pair
          render_choice(choice, label, left, bottom)
        end

        h(:div, { style: { position: 'absolute' } }, [*choices, render_cancel])
      end

      # Anchored at (left, bottom) and centered on that point via
      # `transform`, rather than given an explicit width -- so the button
      # shrinks to fit its own label instead of stretching to match
      # whichever other choice in the fan happens to have the longest one.
      def render_choice(choice, label, left, bottom)
        h('button.no_margin', {
            props: { innerHTML: label },
            style: fanned_style(left, bottom).merge(
              backgroundColor: default_for(:green),
              color: '#FFFFFF',
              fontSize: '14px',
              padding: '4px 8px',
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
              fontSize: '14px',
              padding: '4px 8px',
            ),
            on: { click: -> { store(:tile_selector, nil) } },
          })
      end

      # Common positioning for every fanned choice (including Cancel, at
      # distance 0): absolutely placed at the computed (left, bottom),
      # then centered on that point regardless of the button's own
      # rendered size.
      def fanned_style(left, bottom)
        {
          position: 'absolute',
          left: "#{left}px",
          bottom: "#{bottom}px",
          transform: 'translate(-50%, -50%)',
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
