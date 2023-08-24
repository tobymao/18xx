# frozen_string_literal: true

require_relative '../../../step/base'
require_relative '../../../step/token_merger'
require_relative '../../g_1822/step/minor_acquisition'

module Engine
  module Game
    module G1822Africa
      module Step
        class MinorAcquisition < Engine::Game::G1822::Step::MinorAcquisition
          def can_acquire?(entity)
            return false if !entity.corporation? || (entity.corporation? && entity.type != :major)

            !potentially_mergeable(entity).empty?
          end
        end
      end
    end
  end
end
