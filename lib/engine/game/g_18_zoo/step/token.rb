# frozen_string_literal: true

module Engine
  module Game
    module G18ZOO
      module Step
        class Token < Engine::Step::Token
          include Engine::Game::G18ZOO::ChooseAbilityOnOr
        end
      end
    end
  end
end
