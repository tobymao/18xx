# frozen_string_literal: true

require_relative '../base'
# require_relative 'tokener'

module Engine
  module Step
    module G18Mex
      class Merge < Base
        ACTIONS = %w[merge pass].freeze

        def actions(_entity)
          return [] unless merge_ongoing?

          ACTIONS
        end

        def active_entities
          merge_ongoing? ? [@game.merge_decider].compact : []
        end

        def merge_target
          @game.ndm
        end

        def mergeable(_corporation)
          return [] unless merge_ongoing?

          [@game.mergeable_candidates.first]
        end

        def active?
          merge_ongoing?
        end

        def blocking?
          merge_ongoing?
        end

        def description
          'NdM Merge'
        end

        def pass_description
          'Decline'
        end

        def process_merge(action)
          @game.merge_major(action.corporation)
        end

        def process_pass(_action)
          @game.decline_merge(@game.mergeable_candidates.first)
        end

        private

        def merge_ongoing?
          @game.mergeable_candidates.any?
        end
      end
    end
  end
end
