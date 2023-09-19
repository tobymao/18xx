# frozen_string_literal: true

require_relative '../../../step/track'

module Engine
  module Game
    module G1844
      module Step
        class Track < Engine::Step::Track
          def tile_lay_abilities_should_block?(entity)
            abilities = [type, 'owning_player_track'].flat_map do |time|
              Array(abilities(entity, time: time, passive_ok: false))
            end
            abilities.any? { |a| !a.consume_tile_lay }
          end
        end
      end
    end
  end
end
