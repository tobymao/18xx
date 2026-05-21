# frozen_string_literal: true

require_relative '../../../step/base'

module Engine
  module Game
    module G1862UsaCanada
      module Step
        class RepayBond < Engine::Step::Base
          ACTIONS = %w[choose pass].freeze

          def description
            'Repay Bond (Schuldschein)'
          end

          def pass_description
            'Skip Bond Repayment'
          end

          def actions(entity)
            return [] unless entity.corporation?
            return [] unless entity == current_entity
            return [] unless @game.bond?(entity)
            return [] unless entity.cash >= @game.bond_amount(entity)

            ACTIONS
          end

          def choice_name
            amount = @game.bond_amount(current_entity)
            "Repay #{@game.format_currency(amount)} bond — director sell-block lifted"
          end

          def choices
            amount = @game.bond_amount(current_entity)
            { 'repay' => "Repay #{@game.format_currency(amount)} bond" }
          end

          def process_choose(action)
            @game.repay_bond!(action.entity)
            pass!
          end

          def process_pass(_action)
            pass!
          end

          def log_skip(_entity)
            # silent skip
          end
        end
      end
    end
  end
end
