# frozen_string_literal: true

require 'view/game/part/base'

module View
  module Game
    module Part
      # letter label, like "Z", "H", "OO"
      class Label < Base
        needs :label

        # left of center
        SINGLE_CITY_ONE_SLOT = {
          flat: {
            region_weights: { (LEFT_MID + LEFT_CORNER) => 1, LEFT_CENTER => 0.5 },
            x: -55,
            y: 0,
          },
          pointy: {
            region_weights: { [5, 12] => 1.0, [6] => 0.25 },
            x: -65,
            y: 0,
          },
        }.freeze
        # right of center
        SINGLE_CITY_ONE_SLOT_RIGHT = {
          flat: {
            region_weights: { (RIGHT_MID + RIGHT_CORNER) => 1, RIGHT_CENTER => 0.5 },
            x: 55,
            y: 0,
          },
          pointy: {
            region_weights: { [11, 18] => 1.0, [17] => 0.25 },
            x: 65,
            y: 0,
          },
        }.freeze

        P_LEFT_CORNER = {
          flat: {
            region_weights: { LEFT_CORNER => 1.0 },
            x: -71.25,
            y: 0,
          },
          pointy: {
            region_weights: { LEFT_CORNER => 1.0 },
            x: -67,
            y: 0,
          },
        }.freeze

        P_RIGHT_CORNER = {
          flat: {
            region_weights: { RIGHT_CORNER => 1.0 },
            x: 71.25,
            y: 0,
          },
          pointy: {
            region_weights: { RIGHT_CORNER => 1.0 },
            x: 67,
            y: 0,
          },
        }.freeze

        P_BOTTOM_LEFT_CORNER = {
          flat: {
            region_weights: { BOTTOM_LEFT_CORNER => 1.0 },
            x: -30,
            y: 65,
          },
          pointy: {
            region_weights: { BOTTOM_LEFT_CORNER => 1.0 },
            x: -30,
            y: 61,
          },
        }.freeze

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
            region_weights: { UPPER_LEFT_CORNER => 1.0 },
            x: -40,
            y: -65,
          },
          # top right corner
          {
            region_weights: { UPPER_RIGHT_CORNER => 1.0 },
            x: 40,
            y: -65,
          },
          P_LEFT_CORNER[:flat],
          P_RIGHT_CORNER[:flat],
          P_BOTTOM_LEFT_CORNER[:flat],
          # bottom right corner
          {
            region_weights: { BOTTOM_RIGHT_CORNER => 1.0 },
            x: 40,
            y: 65,
          },
          # edge 1
          {
            region_weights: { [12, 13] => 1.0 },
            x: -50,
            y: 25,
          },
          # bottom center
          {
            region_weights: { [21] => 1.0, [20, 22] => 0.5 },
            x: 0,
            y: 60,
          },
        ].freeze

        POINTY_MULTI_CITY_LOCATIONS = [
          # top center
          {
            region_weights: { [2] => 1.0, [3] => 0.5 },
            x: 0,
            y: -60,
          },
          # edge 2
          {
            region_weights: { [6] => 1.0, [5] => 0.25 },
            x: -50,
            y: -31,
          },
          # top left corner
          {
            region_weights: { UPPER_LEFT_CORNER => 1.0 },
            x: -30,
            y: -65,
          },
          # edge 1
          {
            region_weights: { [13, 14] => 1.0 },
            x: -50,
            y: 25,
          },
          P_LEFT_CORNER[:pointy],
          P_BOTTOM_LEFT_CORNER[:pointy],
          # top right corner
          {
            region_weights: { UPPER_RIGHT_CORNER => 1.0, [2] => 0.5 },
            x: 30,
            y: -65,
          },
          # edge 4
          {
            region_weights: { [10] => 1.0, [4, 11] => 0.25 },
            x: 67,
            y: 0,
          },
          # edge 5
          {
            region_weights: { [17] => 1.0, [18, 23] => 0.25 },
            x: 50,
            y: 37,
          },
        ].freeze

        def preferred_render_locations
          if @tile.city_towns.one?
            if @tile.cities.one? && (@tile.cities.first.slots > 1)
              [P_LEFT_CORNER[layout]]
            else
              [SINGLE_CITY_ONE_SLOT[layout], SINGLE_CITY_ONE_SLOT_RIGHT[layout], P_RIGHT_CORNER[layout]]
            end
          elsif @tile.city_towns.size > 1 && layout == :flat
            MULTI_CITY_LOCATIONS
          elsif @tile.city_towns.size > 1
            POINTY_MULTI_CITY_LOCATIONS
          elsif layout == :flat
            [P_LEFT_CORNER[layout]]
          else
            [P_LEFT_CORNER[layout], P_BOTTOM_LEFT_CORNER[layout]]
          end
        end

        def render_part
          h(:g, { attrs: { transform: "#{translate} #{rotation_for_layout}" } }, [
            h('text.tile__text', { attrs: { transform: 'scale(1.5)' } }, @label.to_s),
          ])
        end
      end
    end
  end
end
