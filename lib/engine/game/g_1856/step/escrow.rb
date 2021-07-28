# frozen_string_literal: true

require_relative '../../../step/base'

module Engine
  module Game
    module G1856
      module Step
        class Escrow < Engine::Step::Base
          ACTIONS = %w[destination_connection].freeze
          # Since *any* corporation could destinated after a given corporation does a tile lay, we need
          # to check for *all* corporations, and since multiple corporations could destinate at once
          # we need to be able to support multiple destinating at once
          def auto_actions(entity)
            [
              Engine::Action::DestinationConnection.new(
                entity,
                corporations: @game.corporations.select { |c| @game.destination_connected?(c) }
              ),
            ]
          end

          def description
            'Escrow Calculation - Undo if you see this'
          end

          def actions(_entity)
            ACTIONS
          end

          def process_destination_connection(action)
            action.corporations.each { |corp| @game.destinated!(corp) }
            pass!
          end
        end
      end
    end
  end
end
