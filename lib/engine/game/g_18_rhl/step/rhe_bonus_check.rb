# frozen_string_literal: true

require_relative '../../../step/base'

module Engine
  module Game
    module G18Rhl
      module Step
        class RheBonusCheck < Engine::Step::Base
          # As long as the Aachen Duren Cologne link has not been built, we need
          # to check for this after potential track lay/upgrade after each
          # corporation does during their OR.
          # As soon as the link has been established, no more checks are needed.
          #
          ACTIONS = %w[destination_connection].freeze

          def auto_actions(entity)
            return unless @game.aachen_duren_cologne_link_checkable?

            [Engine::Action::DestinationConnection.new(
              entity,
              corporations: @game.aachen_duren_cologne_link_established? ? [@game.rhe] : [],
            )]
          end

          def description
            'Check for Aachen-Düren-Köln connection'
          end

          def actions(_entity)
            return [] unless @game.aachen_duren_cologne_link_checkable?

            ACTIONS
          end

          # Skip silently - is of no interest when link has been established
          def log_skip(_entity); end

          # (Copied from 1870)
          # This step should not be passed
          # This prevents the force_next_entity! from trying
          def pass!; end

          def process_destination_connection(action)
            @game.aachen_duren_cologne_link_established! unless action.corporations.empty?
            @passed = true
          end
        end
      end
    end
  end
end
