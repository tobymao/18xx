# frozen_string_literal: true

require_relative '../../../step/token'

module Engine
  module Game
    module G1824
      module Step
        class Token < Engine::Step::Token
          def actions(entity)
            return [] if entity.receivership?

            super
          end
        end
      end
    end
  end
end
