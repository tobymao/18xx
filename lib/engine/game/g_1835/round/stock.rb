# frozen_string_literal: true

require_relative '../../../round/operating'
module Engine
  module Game
    module G1835
      module Round
        class Stock < Engine::Round::Stock
          def pending_tokens
            # Baden might need to choose where to place its home token during the stock round
            @pending_tokens ||= []
          end
        end
      end
    end
  end
end
