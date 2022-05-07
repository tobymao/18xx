# frozen_string_literal: true

require 'view/game/part/base'

module View
  module Game
    module Part
      module LargeItem
        P_WIDE_LEFT_CORNER = {
          region_weights: [5, 6, 7, 12, 13, 14],
          x: -60,
          y: 0,
        }.freeze

        P_WIDE_UPPER_LEFT_CORNER = {
          region_weights: [0, 1, 2, 6, 7, 8],
          x: -30,
          y: -52,
        }.freeze

        P_WIDE_BOTTOM_LEFT_CORNER = {
          region_weights: [13, 14, 15, 19, 20, 21],
          x: -30,
          y: 52,
        }.freeze

        P_WIDE_RIGHT_CORNER = {
          region_weights: [9, 10, 11, 16, 17, 18],
          x: 60,
          y: 0,
        }.freeze

        P_WIDE_UPPER_RIGHT_CORNER = {
          region_weights: [2, 3, 4, 8, 9, 10],
          x: 30,
          y: -52,
        }.freeze

        P_WIDE_BOTTOM_RIGHT_CORNER = {
          region_weights: [15, 16, 17, 21, 22, 23],
          x: 30,
          y: 52,
        }.freeze

        PP_WIDE_LEFT_CORNER = {
          region_weights: [5, 6, 7, 12, 13, 14],
          x: -52,
          y: -30,
        }.freeze

        PP_WIDE_UPPER_LEFT_CORNER = {
          region_weights: [0, 1, 2, 6, 7, 8],
          x: 0,
          y: -60,
        }.freeze

        PP_WIDE_BOTTOM_LEFT_CORNER = {
          region_weights: [13, 14, 15, 19, 20, 21],
          x: -52,
          y: 30,
        }.freeze

        PP_WIDE_RIGHT_CORNER = {
          region_weights: [9, 10, 11, 16, 17, 18],
          x: 52,
          y: 30,
        }.freeze

        PP_WIDE_UPPER_RIGHT_CORNER = {
          region_weights: [2, 3, 4, 8, 9, 10],
          x: 52,
          y: -30,
        }.freeze

        PP_WIDE_BOTTOM_RIGHT_CORNER = {
          region_weights: [15, 16, 17, 21, 22, 23],
          x: 0,
          y: 60,
        }.freeze

        LARGE_ITEM_LOCATIONS = [P_WIDE_LEFT_CORNER,
                                P_WIDE_UPPER_LEFT_CORNER,
                                P_WIDE_BOTTOM_LEFT_CORNER,
                                P_WIDE_RIGHT_CORNER,
                                P_WIDE_UPPER_RIGHT_CORNER,
                                P_WIDE_BOTTOM_RIGHT_CORNER].freeze

        POINTY_LARGE_ITEM_LOCATIONS = [PP_WIDE_LEFT_CORNER,
                                       PP_WIDE_UPPER_LEFT_CORNER,
                                       PP_WIDE_BOTTOM_LEFT_CORNER,
                                       PP_WIDE_RIGHT_CORNER,
                                       PP_WIDE_UPPER_RIGHT_CORNER,
                                       PP_WIDE_BOTTOM_RIGHT_CORNER].freeze

        def preferred_render_locations
          if layout == :flat
            LARGE_ITEM_LOCATIONS
          else
            POINTY_LARGE_ITEM_LOCATIONS
          end
        end

        def diamond_points(r, cx, cy)
          s = r * Math.sqrt(2.0)
          "#{(cx - s).round(2)},#{cy.round(2)} "\
            "#{cx.round(2)},#{(cy - s).round(2)} "\
            "#{(cx + s).round(2)},#{cy.round(2)} "\
            "#{cx.round(2)},#{(cy + s).round(2)}"
        end

        def hex_points(r, cx, cy)
          s = r * 2 / Math.sqrt(3.0)
          f60 = Math.sin(60 / 180 * Math::PI)
          f30 = Math.sin(30 / 180 * Math::PI)
          "#{(cx - s).round(2)},#{cy.round(2)} "\
            "#{(cx - (s * f30)).round(2)},#{(cy - (s * f60)).round(2)} "\
            "#{(cx + (s * f30)).round(2)},#{(cy - (s * f60)).round(2)} "\
            "#{(cx + s).round(2)},#{cy.round(2)} "\
            "#{(cx + (s * f30)).round(2)},#{(cy + (s * f60)).round(2)} "\
            "#{(cx - (s * f30)).round(2)},#{(cy + (s * f60)).round(2)}"
        end
      end
    end
  end
end
