# frozen_string_literal: true

module Engine
  module Game
    module G18USA
      module Step
        module ResourceTrack
          def potential_future_tiles(_entity, hex)
            @game.tiles
              .uniq(&:name)
              .select { |t| @game.upgrades_to?(hex.tile, t) }
          end

          # The oil/coal/ore tiles falsely pass as offboards, so we need to be more careful
          def real_offboard?(tile)
            !tile.offboards&.empty? && !@game.resource_tile?(tile)
          end

          def legal_tile_rotation?(entity, hex, tile)
            return super unless @game.resource_tile?(tile)

            super &&
            tile.exits.any? do |exit|
              neighbor = hex.neighbors[exit]
              ntile = neighbor&.tile
              next false unless ntile

              # The neighbouring tile must have a city or offboard or town
              # That neighbouring tile must either connect to an edge on the tile or
              # potentially be updated in future.
              # 1817 doesn't have any coal next to towns but 1817NA does and
              #  Marc Voyer confirmed that coal should be able to connect to the gray pre-printed town
              (ntile.cities&.any? || real_offboard?(ntile) || ntile.towns&.any?) &&
              (ntile.exits.any? { |e| e == Hex.invert(exit) } || potential_future_tiles(entity, neighbor).any?)
            end
          end

          def lay_tile_action(action, entity: nil, spender: nil)
            if @game.resource_tile?(action.tile)
              entity ||= action.entity
              corporation = entity.corporation? ? entity : entity.owner
              abilities = @game.abilities_to_lay_resource_tile(action.hex, action.tile, corporation.companies).values
              return lay_tile(action, entity: entity, spender: spender) if abilities.none?(&:consume_tile_lay)
            end

            super
          end

          def lay_tile(action, extra_cost: 0, entity: nil, spender: nil)
            tile = action.tile
            hex = action.hex
            entity ||= action.entity
            corporation = entity.corporation? ? entity : entity.owner

            super
            @game.consume_abilities_to_lay_resource_tile(hex, tile, corporation.companies) if @game.resource_tile?(tile)
          end
        end
      end
    end
  end
end
