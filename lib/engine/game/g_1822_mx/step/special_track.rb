# frozen_string_literal: true

require_relative '../../g_1822/step/special_track'

module Engine
  module Game
    module G1822MX
      module Step
        class SpecialTrack < Engine::Game::G1822::Step::SpecialTrack
          PORT_TILES = %w[P1-0 P2-0].freeze

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
            return hex.tile.paths[0].exits == tile.exits if @game.port_company?(entity)
            return true if @game.cube_company?(entity)
            return true if tile.id == 'BC-0'

            # Per rule, a tile specifically placed in M22 must connect Mexico City to existing track, unless
            # it is the MC that is placing it.
            if hex.id == 'M22' && entity.id != 'MC'
              path_to_mc = tile.paths.find { |p| p.edges[0].num == 5 }
              return false unless path_to_mc

              exit_out = tile.paths.find { |p| p.town == path_to_mc.town && p != path_to_mc }.edges[0].num
              @m22_adjacent_hexes ||= { 0 => 'N21', 1 => 'M20', 2 => 'L21', 3 => 'L23', 4 => 'M24' }
              return @game.hex_by_id(@m22_adjacent_hexes[exit_out]).tile.exits.include?((exit_out + 3) % 6)
            end

            super
          end

          def abilities(entity, **kwargs, &block)
            return unless entity&.company?

            %i[tile_lay teleport].each do |type|
              ability = @game.abilities(
                entity,
                type,
                time: %w[special_track %current_step% owning_corp_or_turn],
                **kwargs,
                &block
              )
              return ability if ability && (ability.type != :teleport || !ability.used?)
            end

            nil
          end

          def available_hex(entity, hex)
            if @game.port_company?(entity)
              return [hex.tile.exits] if hex.tile.color == :blue && !PORT_TILES.include?(hex.tile.id)

              return nil
            end
            if @game.cube_company?(entity)
              return @game.can_hold_builder_cubes?(hex.tile) && @game.graph.connected_hexes(entity.owner)[hex]
            end

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
              super
              action.hex.tile.icons.reject! { |i| i.name == 'block' }
            end
          end
        end
      end
    end
  end
end
