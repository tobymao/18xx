# frozen_string_literal: true

require_relative 'dividend'

module Engine
  module Game
    module GSystem18
      module Step
        class ChinaDividend < Dividend
          def share_price_change(_entity, _revenue = 0)
            {}
          end
        end
      end
    end
  end
end
