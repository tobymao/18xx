# frozen_string_literal: true

require_relative '../../../step/base'

module Engine
  module Game
    module G18Rhl
      module Step
        class RheBonusCheck < Engine::Step::Base
          # As long as the Aachen Duren Cologne link has not been built, we need
          # to check for this as the first thing each corporation does during its
          # OR.
          # As soon as the link has been established, no more checks are needed.
          #
          # TODO RhE should really check this after each tile lay during its OR (as
          # a tile lay by RhE can create the link, which should give RhE money for
          # train buy when link is established.)
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

          def process_destination_connection(action)
            @game.aachen_duren_cologne_link_established! unless action.corporations.empty?
            pass!
          end
        end
      end
    end
  end
end
