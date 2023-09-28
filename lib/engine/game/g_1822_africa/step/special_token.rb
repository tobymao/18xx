# frozen_string_literal: true

require_relative '../../g_1822/step/special_token'

module Engine
  module Game
    module G1822Africa
      module Step
        class SpecialToken < G1822::Step::SpecialToken
          def process_place_token(action)
            super

            return unless action.entity.id == @game.class::COMPANY_GOLD_MINE

            token = action.city.tokens.reverse.find(&:itself)
            token.corporation = @game.gold_mine_corp
            token.logo = @game.gold_mine_corp.logo
            token.simple_logo = token.logo
            @game.gold_mine_token = token
          end
        end
      end
    end
  end
end
