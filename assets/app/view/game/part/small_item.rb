# frozen_string_literal: true

require 'view/game/part/base'

module View
  module Game
    module Part
      module SmallItem
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
          y: 65,
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
                                      PP_WIDE_BOTTOM_CORNER].freeze
      end
    end
  end
end
