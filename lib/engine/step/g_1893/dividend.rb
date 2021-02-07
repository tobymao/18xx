# frozen_string_literal: true

require_relative '../dividend'
require_relative '../minor_half_pay'

module Engine
  module Step
    module G1893
      class Dividend < Dividend
        include MinorHalfPay
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
