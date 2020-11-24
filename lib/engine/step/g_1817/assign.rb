# frozen_string_literal: true

require_relative '../assign'

module Engine
  module Step
    module G1817
      class Assign < Assign
        def process_assign(action)
          company = action.entity
          target = action.target

          unless (ability = company.abilities(:assign_hexes))
            @game.game_error("Could not assign #{company.name} to #{target.name}; :assign_hexes ability not found")
          end

          case company.id
          when 'UBC', 'OBC'
            id = 'bridge'
            @game.game_error("Bridge already on #{target.name}") if target.assigned?(id)
            target.assign!(id)
            ability.use!
            @log.action! "builds bridge on #{target.name}"
          end
        end
      end
    end
  end
end
