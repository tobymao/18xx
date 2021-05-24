# frozen_string_literal: true

require_relative 'choose_ability_on_or'
module Engine
  module Game
    module G18ZOO
      module Step
        class Token < Engine::Step::Token
          include Engine::Game::G18ZOO::ChooseAbilityOnOr

          def can_place_token?(entity)
            current_entity == entity &&
              !@round.tokened &&
              !(tokens = available_tokens(entity)).empty? &&
              min_token_price(tokens) <= @game.buying_power(entity, use_tickets: true) &&
              @game.graph.can_token?(entity)
          end

          def help
            @game.threshold_help
          end
        end
      end
    end
  end
end
