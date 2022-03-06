# frozen_string_literal: true

require_relative '../../../step/special_token'

module Engine
  module Game
    module G18LosAngeles
      module Step
        class SpecialToken < Engine::Step::SpecialToken
          def process_place_token(action)
            if (action.entity == @game.dch) && action.city.tokenable?(action.entity.owner)
              raise GameError, 'Dewey, Cheatham, and Howe can only place a token in '\
                               'a city (other than Long Beach) with no open slots.'
            end

            super

            if action.entity == @game.rj
              token = action.city.tokens.reverse.find(&:itself)
              token.logo = token.logo.sub('.svg', '_RJ.svg')
              token.simple_logo = token.logo
              @game.rj_token = token
            elsif action.entity == @game.dump_company
              token = action.city.tokens.reverse.find(&:itself)
              token.corporation = @game.dump_corp
              token.logo = @game.dump_corp.logo
              token.simple_logo = token.logo
              @game.dump_token = token
            end
          end
        end
      end
    end
  end
end
