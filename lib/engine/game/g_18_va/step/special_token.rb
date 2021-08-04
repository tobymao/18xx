# frozen_string_literal: true

require_relative '../../../step/special_token'

module Engine
  module Game
    module G18VA
      module Step
        class SpecialToken < Engine::Step::SpecialToken
          def process_place_token(action)
            entity = action.entity
            super
            @game.log << "#{entity.name} closes"
            entity.close!
          end
        end
      end
    end
  end
end
