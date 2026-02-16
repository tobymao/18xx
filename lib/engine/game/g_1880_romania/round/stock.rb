# frozen_string_literal: true

require_relative '../../g_1880/round/stock'

module Engine
  module Game
    module G1880Romania
      module Round
        class Stock < G1880::Round::Stock
          def show_auto?
            true
          end
        end
      end
    end
  end
end
