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

            super
          end

          def potential_tiles(entity, hex)
            if @game.port_company?(entity)
              return [] if PORT_TILES.include?(hex.tile.id)

              tile_ability = abilities(entity)
              tile = @game.tiles.find { |t| t.name == tile_ability.tiles[0] }
              return [tile]
            elsif @game.cube_company?(entity)
              return @game.can_hold_builder_cubes?(hex.tile) ? [@game.tile_by_id('BC-0')] : []
            end
            return potential_tiles_portage_company(entity, hex) if @game.portage_company?(entity)

            tiles = super
            if @game.can_hold_builder_cubes?(hex.tile)
              cube_tile = @game.tile_by_id('BC-0')
              tiles << cube_tile
            end
            tiles
          end

          def legal_tile_rotation?(entity, hex, tile)
            return hex.tile.paths.any? { |p| p.exits == tile.exits } if @game.port_company?(entity)
            return true if tile.id == 'BC-0'
            return true if @game.legal_leavenworth_tile(hex, tile)
            return legal_tile_rotation_portage_company?(entity, hex, tile) if @game.portage_company?(entity)

            super
          end

          def available_hex_portage_company(entity, hex)
            abilities(entity).hexes.include?(hex.id) ? hex.all_neighbors.keys : nil
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

          def lay_tile(action, extra_cost: 0, entity: nil, spender: nil)
            raise GameError, 'Cannot upgrade forests' if action.hex.assigned?('forest')

            super
          end

          def process_lay_tile(action)
            if @game.cube_company?(action.entity)
              @log << "#{action.entity.name} places builder cube on #{action.hex.name}"
              action.hex.tile.icons << Part::Icon.new('../icons/1822_mx/red_cube', 'block')
              ability = abilities(action.entity)
              ability.use!
              if ability.count.zero? && ability.closed_when_used_up
                company = ability.owner
                @log << "#{company.name} closes"
                company.close!
              end
            elsif @game.company_ability_extra_track?(action.entity) && action.tile.id == 'BC-0'
              @log << "#{action.entity.name} places builder cube on #{action.hex.name}"
              action.hex.tile.icons << Part::Icon.new('../icons/1822_mx/red_cube', 'block')
              ability = abilities(action.entity)
              ability.use!
              # Minors can only do this once...
              if action.entity.owner.type == :minor
                ability.use!
              else
                @extra_laided_track = true
              end

              if ability.type == :tile_lay && ability.count <= 0 && ability.closed_when_used_up
                @log << "#{ability.owner.name} closes"
                ability.owner.close!
              end
            elsif @game.portage_company?(action.entity)
              process_lay_tile_portage_company(action)
            else
              forest = @game.forest?(action.hex.tile)
              super
              action.hex.tile.icons.reject! { |i| i.name == 'block' }
              action.hex.assign!('forest') if forest
            end
          end

          def process_lay_tile_portage_company(action)
            raise GameError, 'Cannot play portage now' if @round.num_laid_track.positive?

            lay_tile(action)
            abilities(action.entity).use!
            @round.num_laid_portage += 1
            action.entity.revenue = 0
          end
        end
      end
    end
  end
end
