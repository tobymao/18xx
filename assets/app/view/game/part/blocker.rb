# frozen_string_literal: true

require 'view/game/part/base'

module View
  module Game
    module Part
      class Blocker < Base
        needs :game, default: nil, store: true

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

        PP_LEFT_CORNER = {
          region_weights: LEFT_CORNER,
          x: -65,
          y: 5,
        }.freeze
        PP_BOTTOM_RIGHT = {
          region_weights: [22, 23],
          x: 35,
          y: 60,
        }.freeze
        PP_EDGE_1 = {
          region_weights_in: { [13] => 1, [12, 19] => 0.5 },
          region_weights_out: [13],
          x: -50,
          y: 30,
        }.freeze

        PP_EDGE_4 = {
          region_weights_in: { [10] => 1, [4, 11] => 0.5 },
          region_weights_out: [10],
          x: 50,
          y: -30,
        }.freeze

        def preferred_render_locations
          if @tile.parts.all?(&:border?) # are the only parts borders?
            [
              P_CENTER,
            ]
          elsif layout == :flat
            [
              P_LEFT_CORNER,
              P_BOTTOM_RIGHT,
            ]
          else
            [
              P_LEFT_CORNER,
              PP_BOTTOM_RIGHT,
              PP_EDGE_4,
              PP_EDGE_1,
            ]
          end
        end

        def load_from_tile
          @blocker = @tile.blockers.find { |b| !@tile.hidden_blockers.include?(b) }
        end

        def should_render?
          should_render_company_sym?
        end

        def should_render_company_sym?
          blocker_open? && (!@blocker.owned_by_corporation? ||
                            @game.abilities(@blocker, :tile_lay, time: 'any') ||
                            @game.abilities(@blocker, :teleport, time: 'any'))
        end

        def should_render_barbell?
          blocker_open? && !@blocker.owned_by_corporation?
        end

        def blocker_open?
          !(@blocker.nil? || @blocker.closed?)
        end

        def render_company_sym
          h(:text, {
              attrs: {
                fill: 'black',
                'dominant-baseline': 'baseline',
                x: 0,
                y: -5,
              },
            },
            @blocker.company? ? @blocker.sym : @blocker.name)
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
