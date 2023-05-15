# frozen_string_literal: true

require_relative '../../../step/token'

module Engine
  module Game
    module G18Rhl
      module Step
        class Token < Engine::Step::Token
          def actions(entity)
            # Do not allow any token if receivership
            return [] if entity.receivership?

            super
          end

          def place_token(entity, city, token)
            # Due to changing the token type, this can cause problems when doing undo.
            # As a fall back assume first available token of type normal/neutral is OK
            super(entity, city, @game.get_token(entity, token))
          end
        end
      end
    end
  end
end
