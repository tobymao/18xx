# frozen_string_literal: true

require_relative '../../../step/dividend'

module Engine
  module Game
    module G18Ardennes
      module Step
        class Dividend < Engine::Step::Dividend
          def payout(entity, revenue)
            return half(entity, revenue) if entity.type == :minor

            super
          end

          def half(_entity, revenue)
            withheld = (revenue / 2.0).ceil
            { corporation: withheld, per_share: revenue - withheld }
          end
        end
      end
    end
  end
end
