# frozen_string_literal: true

require_relative '../../../round/stock'

module Engine
  module Game
    module G1867
      module Round
        class Stock < Engine::Round::Stock
          def sold_out?(corporation)
            corporation.type == :major && super
          end
        end
      end
    end
  end
end
