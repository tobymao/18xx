# frozen_string_literal: true

require_relative '../../../step/return_token'

module Engine
  module Game
    module G18CO
      module Step
        class ReturnToken < Engine::Step::ReturnToken
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
end
