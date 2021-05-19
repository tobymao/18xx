# frozen_string_literal: true

require_relative '../../../step/special_track'
require_relative 'narrow_track'

module Engine
  module Game
    module G18Ireland
      module Step
        class SpecialTrack < Engine::Step::SpecialTrack
          include NarrowTrack
          def potential_tiles(entity, _hex)
            return super unless entity.id == 'TIM'
            return [] unless (tile_ability = abilities(entity))

            tile_ability.tiles.map { |name| @game.tiles.find { |t| t.name == name } }
          end

          def hex_neighbors(entity, hex)
            operator = entity.corporation
            case entity.id
            when 'DR'
              return unless (ability = abilities(entity))
              return if ability.count == 2 && hex.id != 'F4'
            when 'BoW'
              return all_hex_neighbors(operator, hex)
            end

            return unless (ability = abilities(entity))
            return if !ability.hexes&.empty? && !ability.hexes&.include?(hex.id)

            return if ability.type == :tile_lay && ability.reachable && !all_hex_neighbors(operator, hex)

            @game.hex_by_id(hex.id).neighbors.keys
          end
        end
      end
    end
  end
end
