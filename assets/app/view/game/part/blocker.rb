# frozen_string_literal: true

require 'view/game/part/base'

module View
  module Game
    module Part
      class Blocker < Base
        # prefix these constant names with "P" (for "PART") to avoid conflicts
        # with constants in Part::Base
        P_CENTER = {
          region_weights: CENTER,
          x: 0,
          y: 0,
          scale: 1.5,
        }.freeze
        P_LEFT_CORNER = {
          region_weights_in: LEFT_CORNER + [13],
          region_weights_out: LEFT_CORNER,
          x: -65,
          y: 5,
        }.freeze
        P_BOTTOM_RIGHT = {
          region_weights_in: [17, 22, 23],
          region_weights_out: [22, 23],
          x: 35,
          y: 60,
        }.freeze

        def preferred_render_locations
          if @tile.parts.one?
            [
              P_CENTER,
            ]
          else
            [
              P_LEFT_CORNER,
              P_BOTTOM_RIGHT,
            ]
          end
        end

        def load_from_tile
          @blocker = @tile.blockers.first
        end

        def should_render?
          should_render_company_sym?
        end

        def should_render_company_sym?
          blocker_open? && (!@blocker.owned_by_corporation? || @blocker.abilities(:tile_lay))
        end

        def should_render_barbell?
          blocker_open? && !@blocker.owned_by_corporation?
        end

        def blocker_open?
          !(@blocker.nil? || @blocker.closed?)
        end

        def render_company_sym
          h(:text, { attrs: {
                       fill: 'black',
                       'dominant-baseline': 'baseline',
                       x: 0,
                       y: -5,
                     } },
            @blocker.sym)
        end

        def render_barbell
          h(:g, [
            h(:path, attrs: { fill: 'white', d: 'M -11 6 A 44 44 0 0 0 11 6' }),
            h(:circle, attrs: { fill: 'white', r: 6, cx: 11, cy: 6 }),
            h(:circle, attrs: { fill: 'white', r: 6, cx: -11, cy: 6 }),
          ])
        end

        def render_part
          children = []
          children << render_company_sym if should_render_company_sym?
          children << render_barbell if should_render_barbell?

          h(:g, { attrs: { transform: "#{translate} #{scale} #{rotation_for_layout}" } }, children)
        end
      end
    end
  end
end
