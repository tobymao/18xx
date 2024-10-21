# frozen_string_literal: true

require_relative '../../../step/special_track'

module Engine
  module Game
    module G1837
      module Step
        class SpecialTrack < Engine::Step::SpecialTrack
          def abilities(entity, **kwargs, &block)
            return nil unless (ability = super)
            return ability if @game.loading

            hex = @game.hex_by_id(ability.hexes.first)
            @game.graph.connected_hexes(@round.current_operator).include?(hex) ? ability : nil
          end
        end
      end
    end
  end
end
