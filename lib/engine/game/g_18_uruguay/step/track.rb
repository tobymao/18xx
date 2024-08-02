# frozen_string_literal: true

require_relative '../../../step/tracker'
require_relative '../../../step/track'

module Engine
  module Game
    module G18Uruguay
      module Step
        class Track < Engine::Step::Track
          def actions(entity)
            return [] if entity.minor?
            return [] if entity == @game.rptla
            return [] if @game.last_or?

            @round.loan_taken |= false
            actions = super.map(&:clone)
            actions << 'take_loan' if @game.can_take_loan?(entity) && !@round.loan_taken && !@game.nationalized?

            actions
          end

          def log_skip(entity)
            return if entity.minor?
            return if entity.corporation == @game.rptla

            super
          end

          def process_take_loan(action)
            entity = action.entity
            @game.take_loan(entity, action.loan) unless @round.loan_taken
            @round.loan_taken = true
          end
        end
      end
    end
  end
end
