# frozen_string_literal: true

require_relative '../../../step/token'

module Engine
  module Game
    module G18Uruguay
      module Step
        class Token < Engine::Step::Token
          def actions(entity)
            return [] if entity == @game.rptla
            return [] if @game.last_or?

            @round.loan_taken |= false
            actions = super.map(&:clone)
            actions << 'take_loan' if !actions.empty? && can_take_loan?(entity)
            actions
          end

          def log_skip(entity)
            return if entity.minor?
            return if entity.corporation == @game.rptla

            super
          end

          def can_take_loan?(entity)
            @game.can_take_loan?(entity) && !@round.loan_taken && !@game.nationalized?
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
