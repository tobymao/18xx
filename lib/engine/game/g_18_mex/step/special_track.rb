# frozen_string_literal: true

require_relative '../../../step/special_track'

module Engine
  module Game
    module G18MEX
      module Step
        class SpecialTrack < Engine::Step::SpecialTrack
          COPPER_CANYON = '470'

          def abilities(entity, **_kwargs)
            ability = super

            ability if ability &&
              entity.owner == @game.round.current_entity &&
              @game.round.active_step.respond_to?(:process_lay_tile)
          end

          def process_lay_tile(action)
            super
            return unless action.tile.name == COPPER_CANYON

            action.tile.label = nil
            @game.log << "#{@game.p2_company.name} closes"
            @game.p2_company.close!
          end
        end
      end
    end
  end
end
