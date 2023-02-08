# frozen_string_literal: true

require_relative '../../g_1822/step/special_track'

module Engine
  module Game
    module G1822PNW
      module Step
        class SpecialTrack < Engine::Game::G1822::Step::SpecialTrack
          PORT_TILES = %w[P1-0 P2-0].freeze
          def round_state
            super.merge(
              {
                num_laid_portage: 0,
              }
            )
          end

          def setup
            @round.num_laid_portage = 0
          end

          def available_hex(entity, hex)
            if @game.port_company?(entity)
              return nil unless abilities(entity).hexes.include?(hex.id)
              return [hex.tile.exits] if hex.tile.color == :blue && !PORT_TILES.include?(hex.tile.id)

              return nil
            end
            if @game.cube_company?(entity)
              return @game.can_hold_builder_cubes?(hex.tile) && @game.graph.connected_hexes(entity.owner)[hex]
            end
            return available_hex_portage_company(entity, hex) if @game.portage_company?(entity)
            return available_hex_boomtown_company(entity, hex) if @game.boomtown_company?(entity)
            return available_hex_coal_company(entity, hex) if @game.coal_company?(entity)
            return nil if hex.tile.icons.any? { |i| i.name.start_with?('mountain') }

            super
          end

          def potential_tiles(entity, hex)
            if @game.port_company?(entity)
              return [] if PORT_TILES.include?(hex.tile.id)

              tile_ability = abilities(entity)
              tile = @game.tiles.find { |t| t.name == tile_ability.tiles[0] }
              return [tile]
            elsif @game.cube_company?(entity)
              return @game.can_hold_builder_cubes?(hex.tile) ? [@game.cube_tile] : []
            end
            return potential_tiles_portage_company(entity, hex) if @game.portage_company?(entity)
            return potential_tiles_boomtown_company(entity, hex) if @game.boomtown_company?(entity)
            return potential_tiles_coal_company(entity, hex) if @game.coal_company?(entity)

            tiles = super
            tiles << @game.cube_tile if @game.can_hold_builder_cubes?(hex.tile)
            tiles = @game.tokencity_potential_tiles(hex, tiles) if @game.tokencity?(hex)
            tiles
          end

          def legal_tile_rotation?(entity, hex, tile)
            return hex.tile.paths.any? { |p| p.exits == tile.exits } if @game.port_company?(entity)
            return true if tile == @game.cube_tile
            return true if @game.legal_city_and_town_tile(hex, tile)
            return legal_tile_rotation_portage_company?(entity, hex, tile) if @game.portage_company?(entity)
            return legal_tile_rotation_boomtown_company?(entity, hex, tile) if @game.boomtown_company?(entity)
            return legal_tile_rotation_coal_company?(entity, hex, tile) if @game.coal_company?(entity)

            super
          end

          def available_hex_portage_company(entity, hex)
            abilities(entity).hexes.include?(hex.id) && !@game.port_tile?(hex) ? hex.all_neighbors.keys : nil
          end

          def potential_tiles_portage_company(entity, _hex)
            @game.tiles.select { |tile| abilities(entity).tiles.include?(tile.name) }.uniq
          end

          def legal_tile_rotation_portage_company?(_entity, hex, tile)
            # Make sure the tile exits point to actually hexes - use this instead of base checking
            # because we need to be able to place torwards blue hexes that don't have a spike.
            # Also, not allowed to play into Seattle
            tile.exits.all? { |exit| hex.all_neighbors.key?(exit) } &&
            tile.exits.none? { |exit| hex.all_neighbors[exit].id == 'H11' }
          end

          def available_hex_boomtown_company(_entity, hex)
            %w[7 8 9].include?(hex.tile.name)
          end

          def potential_tiles_boomtown_company(entity, _hex)
            @game.tiles.select { |tile| abilities(entity).tiles.include?(tile.name) }.uniq
          end

          def legal_tile_rotation_boomtown_company?(_entity, _hex, _tile)
            true
          end

          def available_hex_coal_company(entity, hex)
            hex.all_neighbors.keys if abilities(entity).hexes.include?(hex.id) && @game.graph.connected_hexes(entity.owner)[hex]
          end

          def potential_tiles_coal_company(entity, _hex)
            @game.tiles.select { |tile| abilities(entity).tiles.include?(tile.name) }.uniq
          end

          def legal_tile_rotation_coal_company?(entity, hex, tile)
            neighbors = tile.exits.map { |exit| hex.neighbors[exit] }
            neighbors.any? { |h| @game.graph.connected_hexes(entity.owner)[h] }
          end

          def lay_tile(action, extra_cost: 0, entity: nil, spender: nil)
            raise GameError, 'Cannot upgrade forests' if action.hex.assigned?('forest')

            super
          end

          def process_lay_tile(action)
            return process_lay_tile_cube_company(action) if @game.cube_company?(action.entity)
            if @game.company_ability_extra_track?(action.entity) && action.tile == @game.cube_tile
              return process_lay_tile_extra_track_cube(action)
            end
            return process_lay_tile_portage_company(action) if @game.portage_company?(action.entity)
            return process_lay_tile_boomtown_company(action) if @game.boomtown_company?(action.entity)
            return process_lay_tile_coal_company(action) if @game.coal_company?(action.entity)

            forest = @game.forest?(action.hex.tile)
            super
            action.hex.tile.icons.reject! { |i| i.name == 'block' }
            action.hex.assign!('forest') if forest
          end

          def process_lay_tile_cube_company(action)
            place_builder_cube(action)
            ability = abilities(action.entity)
            ability.use!
            check_company_closing(ability)
          end

          def process_lay_tile_extra_track_cube(action)
            place_builder_cube(action)
            ability = abilities(action.entity)
            ability.use!
            # Minors can only do this once...
            if action.entity.owner.type == :minor
              ability.use!
            else
              @extra_laided_track = true
            end
            check_company_closing(ability)
          end

          def process_lay_tile_portage_company(action)
            raise GameError, 'Cannot play portage now' if @round.num_laid_track.positive?

            lay_tile(action)
            abilities(action.entity).use!
            @round.num_laid_portage += 1
            action.entity.revenue = 0
          end

          def process_lay_tile_boomtown_company(action)
            lay_tile(action)
            ability = abilities(action.entity)
            ability.use!
            check_company_closing(ability)
          end

          def process_lay_tile_coal_company(action)
            tile_lay = get_tile_lay(action.entity)
            raise GameError, 'Cannot lay coal company now' if !tile_lay || !tile_lay[:lay]

            lay_tile(action)
            @round.num_laid_track += 1
            ability = abilities(action.entity)
            @game.coal_token.corporation = action.entity.owner
            action.tile.cities[0].place_token(action.entity.owner, @game.coal_token, check_tokenable: false)
            action.entity.owner.tokens << @game.coal_token
            @game.coal_company_used
            ability.use!
          end

          def place_builder_cube(action)
            @log << "#{action.entity.name} places builder cube on #{action.hex.name}"
            action.hex.tile.icons << Part::Icon.new('../icons/1822_mx/red_cube', 'block')
          end

          def check_company_closing(ability)
            return if !ability.count.zero? || !ability.closed_when_used_up

            @log << "#{ability.owner.name} closes"
            ability.owner.close!
          end

          def track_upgrade?(_from, _to, hex)
            @game.tokencity?(hex) || super
          end

          def border_cost_discount(entity, spender, border, cost, hex)
            hex == @game.seattle_hex ? 75 : super
          end
        end
      end
    end
  end
end
