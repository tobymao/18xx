# frozen_string_literal: true

require_relative '../track'

module Engine
  module Step
    module G18Mex
      class Track < Track
        ACTIONS = %w[lay_tile pass].freeze
        MEXICO_CITY_MAIN_HEX = 'O10'
        PUEBLA_HEX = 'P11'

        def actions(entity)
          return [] if entity.company? || !remaining_tile_lay?(entity)

          entity == current_entity ? ACTIONS : []
        end

        def process_lay_tile(action)
          @puebla_lay = false
          @game.game_error('Cannot do normal tile lay') unless can_lay_tile?(action.entity)
          if action.hex.name == PUEBLA_HEX
            @game.game_error("Can only be upgraded via Mexico City (#{MEXICO_CITY_MAIN_HEX})")
          end
          lay_tile_action(action)
          lay_in_pueble(action) if action.hex.id == MEXICO_CITY_MAIN_HEX
          pass! unless remaining_tile_lay?(action.entity)
        end

        def check_track_restrictions!(entity, old_tile, new_tile)
          return if @puebla_lay

          super
        end

        def can_lay_tile?(entity)
          return super unless entity.minor?

          home_hex = @game.hex_by_id(entity.coordinates)
          return @game.tile_cost(home_hex.tile, entity) <= entity.cash if home_hex.tile.color == :white

          super
        end

        private

        def remaining_tile_lay?(entity)
          can_lay_tile?(entity) ||
          (@game.p2_company.owner == entity && @game.p2_company.abilities(:tile_lay)&.count&.positive?)
        end

        def lay_in_pueble(action)
          @puebla_lay = true
          hex = @game.hexes.find { |h| h.name == PUEBLA_HEX }
          puebla_tile_name = action.tile.name.sub('MC', 'P')
          tile = @game.tiles.find { |t| t.name == puebla_tile_name }

          puebla_action = Engine::Action::LayTile.new(action.entity, hex: hex, tile: tile, rotation: 0)
          lay_tile(puebla_action)
        end
      end
    end
  end
end
