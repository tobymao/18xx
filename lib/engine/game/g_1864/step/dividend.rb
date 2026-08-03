# frozen_string_literal: true

require_relative '../../g_1867/step/dividend'

module Engine
  module Game
    module G1864
      module Step
        class Dividend < G1867::Step::Dividend
          def actions(entity)
            # The UP has no choice; it always pays out in full.
            return [] if entity.corporation? && entity.type == :national

            super
          end

          def skip!
            return super unless current_entity.type == :national

            process_dividend(Action::Dividend.new(current_entity, kind: 'payout'))
          end

          def payout(entity, revenue)
            return super if entity.type != :national

            { corporation: 0, per_share: revenue / entity.total_shares }
          end
        end
      end
    end
  end
end
