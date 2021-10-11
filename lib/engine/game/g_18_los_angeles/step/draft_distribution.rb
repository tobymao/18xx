# frozen_string_literal: true

require_relative '../../g_1846/step/draft_2p_distribution'

module Engine
  module Game
    module G18LosAngeles
      module Step
        class DraftDistribution < G1846::Step::Draft2pDistribution
          def actions(entity)
            return [] if finished?

            entity == current_entity ? ACTIONS_WITH_PASS : []
          end

          def process_bid(_action)
            entities.each(&:unpass!)
            super
          end

          def process_pass(action)
            @log << "#{action.entity.name} passes"
            @round.next_entity_index!
            @round.next_entity_index! if current_entity == action.entity
            action.entity.pass!
          end
        end
      end
    end
  end
end
