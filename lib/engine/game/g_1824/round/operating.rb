# frozen_string_literal: true

require_relative '../../../round/operating'

module Engine
  module Game
    module G1824
      module Round
        class Operating < Engine::Round::Operating
        end

        def round_state
          super.merge(
            {
              pending_tokens: [],
            }
          )
        end
      end
    end
  end
end
