# frozen_string_literal: true

require_relative '../../../step/base'

module Engine
  module Game
    module G18OE
      module Step
        class Consolidate < Engine::Step::Base
          ACTIONS = [].freeze # merge/abandon actions to be added

          def actions(entity)
            return [] unless entity == current_entity
            return [] if pending_corps(entity).empty?

            ACTIONS
          end

          def description
            'Consolidate or abandon minors/regionals'
          end

          def blocks?
            !pending_corps(current_entity).empty?
          end

          private

          def pending_corps(entity)
            @game.corporations.select { |c| %i[minor regional].include?(c.type) && c.president?(entity) }
          end
        end
      end
    end
  end
end
