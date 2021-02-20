# frozen_string_literal: true

require_relative '../../../step/dividend'
require_relative '../../../step/minor_half_pay'

module Engine
  module Game
    module G1893
      module Step
        class Dividend < Engine::Step::Dividend
          include Engine::Step::MinorHalfPay
          def actions(entity)
            return [] if routeless_minor?(entity)

            super
          end

          def skip!
            return [] if routeless_minor?(current_entity)

            super
          end

          private

          def routeless_minor?(entity)
            entity.minor? && routes.empty?
          end
        end
      end
    end
  end
end
