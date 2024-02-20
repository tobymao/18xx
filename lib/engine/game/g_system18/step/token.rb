# frozen_string_literal: true

require_relative '../../../step/token'

module Engine
  module Game
    module GSystem18
      module Step
        class Token < Engine::Step::Token
          def actions(entity)
            entity.receivership? ? [] : super
          end
        end
      end
    end
  end
end
