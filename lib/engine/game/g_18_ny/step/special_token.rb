# frozen_string_literal: true

require_relative '../../../step/special_token'

module Engine
  module Game
    module G18NY
      module Step
        class SpecialToken < Engine::Step::SpecialToken
          def process_place_token(action)
            corporation = action.token.corporation
            token = Token.new(corporation, logo: 'stagecoach', simple_logo: 'stagecoach.alt')
            action.token = token

            super(action)
          end
        end
      end
    end
  end
end
