# frozen_string_literal: true

require 'view/game/part/base'

module View
  module Game
    module Part
      module SmallItem
        def preferred_render_locations_by_loc
          parts = parts_for_loc

          if layout == :pointy
            case @loc.to_s
            when '0.5'
              parts.one? ? [PP_BOTTOM_LEFT_CORNER] : [PP_WIDE_BOTTOM_LEFT_CORNER]
            when '1.5'
              parts.one? ? [PP_UPPER_LEFT_CORNER] : [PP_WIDE_UPPER_LEFT_CORNER]
            when '2.5'
              parts.one? ? [PP_TOP_CORNER] : [PP_WIDE_TOP_CORNER]
            when '3.5'
              parts.one? ? [PP_UPPER_RIGHT_CORNER] : [PP_WIDE_UPPER_RIGHT_CORNER]
            when '4.5'
              parts.one? ? [PP_BOTTOM_RIGHT_CORNER] : [PP_WIDE_BOTTOM_RIGHT_CORNER]
            when '5.5'
              parts.one? ? [PP_BOTTOM_CORNER] : [PP_WIDE_BOTTOM_CORNER]
            else
              @loc = nil
              preferred_render_locations
            end
          else
            @loc = nil
            preferred_render_locations
          end
        end

        P_RIGHT_CORNER = {
          region_weights: Base::RIGHT_CORNER,
          x: 75,
          y: 0,
        }.freeze

        P_LEFT_CORNER = {
          region_weights: Base::LEFT_CORNER,
          x: -75,
          y: 0,
        }.freeze

        P_UPPER_LEFT_CORNER = {
          region_weights: Base::UPPER_LEFT_CORNER,
          x: -35,
          y: -60.62,
        }.freeze

        P_BOTTOM_LEFT_CORNER = {
          region_weights: Base::BOTTOM_LEFT_CORNER,
          x: -35,
          y: 60.62,
        }.freeze

        P_BOTTOM_RIGHT_CORNER = {
          region_weights: Base::BOTTOM_RIGHT_CORNER,
          x: 35,
          y: 60.62,
        }.freeze

        PP_BOTTOM_RIGHT_CORNER = {
          region_weights: Base::RIGHT_CORNER,
          x: 65,
          y: 37.5,
        }.freeze

        PP_UPPER_LEFT_CORNER = {
          region_weights: Base::LEFT_CORNER,
          x: -65,
          y: -37.5,
        }.freeze

        PP_UPPER_RIGHT_CORNER = {
          region_weights: Base::UPPER_RIGHT_CORNER,
          x: 65,
          y: -37.5,
        }.freeze

        PP_TOP_CORNER = {
          region_weights: Base::UPPER_LEFT_CORNER,
          x: -0,
          y: -75,
        }.freeze

        PP_TOP_LEFT_CORNER = {
          region_weights: Base::UPPER_LEFT_CORNER,
          x: -65,
          y: -37.5,
        }.freeze

        PP_TOP_RIGHT_CORNER = {
          region_weights: Base::UPPER_RIGHT_CORNER,
          x: 65,
          y: -37.5,
        }.freeze

        PP_BOTTOM_RIGHT_CORNER = {
          region_weights: Base::BOTTOM_LEFT_CORNER,
          x: 65,
          y: 37.5,
        }.freeze

        PP_BOTTOM_LEFT_CORNER = {
          region_weights: Base::BOTTOM_LEFT_CORNER,
          x: -65,
          y: 37.5,
        }.freeze

        PP_BOTTOM_CORNER = {
          region_weights: Base::BOTTOM_RIGHT_CORNER,
          x: 0,
          y: 75,
        }.freeze

        PP_RIGHT_CORNER = {
          region_weights: [9, 10],
          x: 60,
          y: 0,
        }.freeze

        PP_LEFT_CORNER = {
          region_weights: [13, 14],
          x: -60,
          y: 0,
        }.freeze

        P_WIDE_TOP_CORNER = {
          region_weights: [0, 1, 2, 3, 4],
          x: 0,
          y: -65,
        }.freeze

        P_WIDE_BOTTOM_CORNER = {
          region_weights: [19, 20, 21, 22, 23],
          x: 0,
          y: 65,
        }.freeze

        PP_WIDE_TOP_CORNER = {
          region_weights: [0, 1, 2, 3, 5, 6],
          x: 0,
          y: -65,
        }.freeze

        PP_WIDE_BOTTOM_CORNER = {
          region_weights: [17, 18, 20, 21, 22, 23],
          x: 0,
          y: 60,
        }.freeze

        PP_TALL_LEFT_CORNER = {
          region_weights: [12, 13, 14, 19],
          x: -60,
          y: 0,
        }.freeze

        PP_TALL_RIGHT_CORNER = {
          region_weights: [4, 9, 10, 11],
          x: 60,
          y: 0,
        }.freeze

        PP_WIDER_TOP_CORNER = {
          region_weights: [4, 10, 12, 13],
          x: 0,
          y: -16,
        }.freeze

        PP_WIDER_BOTTOM_CORNER = {
          region_weights: [10, 11, 13, 19],
          x: 0,
          y: 16,
        }.freeze

        PP_WIDE_UPPER_RIGHT_CORNER = {
          region_weights: Base::RIGHT_CORNER,
          x: 52,
          y: -25,
        }.freeze

        PP_WIDE_UPPER_LEFT_CORNER = {
          region_weights: Base::LEFT_CORNER,
          x: -52,
          y: -25,
        }.freeze

        PP_WIDE_BOTTOM_RIGHT_CORNER = {
          region_weights: [9, 10, 11, 16],
          x: 52,
          y: 25,
        }.freeze

        PP_WIDE_BOTTOM_LEFT_CORNER = {
          region_weights: [13, 14, 15, 19],
          x: -52,
          y: 25,
        }.freeze

        SMALL_ITEM_LOCATIONS = [P_RIGHT_CORNER,
                                P_LEFT_CORNER,
                                P_BOTTOM_RIGHT_CORNER,
                                P_UPPER_LEFT_CORNER,
                                P_BOTTOM_LEFT_CORNER].freeze

        POINTY_SMALL_ITEM_LOCATIONS = [PP_LEFT_CORNER,
                                       PP_RIGHT_CORNER,
                                       PP_TOP_CORNER,
                                       PP_BOTTOM_CORNER,
                                       PP_UPPER_LEFT_CORNER,
                                       PP_BOTTOM_LEFT_CORNER,
                                       PP_UPPER_RIGHT_CORNER,
                                       PP_BOTTOM_RIGHT_CORNER].freeze

        WIDE_ITEM_LOCATIONS = [PP_WIDE_TOP_CORNER,
                               PP_WIDE_BOTTOM_CORNER].freeze

        POINTY_WIDE_ITEM_LOCATIONS = [PP_WIDE_TOP_CORNER,
                                      PP_WIDE_BOTTOM_CORNER,
                                      PP_WIDE_BOTTOM_LEFT_CORNER].freeze

        POINTY_TALL_ITEM_LOCATIONS = [PP_TALL_LEFT_CORNER,
                                      PP_TALL_RIGHT_CORNER].freeze

        POINTY_WIDER_ITEM_LOCATIONS = [PP_WIDER_BOTTOM_CORNER,
                                       PP_WIDER_TOP_CORNER].freeze
      end
    end
  end
end
