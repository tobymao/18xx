# frozen_string_literal: true

require 'view/part/base'
require 'view/part/upgrade'

module View
  module Part
    class Upgrades < Snabberb::Component
      needs :tile
      needs :region_use

      def render
        @tile.upgrades.map do |upgrade|
          h(
            Part::Upgrade,
            region_use: @region_use,
            cost: upgrade.cost,
            terrains: upgrade.terrains,
            tile: @tile,
          )
        end
      end
    end
  end
end
