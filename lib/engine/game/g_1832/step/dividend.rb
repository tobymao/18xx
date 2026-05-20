# frozen_string_literal: true

require_relative '../../g_1870/step/dividend'

module Engine
  module Game
    module G1832
      module Step
        # Inherits full/half/withhold with correct stock price movement from 1870:
        # right on full dividend, left on withhold, no movement on half or $0 declared.
        class Dividend < G1870::Step::Dividend
          def process_dividend(action)
            super
            close_london_investment!(action)
          end

          private

          def close_london_investment!(action)
            return if action.kind == 'withhold'

            p4 = @game.london_company
            return if !p4 || p4.closed? || @game.p4_invested_in != action.entity

            p4.close!
            @game.log << "#{p4.name} closes as #{action.entity.name} pays its first dividend"
          end
        end
      end
    end
  end
end
