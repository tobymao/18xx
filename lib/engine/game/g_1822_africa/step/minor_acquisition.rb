# frozen_string_literal: true

require_relative '../../../step/base'
require_relative '../../../step/token_merger'

module Engine
  module Game
    module G1822Africa
      module Step
        class MinorAcquisition < G1822::Step::MinorAcquisition
          def can_acquire?(entity)
            return false if !entity.corporation? || (entity.corporation? && entity.type != :major)

            !potentially_mergeable(entity).empty?
          end
        end
      end
    end
  end
end
