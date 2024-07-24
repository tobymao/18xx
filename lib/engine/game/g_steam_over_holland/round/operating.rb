# frozen_string_literal: true

require_relative '../../../round/operating'

module Engine
  module Game
    module GSteamOverHolland
      module Round
        class Operating < Engine::Round::Operating
          def setup
            @game.issued_shares = false

            super
          end
        end
      end
    end
  end
end
