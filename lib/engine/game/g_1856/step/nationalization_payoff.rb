# frozen_string_literal: true

require_relative '../../../step/base'
# require_relative 'tokener'

module Engine
  module Game
    module G1856
      module Step
        class NationalizationPayoff < Engine::Step::Base
          # To get to re-use view code from 18MEX we will slightly abuse merge and pass
          # Merge - Merge the corporation into the CGR
          # Pass - Payoff the loan debt owed by the corporation
          ACTIONS = %w[merge pass].freeze

          def actions(_entity)
            return [] unless merge_ongoing?

            ACTIONS
          end

          def active_entities
            merge_ongoing? ? [@game.nationalizables.first].compact : []
          end

          def merge_target
            @game.national
          end

          def merge_name(_entity = nil)
            "Merge into #{@game.national.name}"
          end

          def mergeable_type(corporation)
            "Corporations that can merge with #{corporation.name}"
          end

          def mergeable(_corporation)
            return [] unless merge_ongoing?

            [@game.nationalizables.first]
          end

          def override_entities
            @game.nationalizables
          end

          def show_other_players
            true
          end

          def active?
            merge_ongoing?
          end

          def blocking?
            merge_ongoing?
          end

          def description
            'Nationalization - Loan payoffs'
          end

          def amount_owed
            100 * @game.nationalizables.first.loans.size
          end

          def pass_description
            "Pay #{@game.format_currency(amount_owed - @game.nationalizables.first.cash)} to cover loans"
          end

          def process_merge(action)
            @game.merge_major(action.corporation)
          end

          def process_pass(_action)
            presidential_contribution = amount_owed - @game.nationalizables.first.cash
            @game.nationalization_president_payoff(@game.nationalizables.first, presidential_contribution)
          end

          private

          def merge_ongoing?
            @game.nationalizables.any?
          end
        end
      end
    end
  end
end
