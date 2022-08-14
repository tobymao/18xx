# frozen_string_literal: true

require_relative '../../g_1822/step/special_track'

module Engine
  module Game
    module G1822PNW
      module Step
        class SpecialTrack < Engine::Game::G1822::Step::SpecialTrack
          PORT_TILES = %w[P1-0 P2-0].freeze

          def available_hex(entity, hex)
            if @game.port_company?(entity)
              return nil unless abilities(entity).hexes.include?(hex.id)
              return [hex.tile.exits] if hex.tile.color == :blue && !PORT_TILES.include?(hex.tile.id)

              return nil
            end
            if @game.cube_company?(entity)
              return @game.can_hold_builder_cubes?(hex.tile) && @game.graph.connected_hexes(entity.owner)[hex]
            end

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

            super
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
            else
              forest = @game.forest?(action.hex.tile)
              super
              action.hex.tile.icons.reject! { |i| i.name == 'block' }
              action.hex.assign!('forest') if forest
            end
          end
        end
      end
    end
  end
end
