# frozen_string_literal: true

require_relative '../../../step/assign'

module Engine
  module Game
    module G18FL
      module Step
        class Assign < Engine::Step::Assign
          def process_assign(action)
            super
            company = action.entity
            @game.current_entity.assign!(company.id)
            @log << "#{company.name} is assigned to #{@game.current_entity.name}"
            company.close!
          end
        end
      end
    end
  end
end
