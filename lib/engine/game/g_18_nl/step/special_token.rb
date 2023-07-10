# frozen_string_literal: true

require_relative '../../../step/special_token'

module Engine
  module Game
    module G18NL
      module Step
        class SpecialToken < Engine::Step::SpecialToken
          def process_place_token(action)
            entity = action.entity
            city = action.city
            if city.tile.paths.empty?
              super
              @game.log << "#{entity.name} closes"
              entity.close!
            else
              # Handle the case when tile.paths is not empty
              raise GameError, 'Cannot place station on hex with existing track'
            end
          end
        end
      end
    end
  end
end
