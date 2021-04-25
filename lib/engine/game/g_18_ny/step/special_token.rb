# frozen_string_literal: true

require_relative '../../../step/special_token'

module Engine
  module Game
    module G18NY
      module Step
        class SpecialToken < Engine::Step::SpecialToken
          def process_place_token(action)
            super

            company = action.entity

            token = company.owner.tokens.find { |token| token.hex&.id == 'F20' }
            token.logo = '/logos/18_ny/stagecoach.svg'
            token.simple_logo = '/logos/18_ny/stagecoach.alt.svg'

            @log << "#{company.name} closes"
            company.close!
          end
        end
      end
    end
  end
end
