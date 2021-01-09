# frozen_string_literal: true

require_relative '../tracker'
require_relative '../track'
require_relative '../upgrade_track_max_exits'
require_relative 'automatic_loan'

module Engine
  module Step
    module G1867
      class Track < Track
        include AutomaticLoan
        include UpgradeTrackMaxExits
        def setup
          super
          @hex = nil
        end

        def lay_tile(action, extra_cost: 0, entity: nil)
          raise GameError, 'Cannot lay and upgrade the same tile in the same turn' if action.hex == @hex

          super
          @game.place_cn_montreal_token(action.hex.tile) if action.tile.name == '639'
          @hex = action.hex
        end

        def connects_to?(hex, tile, to)
          dir = hex.neighbor_direction(to)
          tile.exits.include?(dir)
        end
      end
    end
  end
end
