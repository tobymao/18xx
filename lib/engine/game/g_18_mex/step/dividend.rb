# frozen_string_literal: true

require_relative '../../../step/dividend'
require_relative '../../../step/minor_half_pay'

module Engine
  module Game
    module G18MEX
      module Step
        class Dividend < Engine::Step::Dividend
          include Engine::Step::MinorHalfPay
        end
      end
    end
  end
end
