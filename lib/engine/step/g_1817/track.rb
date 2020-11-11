# frozen_string_literal: true

require_relative '../tracker'
require_relative '../track'

module Engine
  module Step
    module G1817
      class Track < Track
        # Special track lays act as normal lays for 1817
        attr_accessor :laid_track

        def setup
          super
          @hex = nil
        end

        def lay_tile(action, extra_cost: 0, entity: nil)
          @game.game_error('Cannot lay and upgrade the same tile in the same turn') if action.hex == @hex
          @game.game_error('Cannot upgrade mines') if action.hex.assigned?('mine')
          super
          @hex = action.hex

          return unless action.hex.name == 'F13'

          # PSM loses it's special if something else goes on F13
          psm = @game.company_by_id('PSM')
          return unless (ability = psm.abilities(:tile_lay))

          psm.remove_ability(ability)
        end

        def potential_tiles(_entity, hex)
          return super if hex.tile.color != :green || hex.tile.cities.none?

          tiles = super

          # When upgrading normal cities to brown, players must use tiles with as many exits as will fit.
          # Find maximum number of exits
          max_edges = tiles.map { |t| t.edges.length }.max
          tiles.select { |t| t.edges.length == max_edges }
        end
      end
    end
  end
end
