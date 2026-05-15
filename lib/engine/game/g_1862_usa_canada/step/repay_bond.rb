# frozen_string_literal: true

module Engine
  module Game
    module G1862UsaCanada
      module Step
        class RepayBond < Engine::Step::Base
          ACTIONS = %w[payoff_debt pass].freeze

          def actions(entity)
            return [] if entity != current_entity || !entity.corporation?
            return [] if !@game.bond?(entity) || !entity.cash.positive?

            ACTIONS
          end

          def description
            'Repay Bond (Optional)'
          end

          def pass_description
            'Skip Bond Repayment'
          end

          def process_payoff_debt(_action)
            entity = current_entity
            @game.repay_bond!(entity)
            pass!
          end

          def process_pass(_action)
            pass!
          end

          def blocks?
            false
          end
        end
      end
    end
  end
end
