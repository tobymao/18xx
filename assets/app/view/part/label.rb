# frozen_string_literal: true

require 'view/part/base'

module View
  module Part
    # letter label, like "Z", "H", "OO"
    class Label < Base
      # left of center
      SINGLE_CITY_ONE_SLOT = [{
        region_weights: { (LEFT_MID + LEFT_CORNER) => 1, LEFT_CENTER => 0.5 },
        x: -55,
        y: 0,
      }].freeze

      P_LEFT_CORNER = {
        region_weights: { LEFT_CORNER => 1.0, (LEFT_CENTER + LEFT_MID) => 0.5 },
        x: -71.25,
        y: 0,
      }.freeze

      SINGLE_CITY_MULTI_SLOT = [P_LEFT_CORNER].freeze

      MULTI_CITY_LOCATIONS = [
        # top center
        {
          region_weights: { [2] => 1.0, [1, 3] => 0.5 },
          x: 0,
          y: -60,
        },
        # edge 2
        {
          region_weights: { [6] => 1.0, [5, 7] => 0.5 },
          x: -50,
          y: -31,
        },
        # edge 5
        {
          region_weights: { [17] => 1.0, [16, 18] => 0.5 },
          x: 50,
          y: 37,
        },
        # top left corner
        {
          region_weights: { [0, 1] => 1.0 },
          x: -30,
          y: -65,
        },
        # top right corner
        {
          region_weights: { [3, 4] => 1.0 },
          x: 30,
          y: -65,
        },
        # bottom left corner
        {
          region_weights: { [19, 20] => 1.0 },
          x: -30,
          y: 65,
        },
      ].freeze

      def preferred_render_locations
        if (@tile.cities + @tile.towns).one?
          if @tile.cities.one? && (@tile.cities.first.slots > 1)
            SINGLE_CITY_MULTI_SLOT
          else
            SINGLE_CITY_ONE_SLOT
          end
        elsif @tile.cities.size > 1
          MULTI_CITY_LOCATIONS
        else
          [P_LEFT_CORNER]
        end
      end

      def load_from_tile
        @label = @tile.label.to_s
      end

      def render_part
        attrs = {
          transform: translate,
          'pointer-events': 'none',
        }

        text_attrs = {
          fill: 'black',
          transform: 'scale(2.5)',
          'text-anchor': 'middle',
          'alignment-baseline': 'middle',
          'dominant-baseline': 'middle',
        }

        h(:g, { attrs: attrs }, [
          h(:text, { attrs: text_attrs }, @label)
        ])
      end
    end
  end
end
