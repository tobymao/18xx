# frozen_string_literal: true

require_relative '../../g_1837/round/operating'

module Engine
  module Game
    module G1824
      module Round
        class Operating < G1837::Round::Operating
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
