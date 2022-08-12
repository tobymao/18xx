# frozen_string_literal: true

require_relative '../../g_1822/step/special_track'

module Engine
  module Game
    module G1822PNW
      module Step
        class SpecialTrack < Engine::Game::G1822::Step::SpecialTrack
          def potential_tiles(entity, hex)
            tiles = super
            if @game.can_hold_builder_cubes?(hex.tile)
              cube_tile = @game.tile_by_id('BC-0')
              tiles << cube_tile
            end
            tiles
          end

          def legal_tile_rotation?(_entity, _hex, tile)
            return true if tile.id == 'BC-0'
            return true if @game.legal_leavenworth_tile(hex, tile)

            super
          end

          def lay_tile(action, extra_cost: 0, entity: nil, spender: nil)
            raise GameError, 'Cannot upgrade forests' if action.hex.assigned?('forest')

            super
          end

          def process_lay_tile(action)
            if @game.company_ability_extra_track?(action.entity) && action.tile.id == 'BC-0'
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
