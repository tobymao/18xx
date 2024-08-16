# frozen_string_literal: true

require_relative '../../../round/operating'

module Engine
  module Game
    module GSteamOverHolland
      module Round
        class Operating < Engine::Round::Operating
          attr_reader :issued_shares

          def setup
            @issued_shares = {}

            super
          end
        end
      end
    end
  end
end
