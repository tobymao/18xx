# frozen_string_literal: true

require_relative '../../../step/route'

module Engine
  module Game
    module G18NewEngland
      module Step
        class Route < Engine::Step::Route
          def train_name(_entity, train)
            @game.train_name(train)
          end
        end
      end
    end
  end
end
