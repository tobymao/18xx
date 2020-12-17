# frozen_string_literal: true

require_relative '../tracker'
require_relative '../track'
require_relative 'automatic_loan'

module Engine
  module Step
    module G1867
      class Track < Track
        include AutomaticLoan
        def setup
          super
          @hex = nil
        end

        def lay_tile(action, extra_cost: 0, entity: nil)
          @game.game_error('Cannot lay and upgrade the same tile in the same turn') if action.hex == @hex
          super
          @hex = action.hex
        end

        def connects_to?(hex, tile, to)
          dir = hex.neighbor_direction(to)
          tile.exits.include?(dir)
        end

        def legal_tile_rotation?(entity, hex, tile)
          legal = super
          return legal unless legal
          return legal if tile.color != :yellow

          # G15, K13, M11 have to be connected to specific neighbors

          case hex.id
          when 'G15'
            connects_to?(hex, tile, @game.hex_by_id('F16'))
          when 'K13', 'M11'
            connects_to?(hex, tile, @game.hex_by_id('L12'))
          else
            legal
          end
        end
      end
    end
  end
end
