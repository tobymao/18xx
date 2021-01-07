# frozen_string_literal: true

require_relative '../dividend'
require_relative '../minor_half_pay'

module Engine
  module Step
    module G18Mag
      class Dividend < Dividend
        include MinorHalfPay
      end
    end
  end
end
