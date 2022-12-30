# frozen_string_literal: true

require_relative '../../../step/base'

module Engine
  module Game
    module G18NY
      module Step
        class ViewAcquirable < Engine::Step::Base
          ACTIONS = %w[view_merge_options].freeze

          def actions(entity)
            return [] if entity != current_entity
            return [] unless entity.corporation?
            return [] if !@game.loading && @game.acquisition_candidates(entity).empty?

            ACTIONS
          end

          def view_merge_name
            'Mergers/Takeovers'
          end

          def process_view_merge_options(_action)
            @round.view_merge_options = true
          end

          def blocks?
            false
          end

          def round_state
            { view_merge_options: false }
          end
        end
      end
    end
  end
end
