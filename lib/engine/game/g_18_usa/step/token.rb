# frozen_string_literal: true

require_relative '../../../step/token'
require_relative 'scrap_train_module'

module Engine
  module Game
    module G18USA
      module Step
        class Token < Engine::Step::Token
          include ScrapTrainModule
          def place_token(entity, city, token, connected: true, extra_action: false,
                          special_ability: nil, check_tokenable: true, spender: nil)
            super
            @game.jump_graph.clear
          end
        end
      end
    end
  end
end
