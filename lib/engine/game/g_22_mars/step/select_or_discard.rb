# frozen_string_literal: true

module Engine
  module Game
    module G22Mars
      module Step
        class SelectOrDiscard < Engine::Step::SimpleDraft
          ACTIONS = %w[bid pass].freeze

          def setup
            @companies = @game.companies
          end

          def available
            [@companies.first]
          end

          def finished?
            @companies.empty?
          end

          def actions(entity)
            return [] if finished?

            entity == current_entity ? ACTIONS : []
          end

          def process_pass(action)
            company = available.first
            player = action.entity

            company.close!
            @companies.delete(company)

            @log << "#{player.name} discards #{company.name} from the game"

            @round.next_entity_index!
            action_finalized
          end

          def description
            'Buy or Discard Permit'
          end

          def pass_description
            'Discard Permit'
          end
        end
      end
    end
  end
end
