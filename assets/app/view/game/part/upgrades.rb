# frozen_string_literal: true

require 'view/game/part/base'
require 'view/game/part/upgrade'

module View
  module Game
    module Part
      class Upgrades < Snabberb::Component
        needs :tile
        needs :region_use
        needs :loc, default: nil

        def render
          @tile.upgrades.map do |upgrade|
            h(
              Part::Upgrade,
              region_use: @region_use,
              cost: upgrade.cost,
              terrains: upgrade.terrains,
              tile: @tile,
              size: upgrade.size,
              loc: @loc,
            )
          end
        end
      end
    end
  end
end
