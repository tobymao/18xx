# frozen_string_literal: true

require_relative '../../../step/token'

module Engine
  module Game
    module G18Neb
      module Step
        class Token < Engine::Step::Token
          def can_place_token?(entity)
            super || @game.cattle_company&.owner == entity
          end
        end
      end
    end
  end
end
