# frozen_string_literal: true

require_relative '../../../round/operating'
require_relative '../step/destination'

module Engine
  module Game
    module G1844
      module Round
        class Operating < Engine::Round::Operating
          def initialize(game, steps, **opts)
            super
            @destination_step = @steps.find { |step| step.is_a?(Step::Destination) }
          end

          def auto_actions
            @destination_step.auto_actions(current_entity).concat(Array(super))
          end
        end
      end
    end
  end
end
