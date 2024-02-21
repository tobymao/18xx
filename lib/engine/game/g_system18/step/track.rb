# frozen_string_literal: true

require_relative '../../../step/track'

module Engine
  module Game
    module GSystem18
      module Step
        class Track < Engine::Step::Track
          def actions(entity)
            entity.receivership? ? [] : super
          end
        end
      end
    end
  end
end
