# frozen_string_literal: true

require_relative '../dividend'

module Engine
  module Step
    module G18TN
      class Dividend < Dividend
        # TODO: Should stock market be unchanged (due to civil war) if only one route?
        def process_dividend(action)
          super

          abilities = action.entity.abilities(:civil_war)

          return if !abilities || abilities.empty?

          ability = abilities.first
          @log << "#{action.entity.name} resolves Civil War"
          ability.use!
        end
      end
    end
  end
end
