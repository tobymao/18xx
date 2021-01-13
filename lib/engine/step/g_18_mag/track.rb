# frozen_string_literal: true

require_relative '../track'

module Engine
  module Step
    module G18Mag
      class Track < Track
        K_HEXES = %w[I1 H23 H27].freeze

        def actions(entity)
          return [] unless entity == current_entity
          return [] if entity.corporation?

          super
        end

        def log_skip(entity)
          super unless entity.corporation?
        end

        def process_lay_tile(action)
          old_tile = action.hex.tile
          super
          return unless K_HEXES.include?(action.hex.coordinates)

          # Handle special upgrade rules from K hexes
          action.tile.label = 'K' if action.tile.color == 'yellow'
          old_tile.label = nil if old_tile.color == 'yellow'
        end

        def update_tile_lists(tile, old_tile)
          @game.add_extra_tile(tile) if tile.unlimited # probably not compatible with double-sided tiles

          @game.tiles.delete(tile)
          if tile.opposite
            @game.tiles.delete(tile.opposite)
            @game.unused_tiles << tile.opposite
          end

          return if old_tile.preprinted

          @game.tiles << old_tile
          return unless old_tile.opposite

          @game.unused_tiles.delete(old_tile.opposite)
          @game.tiles << old_tile.opposite
        end

        def pay_tile_cost(spender, cost, extra_cost)
          # FIXME: deal with terrain tokens
          if extra_cost.positive?
            spender.spend(extra_cost, @game.skev)
            @log << "#{@game.skev.name} earns #{@game.format_currency(extra_cost)}"
          end
          return unless (cost - extra_cost).positive?

          spender.spend(cost - extra_cost, @game.sik)
          @log << "#{@game.sik.name} earns #{@game.format_currency(cost - extra_cost)}"
        end
      end
    end
  end
end
