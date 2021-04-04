# frozen_string_literal: true

require_relative '../../../step/special_track'

module Engine
  module Game
    module G18Ireland
      module Step
        class SpecialTrack < Engine::Step::SpecialTrack
          def potential_tiles(entity, _hex)
            return super unless entity.id == 'TIM'
            return [] unless (tile_ability = abilities(entity))

            tile_ability.tiles.map { |name| @game.tiles.find { |t| t.name == name } }
          end

          def hex_neighbors(entity, hex)
            if entity.id == 'DR'
              return unless (ability = abilities(entity))
              return if ability.count == 2 && hex.id != 'F4'
            end
            super
          end

          def process_lay_tile(action)
            super
            @game.clear_narrow_graph
          end
        end
      end
    end
  end
end
