# frozen_string_literal: true

require_relative '../assign'

module Engine
  module Step
    module G18FL
      class Assign < Assign
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
