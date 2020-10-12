# frozen_string_literal: true

require_relative '../g_1846/draft_2p_distribution'

module Engine
  module Step
    module G18LosAngeles
      class DraftDistribution < G1846::Draft2pDistribution
        def process_pass(action)
          return super unless only_one_company?

          @log << "#{action.entity.name} passes"
          @round.next_entity_index!
          action.entity.pass!
        end
      end
    end
  end
end
