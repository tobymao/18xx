# frozen_string_literal: true

require_relative '../../../step/special_choose'
require_relative '../../../step/tokener'

module Engine
  module Game
    module G18ESP
      module Step
        class SpecialChoose < Engine::Step::SpecialChoose
          include Engine::Step::Tokener
          def actions(entity)
            return [] unless @game.phase.status.include?('mountain_pass')
            return [] unless opening_mountain_pass?(entity)

            super
          end

          def opening_mountain_pass?(entity)
            corp = entity.owner
            return false unless corp.corporation?

            !@game.opening_new_mountain_pass(corp).empty?
          end

          def choices_ability
            @game.opening_new_mountain_pass(current_entity, true)
          end

          def process_choose_ability(action)
            corp = action.entity.owner
            @game.open_mountain_pass(corp, action.choice, true)
            @game.graph_for_entity(corp).clear
            @log << "#{action.entity.name} closes"
            action.entity.close!
          end
        end
      end
    end
  end
end
