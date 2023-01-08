# frozen_string_literal: true

require_relative '../../../step/dividend'
require_relative '../../../step/minor_half_pay'

module Engine
  module Game
    module G1880
      module Step
        class Dividend < Engine::Step::Dividend
          def actions(entity)
            return [] if entity.minor?

            super
          end

          def skip!
            return super if current_entity.corporation? && !current_entity.minor?

            process_dividend(Action::Dividend.new(
              current_entity,
              kind: 'withhold',
            ))
          end
        end
      end
    end
  end
end
