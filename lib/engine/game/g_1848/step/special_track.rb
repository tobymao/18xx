# frozen_string_literal: true

require_relative '../../../step/special_track'

module Engine
  module Game
    module G1848
      module Step
        class SpecialTrack < Engine::Step::SpecialTrack
          def process_lay_tile(action)
            super
            company = action.entity
            # track lay ability is both on player and corporate, remove all left over abilities
            @game.ability_used!(company)
            return unless @game.private_closed_triggered

            # close company if company closes and the ability has been used
            @log << "#{company.name} closes"
            company.close!
          end
        end
      end
    end
  end
end
