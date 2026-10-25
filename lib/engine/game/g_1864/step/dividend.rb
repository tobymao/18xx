# frozen_string_literal: true

require_relative '../../g_1867/step/dividend'

module Engine
  module Game
    module G1864
      module Step
        class Dividend < G1867::Step::Dividend
          def actions(entity)
            return [] if entity == @game.union_pacific

            super
          end

          def skip!
            return super unless current_entity == @game.union_pacific

            process_dividend(Action::Dividend.new(current_entity, kind: 'payout'))
          end
        end
      end
    end
  end
end
