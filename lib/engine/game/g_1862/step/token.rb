# frozen_string_literal: true

require_relative '../../../step/token'

module Engine
  module Game
    module G1862
      module Step
        class Token < Engine::Step::Token
          def actions(entity)
            return [] if entity.corporation? && entity.receivership?

            super
          end

          def description
            'Add Token'
          end
        end
      end
    end
  end
end
