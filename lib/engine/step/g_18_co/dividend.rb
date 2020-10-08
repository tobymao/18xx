# frozen_string_literal: true

require_relative '../dividend'

module Engine
  module Step
    module G18CO
      class Dividend < Dividend
        def share_price_change(entity, revenue = 0)
          @log << 'TODO: implement multi-jump'
          super
        end
      end
    end
  end
end
