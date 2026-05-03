# frozen_string_literal: true

require_relative '../../../step/dividend'
require_relative '../../../step/half_pay'

module Engine
  module Game
    module G18OE
      module Step
        class Dividend < Engine::Step::Dividend
          include Engine::Step::HalfPay

          def dividend_types
            case current_entity.type
            when :minor
              [:half]
            when :national
              [:payout]
            else
              %i[withhold half payout]
            end
          end
        end
      end
    end
  end
end
