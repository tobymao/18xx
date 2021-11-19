# frozen_string_literal: true

require_relative '../../../step/base'

module Engine
  module Game
    module G18MEX
      module Step
        class Merge < Engine::Step::Base
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

          def merge_name(_entity = nil)
            "Merge #{mergee.name} into #{merge_target.name}"
          end

          def mergeable_type(corporation)
            "Corporations that can merge with #{corporation.name}"
          end

          def mergeable(_corporation)
            return [] unless merge_ongoing?

            [mergee]
          end

          def override_entities
            @game.mergeable_candidates
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
            'NdM Merge'
          end

          def pass_description
            'Decline'
          end

          def process_merge(action)
            @game.merge_major(action.corporation)
          end

          def process_pass(_action)
            @game.decline_merge(mergee)
          end

          private

          def merge_ongoing?
            @game.mergeable_candidates.any?
          end

          def mergee
            @game.mergeable_candidates.first
          end
        end
      end
    end
  end
end
