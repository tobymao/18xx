# frozen_string_literal: true

require_relative '../../../round/operating'

module Engine
  module Game
    module G18NY
      module Round
        class Operating < Engine::Round::Operating
          def initialize(game, steps, **opts)
            super
            @check_nyc_formation_step = @steps.find { |step| step.is_a?(Step::CheckNYCFormation) }
          end

          def skip_entity?(entity)
            entity.closed? || entity.receivership?
          end

          def cash_crisis_entity
            @game.corporations.find { |corp| corp.cash.negative? }
          end

          def auto_actions
            @check_nyc_formation_step.auto_actions(current_entity).concat(Array(super))
          end
        end
      end
    end
  end
end
