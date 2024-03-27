# frozen_string_literal: true

require_relative '../../../step/special_choose'

module Engine
  module Game
    module G18India
      module Step
        class SpecialChoose < Engine::Step::SpecialChoose
          def round_state
            { terrain_discount: 0, discount_source: nil }.merge(super)
          end

          def setup
            @round.terrain_discount = 0
            @round.discount_source = nil
          end

          def process_choose_ability(action)
            entity = action.entity
            ability = abilities(entity)
            raise GameError, "#{entity.name} does not have a choice ability" unless entity.id == 'P4'

            @log << 'French EIC (P4) discount ability enabled.'
            @round.terrain_discount = 40
            @round.discount_source = entity
            ability.use!
          end
        end
      end
    end
  end
end
