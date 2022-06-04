# frozen_string_literal: true

require_relative '../../../step/assign'

module Engine
  module Game
    module G18SJ
      module Step
        class AssignSveabolaget < Engine::Step::Assign
          ACTIONS = %w[assign].freeze

          def actions(entity)
            return ACTIONS if entity.company? &&
                              entity == @game.sveabolaget &&
                              @game.abilities(entity, :assign_hexes)

            []
          end
        end
      end
    end
  end
end
