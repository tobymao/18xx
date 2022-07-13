# frozen_string_literal: true

require_relative '../../../step/special_track'

module Engine
  module Game
    module G1848
      module Step
        class SpecialTrack < Engine::Step::SpecialTrack
          def process_lay_tile(action)
            ability = abilities(action.entity)
            super
            return unless @game.private_closed_triggered @game.private_closed_triggered

            # close company if company closes and the ability has been used
            company = ability.owner
            @log << "#{company.name} closes"
            company.close!
          end
        end
      end
    end
  end
end
