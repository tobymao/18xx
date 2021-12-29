# frozen_string_literal: true

require_relative '../../../step/token'

module Engine
  module Game
    module G18SJ
      module Step
        class Token < Engine::Step::Token
          def place_token(entity, city, token)
            token.price = 0 if @game.bot_corporation?(entity)
            super(entity, city, token)
          end

          def pass!
            @game.make_sj_tokens_passable_for_electric_trains(current_entity)
            super
          end
        end
      end
    end
  end
end
