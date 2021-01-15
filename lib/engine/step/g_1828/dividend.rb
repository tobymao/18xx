# frozen_string_literal: true

require_relative '../dividend'
require_relative '../minor_half_pay'

module Engine
  module Step
    module G1828
      class Dividend < Dividend
        include MinorHalfPay

        # Systems also get paid for their treasury share
        def corporation_dividends(entity, per_share)
          super + (entity.system? ? per_share : 0)
        end
      end
    end
  end
end
