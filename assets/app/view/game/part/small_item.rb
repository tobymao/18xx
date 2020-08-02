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

        SMALL_ITEM_LOCATIONS = [P_RIGHT_CORNER,
                                P_LEFT_CORNER,
                                P_BOTTOM_RIGHT_CORNER,
                                P_UPPER_LEFT_CORNER,
                                P_BOTTOM_LEFT_CORNER].freeze
      end
    end
  end
end
