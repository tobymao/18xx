# frozen_string_literal: true

require_relative '../../../step/special_track'
require_relative 'tile_point_tracker'

module Engine
  module Game
    module G18OE
      module Step
        class SpecialTrack < Engine::Step::SpecialTrack
          include TilePointTracker

          def actions(entity)
            return [] unless entity == @game.brandt_private
            return [] unless @game.brandt_token_placeable?(@round.current_operator)

            %w[lay_tile]
          end

          def description
            'Lay Track (Brandt & Brandau)'
          end

          def available_hex(entity, hex)
            return unless entity.company?
            return unless @game.brandt_hex?(hex)

            tracker_available_hex(@round.current_operator, hex)
          end

          def hex_neighbors(entity, hex)
            @game.graph_for_entity(entity).connected_hexes(entity)[hex]
          end

          def potential_tile_colors(_entity, hex)
            super(@round.current_operator, hex)
          end

          def potential_tiles(entity_or_entities, hex)
            super.reject(&:blocks_lay)
          end

          def upgradeable_tiles(entity_or_entities, ui_hex)
            super.select { |tile| tile.color == :yellow }
          end

          def legal_tile_rotation?(entity_or_entities, hex, tile)
            entity = Array(entity_or_entities).first
            super(entity.company? ? @round.current_operator : entity_or_entities, hex, tile)
          end

          def process_lay_tile(action)
            operator = @round.current_operator
            hex = action.hex
            tile = action.tile
            old_tile = hex.tile

            raise GameError, "#{action.entity.name} cannot be used by #{operator.name} now" unless
              @game.brandt_token_placeable?(operator)
            raise GameError, "#{hex.name} cannot hold a Brandt & Brandau token" unless @game.brandt_hex?(hex)
            raise GameError, 'Brandt & Brandau lays a yellow tile' unless tile.color == :yellow
            raise GameError, "#{old_tile.name} is not upgradeable to #{tile.name}" unless @game.upgrades_to?(old_tile, tile)
            if !@game.loading && !tracker_available_hex(operator, hex)
              raise GameError, "#{hex.name} is not connected to #{operator.name}"
            end

            points_cost = @game.tile_point_cost(operator, old_tile: old_tile)
            raise GameError, 'Cannot lay a yellow now' if points_cost > remaining_tile_points(operator)

            super
            @game.after_lay_tile(operator, old_tile, tile)
            @game.fulfill_patronage!(operator, hex)
            @round.num_laid_track += 1
            @round.tile_points_used += points_cost
            @game.place_brandt_token!(hex)
          end

          def lay_tile(action, extra_cost: 0, entity: nil, spender: nil)
            operator = @round.current_operator
            action.tile.rotate!(action.rotation)
            action.extra_cost = cross_water_fee(action, operator) unless @game.loading
            super(action, extra_cost: action.extra_cost || 0, entity: entity, spender: spender)
          end
        end
      end
    end
  end
end
