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

          def resource_ability_used?(tile)
            @game.resource_tile?(tile) && tile.color == :yellow && !@game.class::ORE20_TILES.include?(tile.name)
          end

          def legal_tile_rotation?(entity, hex, tile)
            return super unless resource_ability_used?(tile)

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

          def track_upgrade?(_from, to, _hex)
            super || @game.class::ORE20_TILES.include?(to.name)
          end

          def lay_tile_action(action, entity: nil, spender: nil)
            if resource_ability_used?(action.tile)
              entity ||= action.entity
              corporation = entity.corporation? ? entity : entity.owner
              abilities = @game.abilities_to_lay_resource_tile(action.hex, action.tile, corporation.companies).values
              return lay_tile(action, entity: entity, spender: spender) if abilities.any? { |a| !a.consume_tile_lay }
            end

            super
          end

          def lay_tile(action, extra_cost: 0, entity: nil, spender: nil)
            tile = action.tile
            hex = action.hex
            entity ||= action.entity
            corporation = entity.corporation? ? entity : entity.owner

            super
            return unless resource_ability_used?(tile)

            @game.consume_abilities_to_lay_resource_tile(hex, tile, corporation.companies)
          end
        end
      end
    end
  end
end
