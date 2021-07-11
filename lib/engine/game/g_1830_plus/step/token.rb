# frozen_string_literal: true

require_relative '../../../step/base'
require_relative '../../../step/token'
module Engine
  module Game
    module G1830Plus
      module Step
        class Token < Engine::Step::Token
          def place_token(entity, city, token, connected: true, extra_action: false,
                          special_ability: nil, check_tokenable: true, spender: nil)
            super
            @game.prr_graph.clear
            @game.graph.clear
          end
        end
      end
    end
  end
end
