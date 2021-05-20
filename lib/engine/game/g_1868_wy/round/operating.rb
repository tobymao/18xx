# frozen_string_literal: true

require_relative '../../../round/operating'

module Engine
  module Game
    module G1868WY
      module Round
        class Operating < Engine::Round::Operating
          def setup
            @game.setup_development_tokens

            super
          end
        end
      end
    end
  end
end
