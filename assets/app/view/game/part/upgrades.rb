# frozen_string_literal: true

require 'view/game/part/base'
require 'view/game/part/upgrade'

module View
  module Game
    module Part
      class Upgrades < Snabberb::Component
        needs :tile
        needs :upgrades, default: nil
        needs :region_use
        needs :loc, default: nil
        needs :formatter, default: nil

        def render
          (@upgrades || @tile.upgrades).map do |upgrade|
            h(
              Part::Upgrade,
              region_use: @region_use,
              cost: upgrade.cost,
              terrains: upgrade.terrains,
              tile: @tile,
              size: upgrade.size,
              loc: @loc,
              formatter: @formatter,
            )
          end
        end
      end
    end
  end
end
