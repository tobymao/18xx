# frozen_string_literal: true

require_relative '../../../step/dividend'
require_relative '../../../step/minor_half_pay'

module Engine
  module Game
    module G1828
      module Step
        class Dividend < Engine::Step::Dividend
          include Engine::Step::MinorHalfPay

          # Systems also get paid for their treasury share
          def corporation_dividends(entity, per_share)
            super + (entity.system? ? per_share : 0)
          end
        end
      end
    end
  end
end
