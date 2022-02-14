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
        end
      end
    end
  end
end
