# frozen_string_literal: true

require_relative '../stock'

module Engine
  module Round
    module G1867
      class Stock < Stock
        def sold_out?(corporation)
          corporation.type == :major && super
        end
      end
    end
  end
end
