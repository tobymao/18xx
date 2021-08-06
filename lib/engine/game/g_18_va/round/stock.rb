# frozen_string_literal: true

require_relative '../../../round/stock'

module Engine
  module Game
    module G18VA
      module Round
        class Stock < Engine::Round::Stock
          def sold_out?(corporation)
            # Only 10 share corporations may get end-of-round stock bumps
            return false unless corporation.type == :ten_share

            super
          end
        end
      end
    end
  end
end
