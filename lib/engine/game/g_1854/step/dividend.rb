# frozen_string_literal: true

require_relative '../../../step/dividend'
require_relative '../../../step/minor_half_pay'

module Engine
  module Game
    module G1854
      module Step
        class Dividend < Engine::Step::Dividend
          include Engine::Step::MinorHalfPay

          def change_share_price(entity, payout)
            super
            @game.possibly_convert(entity)
          end
        end
      end
    end
  end
end
