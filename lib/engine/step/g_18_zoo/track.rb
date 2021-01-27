# frozen_string_literal: true

require_relative '../track'

module Engine
  module Step
    module G18ZOO
      class Track < Track
        def lay_tile(action, _extra_cost: 0, _entity: nil, _spender: nil)
          hex = action.hex
          tile = action.tile

          if %w[O M MM].include?(hex.location_name) &&
            tile.color == :yellow &&
            !tile.name.end_with?('(water)') && !tile.name.end_with?('(mountain)')
            tile = case tile.name + '_' + hex.location_name
                   when '7_O'
                     Engine::Game::G18ZOO::TILE_W7.dup
                   when '7_M'
                     Engine::Game::G18ZOO::TILE_M7.dup
                   when '7_MM'
                     Engine::Game::G18ZOO::TILE_MM7.dup
                   when '8_O'
                     Engine::Game::G18ZOO::TILE_W8.dup
                   when '8_M'
                     Engine::Game::G18ZOO::TILE_M8.dup
                   when '8_MM'
                     Engine::Game::G18ZOO::TILE_MM8.dup
                   when '9_O'
                     Engine::Game::G18ZOO::TILE_W9.dup
                   when '9_M'
                     Engine::Game::G18ZOO::TILE_M9.dup
                   when '9_MM'
                     Engine::Game::G18ZOO::TILE_MM9.dup
                   end
            @game.tiles << tile
            @game.tiles.delete(tile)
            lay_tile(Engine::Action::LayTile.new(action.entity, hex: hex, tile: tile, rotation: action.rotation))
          else
            super
          end
        end
      end
    end
  end
end
