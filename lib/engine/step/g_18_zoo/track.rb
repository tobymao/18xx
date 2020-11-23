# frozen_string_literal: true

require_relative '../track'
require_relative '../../tile'

module Engine
  module Step
    module G18ZOO
      TILE_W7 = Tile::from_code('7 (water)', 'yellow', 'town=revenue:10;path=a:0,b:_0;path=a:_0,b:1;upgrade=cost:0,terrain:water' )
      TILE_W8 = Tile::from_code('8 (water)', 'yellow', 'town=revenue:10;path=a:0,b:_0;path=a:_0,b:2;upgrade=cost:0,terrain:water' )
      TILE_W9 = Tile::from_code('9 (water)', 'yellow', 'town=revenue:10;path=a:0,b:_0;path=a:_0,b:3;upgrade=cost:0,terrain:water' )

      class Track < Track
        def lay_tile(action, _extra_cost: 0, _entity: nil, _spender: nil)
          if action.hex.location_name == 'O' && action.tile.color == :yellow && !action.tile.name.end_with?('(water)')
            # @log << "and now do other thing" #TODO: Debug log, will be removed later
            tile = case action.tile.name
                   when '7'
                     TILE_W7.dup
                   when '8'
                     TILE_W8.dup
                   when '9'
                     TILE_W9.dup
                   end
            @game.tiles << tile
            @game.tiles.delete(action.tile)
            lay_tile(Engine::Action::LayTile.new(action.entity, hex: action.hex, tile: tile, rotation: action.rotation))
          else
            super
          end
        end
      end
    end
  end
end
