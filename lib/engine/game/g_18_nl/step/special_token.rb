# frozen_string_literal: true

require_relative '../../../step/special_token'

module Engine
  module Game
    module G18NL
      module Step
        class SpecialToken < Engine::Step::SpecialToken
          def special_token
            raise GameError, 'Cannot place station on hex or tile with existing track' unless tile.paths.empty?
          end

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
