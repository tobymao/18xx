# frozen_string_literal: true

require_relative '../../../step/token'

module Engine
  module Game
    module GSteamOverHolland
      module Step
        class Token < Engine::Step::Token
          def can_place_token?(entity)
            return if entity.operating_history.size.zero?

            super
          end
        end
      end
    end
  end
end
