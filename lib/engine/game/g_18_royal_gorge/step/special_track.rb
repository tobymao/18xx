# frozen_string_literal: true

require_relative '../../../step/special_track'

module Engine
  module Game
    module G18RoyalGorge
      module Step
        class SpecialTrack < Engine::Step::SpecialTrack
          def actions(entity)
            return [] unless entity.owner == current_entity

            super
          end
        end
      end
    end
  end
end
