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
              ability.use!(upgrade: %i[green brown gray].include?(action.tile.color))
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

              handle_extra_tile_lay_company(ability, action.entity)
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
