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
            corporation = company.owner

            @game.stagecoach_token.corporation = corporation
            corporation.tokens << @game.stagecoach_token
            token = corporation.tokens.find { |t| t.hex&.id == 'F20' }
            token.swap!(@game.stagecoach_token)
            token.destroy!
            @game.add_stagecoach_token_exchange_ability(corporation)

            @log << "#{company.name} closes"
            company.close!
          end
        end
      end
    end
  end
end
