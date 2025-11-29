# frozen_string_literal: true

require_relative '../../../step/token'

module Engine
  module Game
    module G18RoyalGorge
      module Step
        class Token < Engine::Step::Token
          # home token counts as the token placement for the first turn
          def actions(entity)
            entity == current_entity && entity.operated? ? super : []
          end
        end
      end
    end
  end
end
