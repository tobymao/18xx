# frozen_string_literal: true

require_relative '../return_token'

module Engine
  module Step
    module G18CO
      class ReturnToken < ReturnToken
        def process_remove_token(action)
          company = action.entity
          return_ability = ability(company)

          super

          return if return_ability.count.positive?

          company.close!
          @game.log << "#{company.name} closes"
        end
      end
    end
  end
end
