# frozen_string_literal: true

require_relative '../../../round/operating'

module Engine
  module Game
    module G1835
      module Round
        class Operating < Engine::Round::Operating
          def description
            "Operating Round #{@game.turn}"
          end
        end
      end
    end
  end
end
