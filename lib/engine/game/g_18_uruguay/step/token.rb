# frozen_string_literal: true

require_relative '../../../step/token'

module Engine
  module Game
    module G18Uruguay
      module Step
        class Token < Engine::Step::Token
          def actions(entity)
            return [] if entity == @game.rptla
            return [] if @game.final_operating_round?

            @round.loan_taken |= false
            actions = super.map(&:clone)
            if !actions.empty? && @game.can_take_loan?(entity) && !@round.loan_taken && !@game.nationalized?
              actions << 'take_loan'
            end
            actions
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
