# frozen_string_literal: true

require_relative '../track'

module Engine
  module Step
    module G18Mex
      class Track < Track
        ACTIONS = %w[lay_tile pass].freeze
        MEXICO_CITY_MAIN_HEX = 'O10'
        PUEBLA_HEX = 'P11'
        MEXICO_CITY_DOUBLE_HEX = [MEXICO_CITY_MAIN_HEX, PUEBLA_HEX].freeze

        def actions(entity)
          return [] if entity.company? || !remaining_tile_lay?(entity)

          entity == current_entity ? ACTIONS : []
        end

        def process_lay_tile(action)
          @mexico_city_double_hex_lay = false
          @game.game_error('Cannot do normal tile lay') unless can_lay_tile?(action.entity)
          lay_tile_action(action)
          lay_in_other_hex_of_double_hex(action) if MEXICO_CITY_DOUBLE_HEX.include?(action.hex.id)
          pass! unless remaining_tile_lay?(action.entity)
        end

        def check_track_restrictions!(entity, old_tile, new_tile)
          return if @mexico_city_double_hex_lay

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

        def lay_in_other_hex_of_double_hex(action)
          @mexico_city_double_hex_lay = true
          other_hex_name = action.tile.hex.name == PUEBLA_HEX ? MEXICO_CITY_MAIN_HEX : PUEBLA_HEX
          hex = @game.hexes.find { |h| h.name == other_hex_name }
          laid_name = action.tile.name
          tile_name = laid_name.end_with?('P') ? laid_name.sub('P', 'MC') : laid_name.sub('MC', 'P')
          tile = @game.tiles.find { |t| t.name == tile_name }

          lay_tile(Engine::Action::LayTile.new(action.entity, hex: hex, tile: tile, rotation: 0))
        end
      end
    end
  end
end
